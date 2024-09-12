Rails.configuration.to_prepare do
  ActiveSupport.on_load(:foo) do
    puts "== ActiveSupport.on_load(:foo)"
  end
end
