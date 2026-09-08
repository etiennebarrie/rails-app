# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.app
Rails.application.load_server

if ENV["RAILS_ENV"] == "ractor"
  require "i18n/ractorize"
  Rails.application.ractorize!
end
