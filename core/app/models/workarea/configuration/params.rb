module Workarea
  module Configuration
    class Params
      def initialize(params)
        @params = params
      end

      def to_h
        Admin.definition.fields.each_with_object({}) do |field, memo|
          next unless @params.key?(field.key)
          value = @params[field.key]

          memo[field.key] =
            if value.present? && respond_to?(field.type)
              send(field.type, field, value)
            else
              value
            end
        end
      end

      def array(field, value)
        Array.wrap(CSV.parse(value).first).map(&:strip)
      end

      def hash(field, value)
        value.each_slice(2)
             .to_h
             .reject { |k, v| k.blank? || v.blank? }
             .transform_values { |v| field.values_type_class.mongoize(v) }
      end

      def duration(field, value)
        value.first.to_i.send(value.last.to_sym)
      end
    end
  end
end
