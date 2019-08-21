module Workarea
  class Content
    class BlockName
      def initialize(block)
        @block = block
      end

      def fields_with_displayable_values
        @block
          .type
          .fields
          .reject { |f| f.type == :string && f.options[:multi_line] }
          .select { |f| [:text, :options].exclude?(f.type) }
          .select { |f| @block.data[f.slug].present? }
      end

      def find_field_value(field)
        value = @block.data[field.slug]
        return value unless BSON::ObjectId.legal?(value)

        Workarea.config.content_block_name_search_classes.each do |class_name|
          model = class_name.constantize.where(id: value).first
          return model.name if model.present?
        end

        value
      end

      def first_displayable_value
        fields_with_displayable_values.each do |field|
          value = find_field_value(field)
          return value if value.present?
        end
      end

      def to_s
        if fields_with_displayable_values.blank? || first_displayable_value.blank? || !first_displayable_value.is_a?(String)
          @block.type.name
        else
          "#{@block.type.name} - #{first_displayable_value}"
        end
      end
    end
  end
end
