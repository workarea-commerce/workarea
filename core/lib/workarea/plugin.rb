module Workarea
  module Plugin
    extend ActiveSupport::Concern

    mattr_accessor :installed
    self.installed ||= []

    mattr_accessor :stylesheets_appends, :javascripts_appends, :partials_appends
    self.stylesheets_appends ||= {}
    self.javascripts_appends ||= {}
    self.partials_appends ||= {}

    def self.installed?(search)
      searches = installed +
        installed.map(&:to_s) +
        installed.map(&:to_s).map(&:demodulize) +
        installed.map(&:slug)

      searches.include?(search.to_s)
    end

    def self.skip_appends(appends, config)
      return {} if appends.blank?
      return appends if config.blank?

      Array.wrap(config).each do |line|
        if line.respond_to?(:call)
          appends = appends.reject { |path| line.call(path) }
        elsif line.is_a?(String)
          appends = appends - [line]
        elsif line.is_a?(Regexp)
          appends = appends.reject { |path| line =~ path }
        end
      end

      appends
    end

    def self.add_append(hash, key, *paths)
      hash[key] ||= []
      hash[key].push(*paths)
    end

    def self.remove_append(hash, key, *paths)
      hash[key] ||= []
      hash[key].reject! { |path| paths.include?(path) }
    end

    def self.append_stylesheets(*args)
      add_append(stylesheets_appends, *args)
    end

    def self.append_javascripts(*args)
      add_append(javascripts_appends, *args)
    end

    def self.append_partials(*args)
      add_append(partials_appends, *args)
    end

    def self.remove_stylesheets(*args)
      remove_append(stylesheets_appends, *args)
    end

    def self.remove_javascripts(*args)
      remove_append(javascripts_appends, *args)
    end

    def self.remove_partials(*args)
      remove_append(partials_appends, *args)
    end

    included do
      extend Workarea::MountPoint

      mod = self.to_s.gsub('::Engine', '').constantize

      def mod.slug
        self.to_s.gsub('Workarea::', '').underscore
      end

      def mod.homebase_name
        self.to_s.gsub('Workarea::', '').gsub('::', ' ').titleize
      end

      # TODO is there any code we can cleanup now that this exists?
      def mod.root
        self.const_get(:Engine).root
      end

      def mod.version
        unless const_defined?(:VERSION, false)
          begin
            require root.join('lib', 'workarea', slug, 'version').to_s
          rescue LoadError
            # Version file not in correct dir
          end
        end

        if const_defined?(:VERSION, false)
          const_get(:VERSION, false)
        else
          "0.0.0"
        end
      end

      Workarea::Plugin.installed.append(mod)

      %w(app/services app/view_models app/workers).each do |path|
        config.autoload_paths << "#{root}/#{path}"
        config.eager_load_paths << "#{root}/#{path}"
      end

      engine = self
    end
  end
end
