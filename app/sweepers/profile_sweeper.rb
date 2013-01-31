class ProfileSweeper < ActionController::Caching::Sweeper
  observe Profile

  def after_create(profile)
    expire_cache_for(profile)
  end

  def after_update(profile)
    expire_cache_for(profile)
  end

  def after_destroy(profile)
    expire_cache_for(profile)
  end

  private
  def expire_cache_for(profile)
    @controller ||= ActionController::Base.new

    # Overview#index root_path
    expire_page '/index.html'
    expire_page '/by/funders'
    expire_page '/by/recipients'

    # Arrangement#show
    profile.arrangements.each do |arrangement|
      expire_page "/arrangements/#{arrangement.to_param}"
    end
  end
end
