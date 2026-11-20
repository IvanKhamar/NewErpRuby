Rails.application.routes.draw do
  # JSON API: the reference contract's paths (docs/openapi.json) at the root; the Ruby code lives in Api::V1.
  scope module: "api/v1", defaults: { format: :json } do
    get "health", to: "health#show", defaults: { format: :text }

    scope "auth", controller: :auth do
      post "login"
      post "logout"
      get "me"
      post "change-password", action: :change_password
    end

    scope "orders", controller: :orders do
      get "", action: :index
      post "", action: :create
      get "statuses"
      get "sources"
      get "managers"
      get ":id", action: :show, constraints: { id: /\d+/ }
      put ":id/status", action: :change_status
      get ":id/credits", action: :credits
      post ":id/reward", action: :add_reward
      delete ":id/reward", action: :remove_reward
    end

    scope "stock", controller: :stock do
      get "categories"
      get "items"
      post "items", action: :create
      get "items/:id", action: :show
      post "items/:id/adjustments", action: :adjust
      get "items/:id/movements", action: :movements
    end

    scope "production", controller: :production do
      get "models"
      get "models/:id", action: :show
      post "models/:id/:operation", action: :operation, constraints: { operation: /cut|to-sewing|sewn|ship/ }
      put "components/:id/bom", action: :component_bom
      put "models/:id/sewn-bom", action: :sewn_bom
    end
  end

  # Admin pages (HTML, Turbo) at /app, like the web interfaces of the other versions.
  namespace :admin, path: "app" do
    root "orders#index"
    resource :session, only: %i[new create destroy]
    resources :orders, only: %i[index show] do
      patch :status, on: :member
    end
    resources :stock_items, path: "stock", only: %i[index show] do
      post :adjustments, on: :member
    end
    resources :production_models, path: "production", only: %i[index show] do
      post :operations, on: :member
    end
  end

  root to: redirect("/app")
end
