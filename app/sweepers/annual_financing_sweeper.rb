class AnnualFinancingSweeper < ActionController::Caching::Sweeper
  observe AnnualFinancing

  def after_create(annual_financing)
    expire_cache_for(annual_financing)
  end

  def after_update(annual_financing)
    expire_cache_for(annual_financing)
  end

  def after_destroy(annual_financing)
    expire_cache_for(annual_financing)
  end

  private
  def expire_cache_for(annual_financing)
    @controller ||= ActionController::Base.new

    # Overview#index root_path
    expire_page '/index.html'
    expire_page '/by/funders'
    expire_page '/by/recipients'

    # Arrangement#show
    expire_page "/arrangements/#{annual_financing.arrangement.to_param}"
  end
end
