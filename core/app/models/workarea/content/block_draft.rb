module Workarea
  class Content
    class BlockDraft
      include ApplicationDocument
      include Mongoid::Attributes::Dynamic

      field :content_id, type: String

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
        Workarea.config.content_block_types.detect { |bt| bt.id == type_id.to_sym }
      end

      def typecast_data!
        return unless type_id.present? && data.present?
        self.data = block_type.try(:typecast!, data)
        self
      end

      def to_block
        content.blocks.build(attributes.except('content_id'))
      end
    end
  end
end
