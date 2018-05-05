Rails.application.routes.draw do
    get 'calculator/operate'
    resources :calculator
    root to: "calculator#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
