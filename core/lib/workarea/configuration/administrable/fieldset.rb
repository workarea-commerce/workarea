module Workarea
  module Configuration
    module Administrable
      class Fieldset
        attr_accessor :fields, :id, :description

        def initialize(id, name: nil, namespaced: true)
          @id = id.to_s.systemize.to_sym
          @name = name
          @namespaced = namespaced
          @fields = SwappableList.new
        end

        def name
          @name.presence || id.to_s.titleize
        end

        def namespaced?
          @namespaced
        end

        def description(value = nil)
          @description ||= value
        end

        def field(id, type: nil, override: false, **options)
          field = Field.new(id, fieldset: self, type: type, **options)
          existing = find_field(field.id)

          if existing.present? && override
            @fields.swap(existing, field.validate!)
          elsif existing.present?
            existing.merge!(options)
            existing.validate!
          else
            @fields.push(field.validate!)
          end

          return unless field.encrypted?
          Rails.application.config.filter_parameters << field.key
        end

        def find_field(id)
          @fields.detect { |field| field.id == id.to_sym }
        end
      end
    end
  end
end
