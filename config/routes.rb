Scs::Application.routes.draw do

  devise_for :admins

  resources :accounts

  resources :all_orders, :only => [] do
    collection do
      post 'generate'
    end
  end

  resources :attachments

  resources :locations do
    resources :assigns
  end

  resources :settings

  resources :reports, :only => [] do
    collection do
      get 'count_varience', 'final_report', 'final_frozen'
    end
  end
  

  resources :counts

  resources :checks do
    collection do
      put 'change_state', 'refresh_count', 'color_update', 'generate'
      get 'color', 'history', 'current', 'reimport', 'to_generate'
    end

    member do
      put 'make_current'
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

  namespace :adm do
    # Directs /admin/products/* to Admin::ProductsController
    # (app/controllers/admin/products_controller.rb)
    resources :items do
      resources :tags

      collection do
        get 'missing_cost'
      end

      member do
        get 'input_price'
        put 'update_price'
      end
    end

    resources :tags do
      collection do
        get 'adj_list'
      end
      member do
        get 'to_adj'
        put 'update_adj'
      end
    end

    resources :counters
    resources :inventories do
      resources :tags
    end
    
    resources :counts do
      collection do
        get 'missing_tag', 'result', 'frozen_report'
      end
    end
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "dashboards#show"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
