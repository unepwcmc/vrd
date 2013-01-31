class ActionCategorySweeper < ActionController::Caching::Sweeper
  observe ActionCategory

  def after_create(action_category)
    expire_cache_for(action_category)
  end

  def after_update(action_category)
    expire_cache_for(action_category)
  end

  def after_destroy(action_category)
    expire_cache_for(action_category)
  end

  private
  def expire_cache_for(action_category)
    @controller ||= ActionController::Base.new

    # Overview#index root_path
    expire_page '/index.html'
    expire_page '/by/funders'
    expire_page '/by/recipients'

    # Arrangement#show
    expire_page "/arrangements/#{action_category.arrangement.to_param}"
  end
end
