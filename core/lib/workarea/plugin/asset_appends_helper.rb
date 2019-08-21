module Workarea
  module Plugin
    module AssetAppendsHelper
      def append_stylesheets(name)
        appends = Plugin.skip_appends(
          Plugin.stylesheets_appends[name],
          Workarea.config.skip_stylesheets
        )

        return '' if appends.blank?

        appends.inject([]) do |arr, paths|
          Array(paths).each do |path|
            arr << "@import '#{path}';"
          end
          arr
        end.join("\n")
      end

      def append_javascripts(name)
        appends = Plugin.skip_appends(
          Plugin.javascripts_appends[name],
          Workarea.config.skip_javascripts
        )

        return [] if appends.blank?

        appends.inject([]) do |arr, paths|
          Array(paths).each do |path|
            require_asset(path)
          end
        end
      end
    end
  end
end
