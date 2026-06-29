Rails.application.routes.draw do
  # Mime registry storage benchmark endpoints (see benchmarks/mime_storage.rb).
  get "bench/plain"     => "bench#plain"
  get "bench/template"  => "bench#template"
  get "bench/negotiate" => "bench#negotiate"
  get "bench/json"      => "bench#json_negotiate"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
