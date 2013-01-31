namespace :vrd do
  require 'httparty'

  class Feed
    include HTTParty
    format :xml
  end

  desc "Download all the arrangements"
  task :feed_arrangements => :environment do
    next_archive = 'https://partner.reddplusdatabase.org/api/atom/v2/arrangements'

    # Get cached headers for conditional get
    import = Import.where('date IS NOT NULL AND etag IS NOT NULL AND tag = \'arrangements\'').order('created_at DESC').first

    headers = { 'If-Modified-Since' => import.date, 'If-None-Match' => import.etag }  unless import.nil?
    reddplusdatabase = Feed.get(next_archive, { headers: (headers  if defined? headers) })

    # Exit if not modified...
    unless reddplusdatabase.headers['etag']
      puts "There are no new changes on Arrangements..."
      next
    end

    # Store conditional get headers
    conditional_get_headers = { 'If-Modified-Since' => reddplusdatabase.headers['date'], 'If-None-Match' => reddplusdatabase.headers['etag'] }

    # Find the last successfully imported entry from feed
    found_entry, last_page = false, false
    begin
      db = reddplusdatabase.parsed_response['feed']['entry']
      db = [db] unless db.kind_of?(Array)

      db.each do |entry|
        import = Import.where('last_entry_id IS NOT NULL AND tag = \'arrangements\'').order('created_at DESC').first
        found_entry = (import.try(:last_entry_id) == entry['id'])
      end

      unless found_entry
        # Getting the prev document (page)
        prev_archive_link = reddplusdatabase.parsed_response['feed']['link'].select { |link| link['rel'] == 'prev-archive' }.first

        if prev_archive_link
          next_archive = prev_archive_link['href']
          reddplusdatabase = Feed.get(next_archive)
        else
          last_page = true
        end
      end
    end until found_entry || last_page

    # Auxiliar variable to know if we should import all the entries (if 'last_page == true' that means we have to import everything)
    reverse_found_entry = last_page

    # Get All the Documents (pages)
    begin
      # Debug
      puts "Current page: #{next_archive}"

      db = reddplusdatabase.parsed_response['feed']['entry']
      db = [db] unless db.kind_of?(Array)

      # Loop All the Entries
      db.reverse_each do |entry|
        unless reverse_found_entry
          import = Import.where('last_entry_id IS NOT NULL AND tag = \'arrangements\'').order('created_at DESC').first
          reverse_found_entry = (import.try(:last_entry_id) == entry['id'])
          next
        end

        # Debug
        puts "#{entry['id']}: #{entry['title']}"

        events = entry['category']
        events = [events] unless events.kind_of?(Array)
        events = events.select { |category| category['scheme'] == 'https://partner.reddplusdatabase.org/api/category/event' }.map { |event| event['term'] } 

        # Delete operation
        if events.include?('DELETED')
          arrangement_id = entry['content']['arrangement_id']['__content__']

          arrangement = Arrangement.find_by_id_feed(arrangement_id)
          arrangement.destroy unless arrangement.nil?

          # Done. Next please!
          next
        end

        feed_arrangement = entry['content']['arrangement']

        # Arrangement
        arrangement = Arrangement.find_or_initialize_by_id_feed(feed_arrangement['id'])
        arrangement.attributes = {
          title: feed_arrangement['title'],
          description: feed_arrangement['description'],
          additional_notes: feed_arrangement['additional_notes'],
          objectives: feed_arrangement['objectives'],
          financing_type: (feed_arrangement['financing_type'].kind_of?(Array) ? feed_arrangement['financing_type'].join(',') : feed_arrangement['financing_type']),
          last_published_update: feed_arrangement['last_published'],
          # Period
          period_from: feed_arrangement['year_range']['start'],
          period_to: feed_arrangement['year_range']['end'],
          arrangement_type: feed_arrangement['flow'].downcase,
          fast_start_finance: feed_arrangement['fast_start_finance']
        }

        # Profile and institution
        profile = Profile.find_or_create_by_id_feed(feed_arrangement['profile_id'])
        institution = Institution.find_by_id_feed(feed_arrangement['institution_id'])

        arrangement.update_attributes({profile: profile, reported_on_institution: institution})

        # Financing
        feed_financing = feed_arrangement['financing']
        feed_financing = [feed_financing] unless feed_financing.kind_of?(Array)

        # Reset annual financings for the arrangement
        arrangement.annual_financings = []

        feed_financing.compact.each do |finance|
          annual_financing = AnnualFinancing.find_or_create_by_arrangement_id_and_year(arrangement.id, finance['year'])
          annual_financing.attributes = {
            contribution: finance['contribution'],
            disbursement: finance.try(:[], 'disbursement')
          }

          arrangement.annual_financings << annual_financing
        end

        # beneficiary-countries (Arrangement)
        if feed_arrangement['beneficiary_country_id'].nil?
          feed_beneficiary_countries = []
        else
          feed_beneficiary_countries = feed_arrangement['beneficiary_country_id']
          feed_beneficiary_countries = [feed_beneficiary_countries] unless feed_beneficiary_countries.kind_of?(Array)
        end

        feed_beneficiary_countries.each do |feed_country_id|
          country = Institution.find_by_id_feed(feed_country_id)
          arrangement.beneficiary_countries << country unless country.nil?
        end

        # Saving Arrangement
        arrangement.save

        # action-category (Arrangement)
        if feed_arrangement['action_category'].nil?
          feed_action_categories = []
        else
          feed_action_categories = feed_arrangement['action_category']
          feed_action_categories = [feed_action_categories] unless feed_action_categories.kind_of?(Array)
        end

        feed_action_categories.each do |feed_action_category|
          ActionCategory.find_or_create_by_name_and_arrangement_id(feed_action_category, arrangement.id)
        end

        # phases (Arrangement)
        if feed_arrangement['phase'].nil?
          feed_phases = []
        else
          feed_phases = feed_arrangement['phase']
          feed_phases = [feed_phases] unless feed_phases.kind_of?(Array)
        end

        feed_phases.each do |feed_phase|
          Phase.find_or_create_by_name_and_arrangement_id(feed_phase, arrangement.id)
        end

        # Entry successfully imported
        Import.create({last_entry_id: entry['id'], tag: 'arrangements'})
      end

      # Getting the next document (page)
      feed_links = reddplusdatabase.parsed_response['feed']['link']
      next_archive_link = feed_links.select { |link| link['rel'] == 'next-archive' }.first
      if next_archive_link
        next_archive = next_archive_link['href']
      else
        current_link = feed_links.select { |link| link['rel'] == 'current' }.first
        next_archive = current_link['href'] if current_link && current_link['href'] == 'https://partner.reddplusdatabase.org/api/atom/v2/arrangements'
      end

      reddplusdatabase = Feed.get(next_archive)

    end while next_archive_link || current_link

    # Cache the conditional get headers if everything went right
    Import.create({date: conditional_get_headers['If-Modified-Since'], etag: conditional_get_headers['If-None-Match'], tag: 'arrangements'})
  end

  desc "Download all the institutions"
  task :feed_institutions => :environment do
    next_archive = 'https://partner.reddplusdatabase.org/api/atom/v2/institutions'

    # Get cached headers for conditional get
    import = Import.where('date IS NOT NULL AND etag IS NOT NULL AND tag = \'institutions\'').order('created_at DESC').first

    headers = { 'If-Modified-Since' => import.date, 'If-None-Match' => import.etag }  unless import.nil?
    reddplusdatabase = Feed.get(next_archive, { headers: (headers  if defined? headers) })

    # Exit if not modified...
    unless reddplusdatabase.headers['etag']
      puts "There are no new changes on Institutions..."
      next
    end

    # Store conditional get headers
    conditional_get_headers = { 'If-Modified-Since' => reddplusdatabase.headers['date'], 'If-None-Match' => reddplusdatabase.headers['etag'] }

    # Find the last successfully imported entry from feed
    found_entry, last_page = false, false
    begin
      db = reddplusdatabase.parsed_response['feed']['entry']
      db = [db] unless db.kind_of?(Array)

      db.each do |entry|
        import = Import.where('last_entry_id IS NOT NULL AND tag = \'institutions\'').order('created_at DESC').first
        found_entry = (import.try(:last_entry_id) == entry['id'])
      end

      unless found_entry
        # Getting the prev document (page)
        prev_archive_link = reddplusdatabase.parsed_response['feed']['link'].select { |link| link['rel'] == 'prev-archive' }.first

        if prev_archive_link
          next_archive = prev_archive_link['href']
          reddplusdatabase = Feed.get(next_archive)
        else
          last_page = true
        end
      end
    end until found_entry || last_page

    # Auxiliar variable to know if we should import all the entries (if 'last_page == true' that means we have to import everything)
    reverse_found_entry = last_page

    # Get All the Documents (pages)
    begin
      # Debug
      puts "Current page: #{next_archive}"

      db = reddplusdatabase.parsed_response['feed']['entry']
      db = [db] unless db.kind_of?(Array)

      # Loop All the Entries
      db.reverse_each do |entry|
        unless reverse_found_entry
          import = Import.where('last_entry_id IS NOT NULL AND tag = \'institutions\'').order('created_at DESC').first
          reverse_found_entry = (import.try(:last_entry_id) == entry['id'])
          next
        end

        # Debug
        puts "#{entry['id']}: #{entry['title']}"

        events = entry['category']
        events = [events] unless events.kind_of?(Array)
        events = events.select { |category| category['scheme'] == 'https://partner.reddplusdatabase.org/api/category/event' }.map { |event| event['__content__'] } 

        # Delete operation
        if events.include?('DELETE')
          institution_id = entry['content']['institution_id']['__content__']

          institution = Institution.find_by_id_feed(institution_id)
          institution.destroy unless institution.nil?

          # Done. Next please!
          next
        end

        feed_institution = entry['content']['institution']

        # Institution
        institution = Institution.find_or_initialize_by_id_feed(feed_institution['id'])
        institution.attributes = {
          acronym: feed_institution['acronym'],
          name: feed_institution['name'],
          institution_type: feed_institution['type'],
          iso2: feed_institution['iso2']
        }

        # Saving Institution
        institution.save

        # Entry successfully imported
        Import.create({last_entry_id: entry['id'], tag: 'institutions'})
      end

      # Getting the next document (page)
      feed_links = reddplusdatabase.parsed_response['feed']['link']
      next_archive_link = feed_links.select { |link| link['rel'] == 'next-archive' }.first
      if next_archive_link
        next_archive = next_archive_link['href']
      else
        current_link = feed_links.select { |link| link['rel'] == 'current' }.first
        next_archive = current_link['href'] if current_link && current_link['href'] == 'https://partner.reddplusdatabase.org/api/atom/v2/institutions'
      end

      reddplusdatabase = Feed.get(next_archive)

    end while next_archive_link || current_link

    # Cache the conditional get headers if everything went right
    Import.create({date: conditional_get_headers['If-Modified-Since'], etag: conditional_get_headers['If-None-Match'], tag: 'institutions'})
  end

  desc "Download all the profiles"
  task :feed_profiles => :environment do
    next_archive = 'https://partner.reddplusdatabase.org/api/atom/v2/profiles'

    # Get cached headers for conditional get
    import = Import.where('date IS NOT NULL AND etag IS NOT NULL AND tag = \'profiles\'').order('created_at DESC').first

    headers = { 'If-Modified-Since' => import.date, 'If-None-Match' => import.etag }  unless import.nil?
    reddplusdatabase = Feed.get(next_archive, { headers: (headers  if defined? headers) })

    # Exit if not modified...
    unless reddplusdatabase.headers['etag']
      puts "There are no new changes on Profiles..."
      next
    end

    # Store conditional get headers
    conditional_get_headers = { 'If-Modified-Since' => reddplusdatabase.headers['date'], 'If-None-Match' => reddplusdatabase.headers['etag'] }

    # Find the last successfully imported entry from feed
    found_entry, last_page = false, false
    begin
      db = reddplusdatabase.parsed_response['feed']['entry']
      db = [db] unless db.kind_of?(Array)

      db.each do |entry|
        import = Import.where('last_entry_id IS NOT NULL AND tag = \'profiles\'').order('created_at DESC').first
        found_entry = (import.try(:last_entry_id) == entry['id'])
      end

      unless found_entry
        # Getting the prev document (page)
        prev_archive_link = reddplusdatabase.parsed_response['feed']['link'].select { |link| link['rel'] == 'prev-archive' }.first

        if prev_archive_link
          next_archive = prev_archive_link['href']
          reddplusdatabase = Feed.get(next_archive)
        else
          last_page = true
        end
      end
    end until found_entry || last_page

    # Auxiliar variable to know if we should import all the entries (if 'last_page == true' that means we have to import everything)
    reverse_found_entry = last_page

    # Get All the Documents (pages)
    begin
      # Debug
      puts "Current page: #{next_archive}"

      db = reddplusdatabase.parsed_response['feed']['entry']
      db = [db] unless db.kind_of?(Array)

      # Loop All the Entries
      db.reverse_each do |entry|
        unless reverse_found_entry
          import = Import.where('last_entry_id IS NOT NULL AND tag = \'profiles\'').order('created_at DESC').first
          reverse_found_entry = (import.try(:last_entry_id) == entry['id'])
          next
        end

        # Debug
        puts "#{entry['id']}: #{entry['title']}"

        events = entry['category']
        events = [events] unless events.kind_of?(Array)
        events = events.select { |category| category['scheme'] == 'https://partner.reddplusdatabase.org/api/category/event' }.map { |event| event['term'] } 

        # Delete operation
        if events.include?('DELETE')
          profile_id = entry['content']['profile_id']

          profile = Profile.find_by_id_feed(profile_id)
          profile.destroy unless profile.nil?

          # Done. Next please!
          next
        end

        feed_profile = entry['content']['profile']

        # Profile
        profile = Profile.find_or_initialize_by_id_feed(feed_profile['id'])
        profile.attributes = {
          institution: Institution.find_or_initialize_by_id_feed(feed_profile['institution_id'])
        }

        profile.save

        # Loop through focal points and save
        focal_points = feed_profile['focal_point']
        focal_points = [focal_points]  unless focal_points.kind_of?(Array)

        # No IDs to match this with, and indexing by name seems like a
        # bad idea?
        focal_points.each do |point|
          point = FocalPoint.create(
            name: point.try(:[],:name),
            email: point.try(:[],:email),
            position: point.try(:[],:position),
            institution: point.try(:[],:institution),
            address: point.try(:[],:address),
            phone: point.try(:[],:phone),
            fax: point.try(:[],:fax),
            preferred: point.try(:[],:preferred))

          point.save

          profile.focal_points << point
        end

        # Saving Profile
        profile.save

        # Entry successfully imported
        Import.create({last_entry_id: entry['id'], tag: 'profiles'})
      end

      # Getting the next document (page)
      feed_links = reddplusdatabase.parsed_response['feed']['link']
      next_archive_link = feed_links.select { |link| link['rel'] == 'next-archive' }.first
      if next_archive_link
        next_archive = next_archive_link['href']
      else
        current_link = feed_links.select { |link| link['rel'] == 'current' }.first
        next_archive = current_link['href'] if current_link && current_link['href'] == 'https://partner.reddplusdatabase.org/api/atom/v2/profiles'
      end

      reddplusdatabase = Feed.get(next_archive)

    end while next_archive_link || current_link

    # Cache the conditional get headers if everything went right
    Import.create({date: conditional_get_headers['If-Modified-Since'], etag: conditional_get_headers['If-None-Match'], tag: 'profiles'})
  end
end
