module Workarea
  module Configuration
    module Administrable
      class Field
        class Invalid < StandardError; end

        attr_reader :id, :type, :fieldset, :options
        delegate :default, :description, :values_type, :encrypted, to: :options

        def initialize(id, type:, fieldset: nil,  **options)
          @id = id.to_s.systemize.to_sym
          @type = type.to_s.underscore.to_sym
          @fieldset = fieldset
          @options = OpenStruct.new(options)
        end

        def name
          @name ||= (options.name || id.to_s.titleize)
        end

        def key
          @key ||= fieldset&.namespaced? ? :"#{fieldset.id}_#{id}" : id
        end

        def type_class
          Workarea.config.configurable_field_types[type]&.constantize
        end

        def values
          return options.values unless options.values.respond_to?(:call)
          options.values.call
        end

        def values_type_class
          return unless type.in?(%i(hash array))

          values_type = options.values_type || :string
          Workarea.config.configurable_field_types[values_type]&.constantize
        end

        def overridden?
          Workarea.config.key?(key)
        end

        def encrypted?
          !!encrypted
        end

        def validate!
          validate_id
          validate_type
          validate_default
          self
        end

        def required?
          return true unless @options.to_h.key?(:required)
          !!@options.required
        end

        def merge!(options = {})
          @options = OpenStruct.new(options.to_h.merge(options))
        end

        private

        def validate_id
          unless id.to_s.valid_method_name?
            raise Invalid.new("configuration field '#{name}' does not have a valid id - #{id}.")
          end
        end

        def validate_type
          unless type_class.present?
            raise Invalid.new("configuration field '#{name}' does not have a valid type - #{@type}.")
          end
        end

        def validate_default
          if required? && default.nil?
            raise Invalid.new("configuration field '#{name}' is required but doesn't have a default.")
          end
        end
      end
    end
  end
end
