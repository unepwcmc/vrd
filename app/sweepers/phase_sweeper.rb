class PhaseSweeper < ActionController::Caching::Sweeper
  observe Phase

  def after_create(phase)
    expire_cache_for(phase)
  end

  def after_update(phase)
    expire_cache_for(phase)
  end

  def after_destroy(phase)
    expire_cache_for(phase)
  end

  private
  def expire_cache_for(phase)
    @controller ||= ActionController::Base.new

    # Arrangement#show
    expire_page "/arrangements/#{phase.arrangement.to_param}"
  end
end
