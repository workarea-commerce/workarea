module Workarea
  module Configuration
    module HeadlessChrome
      extend self

      # TODO v3.5
      #
      # Allow apps to configure both Chrome options and arguments separately, as
      # any given release to Chrome may require changing these separately.
      #
      def load
        Workarea.config.headless_chrome_args = Workarea.config.headless_chrome_options
      end

      def options
        default_options.merge(env_options)
      end

      def default_options
        { args: args, w3c: false }
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
end
