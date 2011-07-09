Scs::Application.routes.draw do

  devise_for :gods

  devise_for :admins

  resources :accounts

  resources :all_orders, :only => [] do
    collection do
      post 'generate'
    end
  end

  resources :attachments do
    member do
      get 'download'
    end
  end

  resources :locations

  resources :settings

  resources :counts

  resources :checks do
    collection do
      put 'refresh_count', 'color_update', 'generate', 'upload_ins'
      get 'color', 'reimport', 'to_generate', 'instruction'
    end

    member do
      put 'make_current'
    end

    resources :reports, :only => [] do
      collection do
        get 'count_varience', 'count_frozen', 'tags', 'inventories'
      end
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


  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  namespace :audit do
    resources :tags
  end

  namespace :dataentry do
    resources :inventories
    resources :items do
      resources :inventories
    end
  end

  namespace :god do
    resources :rechecks

    resources :checks do
      resources :activities
      resources :tags
      resources :inventories
      
      collection do
        get 'current', 'history', 'import_cost'
        put 'do_import_cost'
      end

      put 'change_state', :on => :member
    end
  end

  namespace :adm do
    # Directs /admin/products/* to Admin::ProductsController
    # (app/controllers/admin/products_controller.rb)
    resources :wait_prints

    resources :items do
      resources :tags

      get 'missing_cost', :on => :collection

      member do
        get 'input_price'
        put 'update_price'
      end
    end

    resources :tags do
      get 'adj_list', :on => :collection

      member do
        get 'to_adj'
        put 'update_adj'
      end
    end

    resources :counters

    resources :items do
      resources :inventories, :only => [:new, :create]
    end

    resources :inventories do
      resources :tags
    end

    resources :counts do
      get 'missing_tag', 'result', :on => :collection
    end

    resources :locations do
      resources :assigns
    end
  end

  root :to => "dashboards#show"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
