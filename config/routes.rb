Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v10 do
    scope module: 'account' do
      post 'login', to: 'sessions#create', as: :login
      post 'logout', to: 'sessions#destroy', as: :logout
      post 'register', to: 'accounts#create', as: :register
    end

    namespace :account do
      resource :reset_password, only: [:create]
      resource :v_codes, only: [:create]
      resource :verify_vcode, only: [:create]
      resource :test_user, only: [:show]
      resources :users, only: [] do
        resource :profile, only: [:show, :update]
        resource :change_password, only: [:create]
        resource :change_permission, only: [:create]
        resources :address, only: [:index, :create] do
          scope module: 'address' do
            resources :default, only: [:create]
            resources :delete, only: [:create]
          end
        end
        resources :certification, only: [:index, :create]
        namespace :certification do
          resources :delete, only: [:create]
          resources :default, only: [:create]
        end
        resources :change_account, only: [:create]
        resources :bind_account, only: [:create]
      end
      get ':account/verify', to: 'verify#index', as: :verify
    end

    scope module: 'races' do
      resources :u, only:[] do
        get 'races/search_by_keyword', to:'search_by_keyword#index', as: :search_by_keyword
        get 'races/search_range_list', to:'search_range_list#index', as: :search_range_list
        resources :races, only: [:index, :show]
        get 'recent_races', to: 'recent_races#index', as: :recent_races
      end
      resources :races, only: [] do
        # get 'new_order', to: 'orders#new_order', as: :new_order   废弃
        resources :sub_races, only: [:index, :show]
        resources :race_ranks, only: [:index]
        resources :tickets, only: [:index, :show] do
          resource :orders, only: [:create]
          resource :unpaid_order, only: [:show]
        end
      end
      resources :race_tickets, only: [:index], as: :ticket_business
    end

    scope module: 'users' do
      resources :users, only: :show do
        resources :notifications, only: [:index, :destroy] do
          get 'unread_remind', on: :collection
          post 'read', on: :member
        end
        resources :followed_players, only: [:index]
        resources :login_count, only: [:create]
      end
    end

    scope module: 'orders' do
      resources :users, only: [] do
        resources :orders, only: [:index, :show] do
          resources :cancel, only: [:create]
          resources :complete, only: [:create]
          resources :pay, only: [:create]
          resources :wx_pay, only: [:create]
        end
        resources :verify_invite_code, only: [:create]
      end
    end

    namespace :uploaders do
      resources :avatar, only:[:create]
      resources :card_image, only:[:create]
    end

    scope module: 'players' do
      resources :players, only: [:show, :index] do
        resources :ranks, only: [:index]
        resource :follow
      end
    end

    namespace :news do
      resources :types, only: [:index, :show]
      resources :search, only: [:index]
      resources :infos, only: [:show]
      resources :videos, only: [:show]
    end

    namespace :videos do
      resources :types, only: [:index, :show] do
        resources :main_lists, only: [:index]
      end
      resources :group, only: [] do
        resources :sub_videos, only: [:index]
      end
      resources :search, only: [:index]
      resources :search_main_videos, only: [:index]
    end

    namespace :weixin do
      resources :auth, only: [:create]
      resources :bind, only: [:create]
      resources :js_sign, only: [:create]
    end

    namespace :pay do
      # resources :test, only: [:index, :create] # 废弃
      resources :notify_url, only: [:index, :create]
      resources :return_url, only: [:index, :create]
      resources :wx_notify, only: [:create]
      resources :wx_shop_order_notify, only: [:create]
    end

    scope module: :homepage do
      resources :banners, only: [:index]
      resources :headlines, only: [:index]
      resources :hot_infos, only: [:index]
    end

    resources :app_versions, only:[:index]
    resources :race_hosts, only:[:index]
    resources :feedbacks, only: [:create]
    resources :activities, only: [:index, :show] do
      get 'pushed', on: :collection
    end

    scope module: :shop do
      resources :categories, only: [:index] do
        get 'children', on: :member
        get 'products', on: :member
      end

      resources :products
      resources :recommended_products, only:[:index]
    end

    scope module: 'shop_orders' do
      resources :product_orders do
        post 'new', on: :collection
        resources :wx_pay, only: [:create]
        resources :cancel, only: [:create]
      end
    end
  end

  unless Rails.env.production?
    namespace :factory do
      get '/clear', to: 'application#clear'
      get '/:ac', to: 'application#create'
    end
  end
end
