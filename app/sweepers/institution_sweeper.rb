class InstitutionSweeper < ActionController::Caching::Sweeper
  observe Institution

  def after_create(institution)
    expire_cache_for(institution)
  end

  def after_update(institution)
    expire_cache_for(institution)
  end

  def after_destroy(institution)
    expire_cache_for(institution)
  end

  private
  def expire_cache_for(institution)
    @controller ||= ActionController::Base.new

    # Overview#index root_path
    expire_page '/index.html'
    expire_page '/by/funders'
    expire_page '/by/recipients'

    # Entities#show
    expire_page "/entities/#{institution.to_param}"
    expire_page "/entities/#{institution.to_param}/by/self"
    expire_page "/entities/#{institution.to_param}/by/others"

    # Entities#countries
    expire_page "/countries"

    # Entities#institutions
    expire_page "/institutions"
  end
end
