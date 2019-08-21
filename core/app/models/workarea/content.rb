module Workarea
  class Content
    include ApplicationDocument
    include Releasable
    include Commentable

    field :name, type: String
    field :browser_title, type: String, localize: true
    field :meta_description, type: String, localize: true
    field :javascript, type: String
    field :css, type: String
    field :automate_metadata, type: Boolean, default: true
    field :open_graph_asset_id, type: String

    belongs_to :contentable, polymorphic: true, optional: true, index: true

    index({ name: 1 })
    index({ contentable_type: 1 })
    index({ 'blocks._id' => 1 })

    embeds_many :blocks,
      class_name: 'Workarea::Content::Block',
      inverse_of: :content,
      cascade_callbacks: true

    before_validation :set_system_name
    after_update :touch_contentable

    scope :recent, ->(l = 5) { order_by([:created_at, :desc]).limit(l) }
    scope :system, (lambda do
      any_of({ :contentable_type.exists => false }, { contentable_type: nil })
    end)

    # Find {Content} for a given object. Object
    # can be string or model (polymorphic).
    #
    # @param contentable [Object]
    # @return [Content]
    #
    def self.for(object)
      if object.is_a?(String)
        find_or_create_by(name: object.titleize)
      else
        find_or_create_by(
          contentable_id: object.try(:id),
          contentable_type: object.try(:class)
        )
      end
    end

    # Find the {Content} from a {Content::Block} id
    #
    # @return [Content]
    #
    def self.from_block(block_id)
      block_id = BSON::ObjectId.from_string(block_id.to_s)
      find_by('blocks._id' => block_id) rescue nil
    end

    # Define block types for use by administrators. A block type represents a
    # row of content on the storefront, self-contained with its own styles and
    # responsive logic.
    #
    # == Defining new block types
    #
    #    Workarea::Content.define_block_types do
    #      # Create a new block type called 2 Column Text
    #      # The ID or slug for this type will be :2_column_text
    #      block_type '2 Column Text' do
    #        # Set a description, which will be shown to admin users when
    #        # selecting a block type
    #        description 'Provides 2 columns of text'
    #
    #        # Allows custom specification of which icon to use to display this
    #        # block type in the admin when selecting a new block. The default
    #        # is workarea/admin/content_block_types/#{block_type_id}
    #        icon 'workarea/admin/content_block_types/columns'
    #
    #        # Tags are used for filtering content block types in the admin when
    #        # creating a new block and selecting its type
    #        tags %w(columns text)
    #
    #        # You can also specify a custom view model to be used in the store
    #        # front when rendering. You could even share view models for
    #        # different blocks
    #        view_model 'Workarea::Storefront::ContentBlocks::ColumnsViewModel'
    #
    #        # If your block type requires developer-facing configuration, you
    #        # you can specify any arbitrary attributes and they will be added
    #        # to the #config hash on the block type. For example, configuration
    #        # values tied to site design.
    #        height 960
    #        width 470
    #
    #        # Use fieldset to group fields together for admin display. The
    #        # fieldset has no other use.
    #        fieldset 'Left Column' do
    #          # A field corresponds to one input in the admin and one key in
    #          # the Workarea::Content::Block#data hash. It will be referenced
    #          # by a systemized version of the name.
    #
    #          # The second argument must be a type. Out-of-the-box valid types
    #          # include :asset, :category, :options, :products, :rich_text,
    #          # :string, and :url.
    #
    #          # Options can be specific to the field type. All field types
    #          # support :default and :required.
    #          field 'Left Column Text', :text, required: true, default: 'Left Column'
    #        end
    #
    #        fieldset 'Right Column' do
    #          field 'Right Column Text', :text, required: true, default: 'Right Column'
    #        end
    #      end
    #    end
    #
    # == Overriding values for existing block types
    #
    # To allow full customization, all details about a block type and its fields
    # can be overridden. Here's an example of overriding details on the Product
    # List block type which ships out of the box.
    #
    #    Workarea::Content.define_block_types do
    #      # Open the Product List block up again
    #      block_type 'Product List' do
    #        # Override the default on Title
    #        field 'Title', :string, default: 'Staff Picks'
    #        # Add a new field called description
    #        field 'Description', :text, default: 'Top picks by our staff
    #
    #        # No need to touch other fields, they remain the same
    #      end
    #    end
    #
    # == Admin UI
    # The admin UI for the block will be automatically generated based on the
    # fields provided.
    #
    def self.define_block_types(&block)
      definition = BlockTypeDefinition.new
      definition.instance_eval(&block)
    end

    # The name for this content, returns the name of the contentable
    # if that is present.
    #
    # @return [String]
    #
    def name
      if !system? && contentable.present?
        contentable.name
      else
        read_attribute(:name)
      end
    end

    # Whether this content belongs to a system page as opposed to a contentable
    # model.
    #
    # @return [Boolean]
    #
    def system?
      contentable_type.blank?
    end

    # Slug for the type of object this content is
    # attached to.
    #
    # @return [String]
    #
    def slug
      if system?
        name.slugify
      else
        contentable_type.to_s.demodulize.underscore
      end
    end

    # Whether this is home page content, which
    # is a special case. Used when linking to
    # contentable.
    #
    # @return [Boolean]
    #
    def home_page?
      name =~ /home/i
    end

    # Whether this is layout content, which
    # is a special case. Used when linking to
    # contentable.
    #
    # @return [Boolean]
    #
    def layout?
      name =~ /layout/i
    end

    # Find an array of active blocks for a given area.
    #
    # @param area [String]
    # @return [Array<Block>]
    #
    def blocks_for(area)
      blocks.where(area: area).all
    end

    # Get an array of all text strings associated as part
    # of this content. Used in indexing content for search.
    #
    # @return [Array<String>]
    #
    def all_text
      blocks.map { |b| b.data.values }.flatten
    end

    private

    def set_system_name
      self.name = name.titleize if system?
    end

    def lookup_by
      contentable || name
    end

    def touch_contentable
      contentable.touch if contentable.present?
    end
  end
end
