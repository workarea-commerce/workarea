module Workarea
  class Content
    include ApplicationDocument
    include Releasable
    include Commentable

    field :name, type: String
    field :browser_title, type: String, localize: true
    field :meta_description, type: String, localize: true
    field :javascript, type: String
    field :head_content, type: String
    field :css, type: String
    field :automate_metadata, type: Boolean, default: true
    field :open_graph_asset_id, type: String
    field :content_security_policy, type: String

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

    # @deprecated Use `Workarea.define_content_block_types` instead.
    class << self
      def define_block_types(&block)
        require_dependency 'workarea/content/block_type_definition'
        definition = BlockTypeDefinition.new
        definition.instance_eval(&block)
      end
      Workarea.deprecation.deprecate_methods(
        self,
        define_block_types: 'Use `Workarea.define_content_block_types` instead.'
      )
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
