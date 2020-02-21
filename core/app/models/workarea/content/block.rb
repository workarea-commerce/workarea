module Workarea
  class Content
    # This class represents a single block of content. These are grouped
    # by their area field for display in the storefront.
    #
    # The actual HTML rendered is defined by the type field. This
    # field is used to decide which partial is used to display for storefront.
    # The data field is passed to the partial as local assigns.
    #
    # This flexibility makes it very easy to add a new type to the system:
    # 1) Define the block type using the DSL ({Workarea.define_content_block_types})
    # 2) Add the storefront partial, e.g. workarea/storefront/content_blocks/types/_foo.html.haml
    #
    class Block
      include ApplicationDocument
      include Releasable
      include Ordering

      # @!attribute type_id
      #   @return [Symbol] the content block type id
      #
      field :type_id, type: Symbol

      # @!attribute area
      #   @return [String] what area on the page this block belongs to
      #
      field :area, type: String, default: 'default'

      # @!attribute data
      #   @return [HashWithIndifferentAccess] data passed to partials to render
      #
      field :data,
              type: HashWithIndifferentAccess,
              default: HashWithIndifferentAccess.new,
              localize: true

      # @!attribute hidden_breakpoints
      #   @return [Array] the breakpoints for which the block will be hidden
      #
      field :hidden_breakpoints, type: Array, default: []

      # @!attribute name
      #   @return [String] the user-defined name of the block
      #
      field :name, type: String

      # @!attribute content
      #   @return [Content]
      #
      embedded_in :content,
        class_name: 'Workarea::Content',
        inverse_of: :blocks

      validates :area, presence: true
      validates :type, presence: true
      validate :data_fields

      before_validation :set_defaults, on: :create
      before_validation :typecast_data

      delegate :icon, :fieldsets, to: :type

      # Tries to find a unique name for this block relative to the other blocks
      # in the content area.
      #
      # @return [String]
      #
      def name
        super.presence || BlockName.new(self).to_s
      end

      # The bag of data used to render this content block on the storefront.
      # Any relevant data for rendering can be stored here. All data will be
      # typecasted and validated by the {Workarea::Content::Field} system.
      #
      # @return [HashWithIndifferentAccess]
      #
      def data
        value = super

        unless value.nil? || value.is_a?(HashWithIndifferentAccess)
          wrapped_hash = value.with_indifferent_access
          self.send(:data=, wrapped_hash) unless self.frozen?
          value = wrapped_hash
        end

        value
      end

      def data=(value)
        unless value.is_a?(HashWithIndifferentAccess)
          value = value.with_indifferent_access
        end

        super(value)
      end

      # The {Workarea::Content::BlockType} that this block is. See documentation
      # for {Workarea.define_content_block_types} for info how to define block types.
      #
      # @return [Workarea::Content::BlockType]
      #
      def type
        Configuration::ContentBlocks.types.detect { |bt| bt.id == type_id }
      end

      def type=(value)
        self.type_id = value.is_a?(BlockType) ? value.id : value
      end

      # Any miscellaneous config set on the {#type} by the content block DSL.
      #
      # @return [HashWithIndifferentAccess]
      #
      def config
        type.config.with_indifferent_access
      end

      # Whether this block is at the top of the blocks list
      #
      # @return [Boolean]
      #
      def at_top?
        self == siblings.select(&:active?).first
      end

      # Whether this block is at the top of the blocks list
      #
      # @return [Boolean]
      #
      def at_bottom?
        self == siblings.select(&:active?).last
      end

      def to_draft
        result = Content::BlockDraft.instantiate(as_document.merge('content_id' => _parent.id))
        result.new_record = true
        result
      end

      private

      def set_defaults
        return if type.blank? || data.present?
        self.data = type.defaults
      end

      def typecast_data
        self.data = type.typecast!(data) if type.present? && data.present?
      end

      def data_fields
        return unless type.present?

        type.fields.each do |field|
          if field.required? && data[field.slug.to_s].blank?
            errors.add(field.slug, I18n.t('errors.messages.blank'))
          end
        end
      end

      def siblings
        return self.class.none if content.blank?
        content.blocks.where(area: area)
      end
    end
  end
end
