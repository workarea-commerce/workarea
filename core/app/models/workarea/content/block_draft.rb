module Workarea
  class Content
    class BlockDraft
      include ApplicationDocument

      field :content_id, type: String
      Block.fields.except('_id').each do |name, field_instance|
        field name, field_instance.options.except(:klass)
      end

      # Added as a field to ensure copying this value to any blocks created
      # from a draft.
      field :activate_with, type: String

      index(
        { created_at: 1 },
        { expire_after_seconds: 1.hour.seconds.to_i }
      )

      before_save :typecast_data!

      def content
        Content.find(content_id)
      end

      def block_type
        return unless type_id.present?
        Configuration::ContentBlocks.types.detect { |bt| bt.id == type_id.to_sym }
      end

      def typecast_data!
        return unless type_id.present? && data.present?
        self.data = block_type.try(:typecast!, data)
        self
      end

      def to_block
        result = Content::Block.instantiate(as_document.except('content_id'))
        result.new_record = true
        result
      end
    end
  end
end
