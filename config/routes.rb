Rails.application.routes.draw do
  devise_for :admins,
             path: "admin",
             path_names: { sign_in: "login", sign_out: "logout" },
             skip: [:registrations]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  get "/disclaimer", to: "pages#disclaimer"
  get "/terms", to: "pages#terms"
  get "/privacy", to: "pages#privacy"
  get "/data-deletion", to: "pages#data_deletion"

  get "/login", to: "login#show", as: :login

  resource :cart, only: [:show] do
    patch :apply_coupon
    delete :remove_coupon
  end
  resources :cart_items, only: %i[create update destroy]
  resources :enrollments, only: [:destroy]
  post "/checkout", to: "checkouts#create", as: :checkout
  get "/checkout/success", to: "checkouts#success", as: :checkout_success
  get "/checkout/cancel", to: "checkouts#cancel", as: :checkout_cancel

  post "/webhooks/stripe", to: "stripe_webhooks#create"

  resources :courses, only: %i[index show] do
    resources :chapters, only: [] do
      resources :segments, only: %i[show] do
        member do
          post :complete, to: "segment_completions#create"
        end
      end

      # Auth-gated media endpoints (avoid permanent Active Storage signed routes in user-facing HTML).
      resources :segments, only: [] do
        member do
          get :video, to: "segment_media#video"
          get :cover_image, to: "segment_media#cover_image"
        end
        get "attachments/:attachment_id", to: "segment_media#attachment", as: :attachment
      end
    end
  end

  namespace :user, path: "user", module: "user_area" do
    root "dashboard#show"
    resource :settings, only: %i[edit update destroy]
    resources :oauth_identities, only: [:destroy]
    resources :user_sessions, only: [:destroy], path: "sessions" do
      delete :destroy_all_other, on: :collection, path: "other"
    end
  end

  namespace :admin, module: "admin_area", path: "admin" do
    root "dashboard#show"
    resource :profile, only: %i[edit update]

    namespace :preview, module: "preview", path: "preview" do
      resources :courses, only: %i[index show] do
        resources :chapters, only: [] do
          resources :segments, only: %i[show]
        end
      end
    end

    resources :courses do
      member do
        delete :cover_image, action: :destroy_cover_image
      end

      resources :chapters, only: %i[new create edit update destroy] do
        member do
          patch :move_up
          patch :move_down
        end

        resources :segments, only: %i[new create edit update destroy] do
          member do
            patch :move_up
            patch :move_down
            delete "attachments/:attachment_id", action: :destroy_attachment, as: :destroy_attachment
            delete "cover_image", action: :destroy_cover_image, as: :destroy_cover_image
            delete "video", action: :destroy_video, as: :destroy_video
          end
        end
      end
    end

    resources :media_assets, path: "media"
    resources :orders, only: %i[index show destroy]
    resources :users, only: %i[index show]
    resources :coupons
  end

  post "/auth/:provider/callback", to: "user_sessions#create"
  get "/auth/:provider/callback", to: "user_sessions#create"
  get "/auth/failure", to: "user_sessions#failure"

  delete "/logout", to: "user_sessions#destroy", as: :logout
end
