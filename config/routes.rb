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
      get "stocktaking/sheet.xlsx", action: :stocktaking_sheet, format: false
      post "stocktaking/preview", action: :stocktaking_preview
      post "stocktaking", action: :apply_stocktaking
    end

    # New module (not in the reference contract): refunds with a recipient check.
    post "refunds/recipient-checks", to: "refunds#check_recipient"
    get "refunds/recipient-checks", to: "refunds#checks"
    post "refunds", to: "refunds#create"

    get "reports/sales", to: "reports#sales"
    get "catalog/faq", to: "faq#index"
    post "catalog/faq", to: "faq#create"
    put "catalog/faq/:id", to: "faq#update"
    # Anonymous on purpose: the partner's site downloads its feed by the partner code, as on the old site.
    get "feeds/:code.xml", to: "feeds#partner", format: false, defaults: { format: :xml }

    scope "production", controller: :production do
      get "models"
      get "models/:id", action: :show
      post "models/:id/:operation", action: :operation, constraints: { operation: /cut|to-sewing|sewn|ship/ }
      put "components/:id/bom", action: :component_bom
      put "models/:id/sewn-bom", action: :sewn_bom
    end

    scope "preorders", controller: :pre_orders do
      get "", action: :index
      post "settle"
      put ":id", action: :update
    end

    scope "competitors", controller: :competitors do
      get "", action: :index
      post "", action: :create
      get "links"
      post "links", action: :add_link
      post "check"
    end

    post "delivery/tracking/refresh", to: "delivery#refresh_tracking"

    scope "orders/:id", constraints: { id: /\d+/ } do
      post "liqpay-link", to: "payments#liqpay_link"
      get "liqpay-status", to: "payments#liqpay_status"
      get "sms", to: "order_integrations#sms_history"
      post "sms", to: "order_integrations#send_sms"
      post "shipment/international", to: "order_integrations#international_shipment"
    end
    get "payments/bank", to: "payments#bank"
    post "payments/bank/import", to: "payments#import_bank"
    post "cashbox/cheques/:id/fiscalize", to: "cashbox#fiscalize"
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

  # The React app (phase 7): client-side routes all get its index.html.
  get "ui(/*path)", to: "ui#show", format: false

  root to: redirect("/app")
end
