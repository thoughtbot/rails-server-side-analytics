Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"
  post "contacts", to: "pages#contact", as: :contact
  get "search", to: "pages#search", as: :search
  post "sign_up", to: "pages#sign_up", as: :sign_up
  post "sign_in", to: "pages#sign_in", as: :sign_in
  post "enable_analytics", to: "analytics#enable", as: :enable_analytics
end
