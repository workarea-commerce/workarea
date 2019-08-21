module Workarea
  module Configuration
    class Admin
      include ApplicationDocument
      include ::Mongoid::Encrypted

      delegate :definition, to: :class

      def self.instance
        first || create
      end

      def self.definition
        Workarea.config.admin_definition
      end

      definition.fields.each do |f|
        field f.key,
          type: f.type_class,
          default: f.default,
          encrypted: f.encrypted?
      end
    end
  end
end
