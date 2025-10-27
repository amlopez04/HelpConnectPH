Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    registrations: "users/registrations"
  }

  # Email preview (development only)
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # Dashboard (role-based)
  get "/dashboard", to: "dashboards#show", as: "dashboard"

  # ============================================
  # REPORTS (All CRUD operations)
  # ============================================
  get    "/reports",          to: "reports#index",   as: "reports"
  get    "/reports/new",      to: "reports#new",     as: "new_report"
  post   "/reports",          to: "reports#create"
  get    "/reports/:id",      to: "reports#show",    as: "report"
  get    "/reports/:id/edit", to: "reports#edit",    as: "edit_report"
  patch  "/reports/:id",      to: "reports#update"
  delete "/reports/:id",      to: "reports#destroy"
  post   "/reports/:id/approve", to: "reports#approve", as: "approve_report"
  post   "/reports/:id/reject",  to: "reports#reject",  as: "reject_report"
  post   "/reports/:id/request_reopen", to: "reports#request_reopen", as: "request_reopen_report"
  post   "/reports/:id/approve_reopen", to: "reports#approve_reopen", as: "approve_reopen_report"

  # ============================================
  # COMMENTS (Nested under reports)
  # ============================================
  post   "/reports/:report_id/comments",     to: "comments#create",  as: "report_comments"
  delete "/reports/:report_id/comments/:id", to: "comments#destroy", as: "report_comment"

  # ============================================
  # CATEGORIES (Admin only - Full CRUD)
  # ============================================
  get    "/categories",          to: "categories#index",   as: "categories"
  get    "/categories/new",      to: "categories#new",     as: "new_category"
  post   "/categories",          to: "categories#create"
  get    "/categories/:id",      to: "categories#show",    as: "category"
  get    "/categories/:id/edit", to: "categories#edit",    as: "edit_category"
  patch  "/categories/:id",      to: "categories#update"
  delete "/categories/:id",      to: "categories#destroy"

  # ============================================
  # BARANGAYS (Admin only - Full CRUD)
  # ============================================
  get    "/barangays",          to: "barangays#index",   as: "barangays"
  get    "/barangays/new",      to: "barangays#new",     as: "new_barangay"
  post   "/barangays",          to: "barangays#create"
  get    "/barangays/:id",      to: "barangays#show",    as: "barangay"
  get    "/barangays/:id/edit", to: "barangays#edit",    as: "edit_barangay"
  patch  "/barangays/:id",      to: "barangays#update"
  delete "/barangays/:id",      to: "barangays#destroy"

  # ============================================
  # ADMIN - BARANGAY CAPTAIN MANAGEMENT
  # ============================================
  get  "/admin/barangay_captains/new", to: "admin/barangay_captains#new",    as: "new_admin_barangay_captain"
  post "/admin/barangay_captains",     to: "admin/barangay_captains#create", as: "admin_barangay_captains"
end
