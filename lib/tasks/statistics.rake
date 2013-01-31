namespace :vrd do
  require 'csv'

  desc "Import all the ISO3 codes, forest area, forest area percentage for the countries (institutions)"
  task :countries_statistics => :environment do
    # ISO3 CODES
    iso_codes = CSV.read("#{Rails.root}/lib/data/iso2_to_iso3.csv", {headers: true})
    iso_codes.each do |row|
      institution = Institution.find_by_iso2(row[0])
      institution.update_attribute(:iso3_code, row[1]) if institution
    end

    # FOREST AREA
    forest_area = CSV.read("#{Rails.root}/lib/data/forest_area.csv", {headers: true})
    forest_area.each do |row|
      institution = Institution.find_by_iso3_code(row[0])
      institution.update_attribute(:forest_area, row[1]) if institution
    end

    # FOREST AREA PERCENTAGE
    forest_area_percentage = CSV.read("#{Rails.root}/lib/data/forest_area_percentage.csv", {headers: true})
    forest_area_percentage.each do |row|
      institution = Institution.find_by_iso3_code(row[0])
      institution.update_attribute(:forest_area_percentage, row[1]) if institution
    end

    # POPULATION
    population = CSV.read("#{Rails.root}/lib/data/population.csv", {headers: true})
    population.each do |row|
      institution = Institution.find_by_iso3_code(row[0])
      institution.update_attribute(:population, row[1]) if institution
    end
  end

  desc "Import the GPS coordinates of countries using Google Geocoding API"
  task :country_coordinates => :environment do
    Institution.countries.each do |country|
      unless country.latitude && country.longitude
        response = Net::HTTP.get "maps.googleapis.com", URI.escape("/maps/api/geocode/json?address=#{country.name}&sensor=false")
        result = JSON.parse(response)

        if result['status'] == "OK"
          country.update_attributes(
            latitude: result['results'][0]['geometry']['location']['lat'],
            longitude: result['results'][0]['geometry']['location']['lng']
          )
        elsif
          puts "Not able to find GPS coordinates for #{country.name} (response status: #{result['status']})"
        end

        # Take your moment of rest, you deserve it!
        # http://code.google.com/apis/maps/documentation/geocoding/#Limits
        sleep(6)
      end
    end
  end

  desc "Only neeeded to generate a new version of 'countries_geometries.csv' from Protected Planet information"
  task :countries_geometries_build => :environment do
    sql = <<-EOF
SELECT c.iso, ST_asGeoJson(ST_Multi(ST_SimplifyPreserveTopology(g.the_geom, 0.01)), 3, 1)
  FROM country_with_geoms c
  INNER JOIN geoms g ON c.land_geom_id = g.id
EOF

    ActiveRecord::Base.connection.select_value("COPY (#{sql}) TO '#{Rails.root}/lib/data/countries_geometries.csv' WITH CSV HEADER")
  end

  desc "Import data from 'countries_geometries.csv' into geometries' table"
  task :countries_geometries_import => :environment do
    Geometry.delete_all

    geometries = CSV.read("#{Rails.root}/lib/data/countries_geometries.csv", {headers: true})
    geometries.each do |row|
      Geometry.create(:iso => row[0], :geom => row[1])
    end
  end

  desc "Import data from 'regions.csv' into regions and institutions tables"
  task :regions_import => :environment do
    countries = CSV.read("#{Rails.root}/lib/data/regions.csv", {headers: true})
    countries.each do |row|
      region = Region.find_or_create_by_name(row[1])
      country = Institution.find_by_iso2(row[0])

      country.update_attribute(:region_id, region.id) if country
    end
  end
  
  desc "Export arrangements CSV"
  task :arrangements_export => :environment do
    # Fixes "Constant loading when running rake task (expected x.rb to define X)"
    # See https://github.com/rails/rails/issues/882 for more information
    ActiveRecord::Base

    include ActionView::Helpers::SanitizeHelper

    CSV.open("#{Rails.root}/public/system/download_arrangements.csv", "wb") do |csv|
      csv << [
        'Arrangement ID',
        'Title',
        'Description',
        'From/to (years)',
        'Total contribution amount (millions of USD)',
        'Total disbursement amount (millions of USD)',
        'Data quality',
        'Reporter',
        'Reporter role',
        'Funding flow',
        'Funder',
        'Recipient',
        'Financing type',
        'Fast Start Finance',
        'Beneficiary countries',
        'Types of actions to be undertaken',
        'Additional notes'
      ]
      Arrangement.all.each do |arrangement|
        csv << [
          arrangement.id_feed,
          arrangement.title,
          strip_tags(arrangement.description),
          "#{arrangement.years.min}/#{arrangement.years.max}",
          sprintf("%#1.2f", arrangement.total_amount),
          arrangement.total_disbursement > 0 ? sprintf("%#1.2f", arrangement.total_disbursement) : '',
          arrangement.estimate ? 'contribution values contain estimates' : '',
          arrangement.reporting_institution.name,
          %w(outgoing internal).include?(arrangement.arrangement_type) ? 'Funder' : 'Recipient',
          arrangement.arrangement_type.humanize,
          arrangement.funder,
          arrangement.arrangement_type == 'unspecified' ? 'Unspecified' : arrangement.recipient,
          arrangement.financing_type ? arrangement.financing_type.humanize : '',
          arrangement.fast_start_finance ? 'Yes' : '',
          arrangement.beneficiary_countries.map(&:to_s).join(', '),
          arrangement.action_categories.map(&:to_s).join(', '),
          strip_tags(arrangement.additional_notes)
        ]
      end
    end
  end
end
