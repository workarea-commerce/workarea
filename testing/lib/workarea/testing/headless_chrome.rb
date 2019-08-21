module Workarea
  module HeadlessChrome
    extend self

    def options
      Workarea.config.headless_chrome_options.merge(env_options).merge(args: args)
    end

    def env_options
      parsed = if ENV['WORKAREA_HEADLESS_CHROME_OPTIONS'].blank?
        {}
      else
        JSON.parse(ENV['WORKAREA_HEADLESS_CHROME_OPTIONS'])
      end

      parsed.symbolize_keys
    end

    def args
      (Workarea.config.headless_chrome_args + env_args).uniq
    end

    def env_args
      ENV['WORKAREA_HEADLESS_CHROME_ARGS'].to_s.split
    end
  end
end
