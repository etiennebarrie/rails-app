# frozen_string_literal: true

# Production-like environment serving requests from Ractor workers, with the
# Ractor-compatible settings from railties' ractors_test.
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store
  config.public_file_server.enabled = false
  config.logger = ActiveSupport::Ractors::Logger.new(STDOUT)
  config.log_level = :info
  config.secret_key_base = "ractor-demo-not-a-secret"
  config.active_support.report_deprecations = true
end

ActiveSupport::Ractors.unshareable_proc_action = :raise

# i18n's fallbacks still live in a class variable, which non-main Ractors
# cannot read.
I18N_RACTOR_FALLBACKS = Ractor.make_shareable({ en: [:en] })
def I18n.fallbacks = I18N_RACTOR_FALLBACKS
