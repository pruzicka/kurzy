Rails.application.routes.draw do
  devise_for :admins,
             path: "admin",
             path_names: { sign_in: "login", sign_out: "logout" },
             controllers: { sessions: "admins/sessions" },
             skip: [:registrations]

  scope :admin, as: :admin do
    resource :otp_challenge, only: %i[new create], controller: "admins/otp_challenges"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "sitemap", to: "sitemaps#show", defaults: { format: :xml }, as: :sitemap

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
  get "/checkout/billing", to: "checkouts#billing", as: :checkout_billing
  post "/checkout", to: "checkouts#create", as: :checkout
  get "/checkout/success", to: "checkouts#success", as: :checkout_success
  get "/checkout/cancel", to: "checkouts#cancel", as: :checkout_cancel

  post "/webhooks/stripe", to: "stripe_webhooks#create"

  resources :authors, only: [:index], path: "autori"
  get "/autori/:slug", to: "authors#show", as: :author

  resources :subscription_plans, only: [:index], path: "predplatne"
  get "/predplatne/:slug", to: "subscription_plans#show", as: :subscription_plan
  get "/predplatne/:subscription_plan_slug/epizody/:id", to: "episodes#show", as: :subscription_plan_episode

  resources :subscription_checkouts, only: [:create], path: "predplatne-checkout"
  get "/predplatne-checkout/success", to: "subscription_checkouts#success", as: :subscription_checkout_success

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
    resources :subscriptions, only: [:index] do
      member do
        patch :cancel
        patch :resume
      end
    end
    resources :oauth_identities, only: [:destroy]
    resources :user_sessions, only: [:destroy], path: "sessions" do
      delete :destroy_all_other, on: :collection, path: "other"
    end
  end

  authenticate :admin do
    mount GoodJob::Engine, at: "admin/jobs"
  end

  namespace :admin, module: "admin_area", path: "admin" do
    root "dashboard#show"
    resource :profile, only: %i[edit update]
    resource :two_factor, only: %i[new create destroy], controller: "two_factor" do
      post :regenerate_backup_codes
    end

    namespace :preview, module: "preview", path: "preview" do
      resources :courses, only: %i[index show] do
        resources :chapters, only: [] do
          resources :segments, only: %i[show]
        end
      end
    end

    resources :authors do
      member do
        delete :profile_image, action: :destroy_profile_image
      end
    end

    resources :subscription_plans do
      member do
        delete :cover_image, action: :destroy_cover_image
      end

      resources :episodes, only: %i[new create edit update destroy] do
        member do
          patch :move_up
          patch :move_down
          delete "cover_image", action: :destroy_cover_image, as: :destroy_cover_image
          delete "media", action: :destroy_media, as: :destroy_media
          delete "video", action: :destroy_video, as: :destroy_video
          delete "audio", action: :destroy_audio, as: :destroy_audio
          delete "attachments/:attachment_id", action: :destroy_attachment, as: :destroy_attachment
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
            delete "audio", action: :destroy_audio, as: :destroy_audio
          end
        end
      end
    end

    resources :media_assets, path: "media"
    resources :orders, only: %i[index show destroy] do
      member do
        post :create_invoice
        post :resend_invoice_email
        post :refund
      end
    end
    resources :users, only: %i[index show]
    resources :coupons
    resources :tags, except: [:show]
    resources :billing_companies, path: "billing"
  end

  post "/auth/:provider/callback", to: "user_sessions#create"
  get "/auth/:provider/callback", to: "user_sessions#create"
  get "/auth/failure", to: "user_sessions#failure"

  delete "/logout", to: "user_sessions#destroy", as: :logout
end
