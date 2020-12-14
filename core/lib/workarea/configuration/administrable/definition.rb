module Workarea
  module Configuration
    module Administrable
      class Definition
        attr_reader :fieldsets
        delegate :field, to: :application_fieldset

        def initialize
          @fieldsets = SwappableList.new
          @fieldsets.push(Fieldset.new('Application', namespaced: false))
        end

        def fieldset(id, name: nil, override: false, namespaced: true, &block)
          fieldset = Fieldset.new(id, name: name, namespaced: namespaced)
          existing = find_fieldset(fieldset.id)

          if override && existing.present?
            @fieldsets.swap(existing, fieldset)
            fieldset.instance_eval(&block) if block_given?
          elsif existing.present?
            existing.instance_eval(&block) if block_given?
          else
            @fieldsets.push(fieldset)
            fieldset.instance_eval(&block) if block_given?
          end
        end

        def application_fieldset
          @application_fieldset ||= find_fieldset(:application)
        end

        def find_fieldset(id)
          @fieldsets.detect { |fieldset| fieldset.id == id.to_sym }
        end

        def fields
          @fieldsets.flat_map(&:fields)
        end
      end
    end
  end
end
