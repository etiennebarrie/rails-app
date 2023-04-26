Rails.application.routes.draw do
  root "encrypted#index"
  post "verify", to: "encrypted#create", as: :verify
end
