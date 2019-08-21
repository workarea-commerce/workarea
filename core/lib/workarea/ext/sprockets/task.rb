require 'sprockets/rails/task'

module Sprockets
  module Rails
    module Workarea
      # This is required because when precompiling assets in a deployed env
      # like staging or production, Rails.application.assets will be nil
      # because Rails.application.config.assets.compile = false. This means
      # "don't fall back to the asset pipeline if an asset can't be found",
      # which is what we want in those environvments.
      #
      # When Rails.application.assets == nil, sprockets-rails falls back and
      # uses it's own Sprockets::Environment. Since there is no
      # Sprockets::Environment for our app to add our plugin asset appends
      # points during initialization, we must monkey patch the ad hoc creation
      # of one for these rake tasks here to get these included. PRETTY SHITTY.
      #
      def environment
        result = super

        result.context_class.instance_eval do
          include ::Workarea::Plugin::AssetAppendsHelper
        end

        result
      end
    end
  end
end

Sprockets::Rails::Task.prepend(Sprockets::Rails::Workarea)
