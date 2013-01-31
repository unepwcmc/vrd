namespace :vrd do
  desc "Update CartoDB with fundings statistics"
  task :update_cartodb => :environment do

    #excluded_countries = %w{AU AT BY BE BG CA HR CZ DK EE FI FR DE GR HU IS IE IT JP LV LI LT LU ME MT MC NL NZ NO PL PT RO RS RU SK SI ES SE CH TR UA GB US}
    excluded_countries = []

    # Select ROWID's and ISO2's
    rows = CartoDB::Connection.query("SELECT cartodb_id, iso2, name, received_byfunders, recieved_byrecipients, funded_byfunders, funded_byrecipients, total_byfunders, total_byrecipients FROM #{APP_CONFIG['cartodb_point_table']}")[:rows]

    # For each record in fusion tables, calculate values
    rows.each do |row|
      next if row[:iso2] == -99
      country_institution = Institution.find(:first, conditions: ['iso2 ILIKE ?', row[:iso2]])

      received_byfunders_contributions = AnnualFinancing.fusion_tables_query(row[:iso2], 'received', 'funder')
      received_byrecipients_contributions = AnnualFinancing.fusion_tables_query(row[:iso2], 'received', 'recipient')
      funded_byfunders_contributions = AnnualFinancing.fusion_tables_query(row[:iso2], 'funded', 'funder')
      funded_byrecipients_contributions = AnnualFinancing.fusion_tables_query(row[:iso2], 'funded', 'recipient')

      if country_institution.nil? || excluded_countries.include?(row[:iso2].upcase)
        received_byfunders = 0
        received_byrecipients = 0
        funded_byfunders = 0
        funded_byrecipients = 0
        total_byfunders = 0
        total_byrecipients = 0
      else
        received_byfunders = ("%.3f" % received_byfunders_contributions.to_a.sum(&:contribution)).to_f
        received_byrecipients = ("%.3f" % received_byrecipients_contributions.to_a.sum(&:contribution)).to_f
        
        funded_byfunders = ("%.3f" % funded_byfunders_contributions.to_a.sum(&:contribution)).to_f
        funded_byrecipients = ("%.3f" % funded_byrecipients_contributions.to_a.sum(&:contribution)).to_f
        
        total_byfunders = funded_byfunders - received_byfunders
        total_byrecipients = funded_byrecipients - received_byrecipients
      end

      unless country_institution.nil?
  
        # Push update if any of the fields have changed
        if row[:received_byfunders].to_f != received_byfunders || row[:recieved_byrecipients].to_f != received_byrecipients ||
          row[:funded_byfunders].to_f != funded_byfunders || row[:funded_byrecipients].to_f != funded_byrecipients ||
          row[:total_byfunders].to_f != total_byfunders || row[:total_byrecipients].to_f != total_byrecipients ||
          country_institution.try(:name) != row[:name]

          puts "#{country_institution.try(:name)} (#{country_institution.try(:iso2)}) [received_by_funder: #{received_byfunders}, received_by_recipient: #{received_byrecipients}, funded_by_funder: #{funded_byfunders}, funded_by_recipient: #{funded_byrecipients}, total_by_funder: #{total_byfunders}, total_by_recipient: #{total_byrecipients}]"
          CartoDB::Connection.query(ActiveRecord::Base.send(:sanitize_sql_array, ["UPDATE #{APP_CONFIG['cartodb_point_table']} SET id_feed = ?, received_byfunders = ?, recieved_byrecipients = ?, funded_byfunders = ?, funded_byrecipients = ?, total_byfunders = ?, total_byrecipients = ?, name = ? WHERE cartodb_id = ?", country_institution.try(:id_feed), received_byfunders, received_byrecipients, funded_byfunders, funded_byrecipients, total_byfunders, total_byrecipients, country_institution.try(:name), row[:cartodb_id]]))
        end
      end
    end
  end
end
