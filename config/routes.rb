Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'root#index'

  get "path-generation/:thing", to: "root#index", as: :path_generation
  get "path-generation-splat/*thing", to: "root#index", as: :path_generation_splat
end
