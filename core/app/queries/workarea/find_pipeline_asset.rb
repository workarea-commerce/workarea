module Workarea
  class FindPipelineAsset
    def initialize(name, path: nil)
      @name = name
      @path = path || %w(app assets images workarea core)
    end

    def path
      host_app_path = Rails.root.join(*@path, @name)
      return host_app_path if host_app_path.exist?
      return plugin_path unless plugin_path.nil?

      Core::Engine.root.join(*@path, @name)
    end

    private

    def plugin_path
      return unless plugin.present?

      plugin.root.join(*@path, @name)
    end

    def plugin
      @plugin ||= Plugin.installed.find do |plugin|
        plugin.root.join(*@path, @name).exist?
      end
    end
  end
end
