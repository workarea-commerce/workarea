module Workarea
  module Configuration
    class AdministrableOptions < ActiveSupport::InheritableOptions
      def method_missing(name, *args)
        static_config = super
        return static_config if static_config.present? || static_config.to_s == 'false'
        return static_config unless check_fieldsets?(name)

        Configuration::Admin.instance.send(name)
      end

      def respond_to_missing?(name, include_private)
        true
      end

      private

      def check_fieldsets?(name)
        ::Mongoid.clients.any? &&
          Configuration::Admin.fields.keys.include?(name.to_s)
      end
    end
  end
end
