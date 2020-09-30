module Workarea
  module Configuration
    class AdministrableOptions < ActiveSupport::InheritableOptions
      def [](name)
        static_config = super
        return static_config if static_config.present? || static_config.to_s == 'false'
        return static_config unless check_fieldsets?(name)

        Configuration::Admin.instance.send(name)
      end

      private

      def check_fieldsets?(name)
        !Workarea.skip_services? &&
          ::Mongoid.clients.any? &&
          Configuration::Admin.fields.keys.include?(name.to_s)
      end
    end
  end
end
