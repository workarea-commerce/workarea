module Workarea
  class Content
    class Preset
      include ApplicationDocument

      # Create and persist a preset from an existing block.
      #
      # @param [Hash]
      # @param [Workarea::Content::Block]
      #
      # @return [Workarea::Content::Preset]
      #
      def self.create_from_block(attributes, block)
        instance = new(attributes)
        instance.apply_block(block)
        instance.save
      end

      # @!attribute type_id
      #   @return [Symbol] the content block type id
      #
      field :type_id, type: Symbol

      # @!attribute name
      #   @return [String]
      #
      field :name, type: String

      # @!attribute data
      #   @return [Hash] the pieces of data passed to partials to render
      #
      field :data, type: Hash, default: {}, localize: true

      validates :name, presence: true

      # Populate a preset from an existing {Workarea::Content::Block}
      #
      # @param [Workarea::Content::Block] block the block to copy
      #
      # @return [Boolean]
      #
      def apply_block(block)
        self.attributes = block.as_json.slice('data', 'type_id')
        self.name ||= block.type.name
      end

      # Return attributes needed to create a {Workarea::Content::Block}
      # from a preset.
      #
      # @return [Hash]
      #
      def block_attributes
        as_json.slice('data', 'type_id')
      end

      # The {Workarea::Content::BlockType} that this block is. See documentation
      # for {Workarea.define_content_block_types} for info how to define block types.
      #
      # @return [Workarea::Content::BlockType]
      #
      def type
        Configuration::ContentBlocks.types.detect { |bt| bt.id == type_id }
      end
    end
  end
end
