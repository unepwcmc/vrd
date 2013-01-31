class ArrangementSweeper < ActionController::Caching::Sweeper
  observe Arrangement

  def after_create(arrangement)
    expire_cache_for(arrangement)
  end

  def after_update(arrangement)
    expire_cache_for(arrangement)
  end

  def after_destroy(arrangement)
    expire_cache_for(arrangement)
  end

  private
  def expire_cache_for(arrangement)
    @controller ||= ActionController::Base.new

    # Overview#index root_path
    expire_page '/index.html'
    expire_page '/by/funders'
    expire_page '/by/recipients'

    # Arrangement#show
    expire_page "/arrangements/#{arrangement.to_param}"

    # Entities#show
    expire_page "/entities/#{arrangement.reporting_institution.to_param}"
    expire_page "/entities/#{arrangement.reporting_institution.to_param}/by/self"
    expire_page "/entities/#{arrangement.reporting_institution.to_param}/by/others"

    expire_page "/entities/#{arrangement.reported_on_institution.to_param}"
    expire_page "/entities/#{arrangement.reported_on_institution.to_param}/by/self"
    expire_page "/entities/#{arrangement.reported_on_institution.to_param}/by/others"
  end
end
