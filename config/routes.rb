Vrdb::Application.routes.draw do
  match '/by/:reported_by' => 'overview#index', as: :reported_by

  match 'about' => 'static#about'
  match 'contact' => 'static#contact'
  match 'download' => 'static#download'
  match 'faq' => 'static#faq'
  match 'glossary' => 'static#glossary'
  match 'submit' => 'static#submit'
  match 'terms' => 'static#terms'
  match 'resources' => 'static#resources'
  match 'guide' => 'static#guide'

  resources :arrangements, only: [:index, :show]

  match 'countries' => 'entities#countries'
  match 'institutions' => 'entities#institutions'

  match 'entities/:id/by/:reported_by' => 'entities#show', as: :entity_reported_by
  resources :entities, only: [:show] do
    member do
      get 'funders_and_recipients'
      get 'arrangement_totals'
      get 'arrangement_totals_with_indirect'
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'overview#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
