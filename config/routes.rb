IceCream::Application.routes.draw do
  root to: 'reviews#new'
  resources :reviews
end
