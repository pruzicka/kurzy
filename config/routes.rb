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

  get "/login", to: "login#show", as: :login

  resources :courses, only: %i[index show]

  namespace :user, path: "user", module: "user_area" do
    root "dashboard#show"
  end

  namespace :admin, module: "admin_area", path: "admin" do
    root "dashboard#show"

    resources :courses do
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
          end
        end
      end
    end
  end

  post "/auth/:provider/callback", to: "user_sessions#create"
  get "/auth/:provider/callback", to: "user_sessions#create"
  get "/auth/failure", to: "user_sessions#failure"

  delete "/logout", to: "user_sessions#destroy", as: :logout
end
