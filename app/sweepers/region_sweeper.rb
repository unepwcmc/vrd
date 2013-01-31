class RegionSweeper < ActionController::Caching::Sweeper
  observe Region

  def after_create(region)
    expire_cache_for(region)
  end

  def after_update(region)
    expire_cache_for(region)
  end

  def after_destroy(region)
    expire_cache_for(region)
  end

  private
  def expire_cache_for(region)
    @controller ||= ActionController::Base.new

    # Overview#index root_path
    expire_page '/index.html'
    expire_page '/by/funders'
    expire_page '/by/recipients'

    # Arrangement#show
    region.institutions.map(&:beneficiary_arrangements).flatten.uniq.each do |arrangement|
      expire_page "/arrangements/#{arrangement.to_param}"
    end
  end
end
