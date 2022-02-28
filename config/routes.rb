Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"
  post "contacts", to: "pages#contact", as: :contact
  get "search", to: "pages#search", as: :search
end
