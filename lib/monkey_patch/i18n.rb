module I18n
  module Base
    def config
      Ractor.current[:i18n_config] ||= I18n::Config.new
    end

    def config=(value)
      Ractor.current[:i18n_config] = value
    end
  end

  class Config
    def default_locale
      @default_locale ||= :en
    end
  end
end
