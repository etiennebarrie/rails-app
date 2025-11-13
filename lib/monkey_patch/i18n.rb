module I18n
  def self.fallbacks
    Ractor.current[:i18n_fallbacks] ||= I18n::Locale::Fallbacks.new
  end

  module Locale
    module Tag
      class << self
        # Returns the current locale tag implementation. Defaults to +I18n::Locale::Tag::Simple+.
        def implementation
          @implementation ||= Simple
        end

        def implementation=(implementation)
          @implementation = implementation
        end
      end
    end
  end

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
