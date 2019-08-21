module Workarea
  class Content
    class Fieldset
      include AssetLookup

      attr_reader :fields
      attr_accessor :field_suffix, :name

      def initialize(name)
        @name = name
        @fields = []
      end

      def field(name, type, options = {})
        name = [name, field_suffix].join if field_suffix.present?

        klass = if type.is_a?(Class)
                  type
                else
                  "Workarea::Content::Fields::#{type.to_s.camelize}".constantize
                end

        if existing = @fields.detect { |f| f.name == name }
          existing.options.merge!(options)
        else
          @fields << klass.new(name, options)
        end
      end
    end
  end
end
