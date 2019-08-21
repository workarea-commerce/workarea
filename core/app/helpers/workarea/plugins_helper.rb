module Workarea
  module PluginsHelper
    def append_partials(name, locals = {})
      appends = Plugin.skip_appends(
        Plugin.partials_appends[name],
        Workarea.config.skip_partials
      )

      return if appends.blank?

      appends.inject([]) do |arr, paths|
        Array(paths).each do |path|
          arr << render(partial: path, locals: locals)
        end
        arr
      end.join("\n").html_safe
    end

    def partials_to_append?(name)
      Plugin.partials_appends[name].present?
    end
  end
end
