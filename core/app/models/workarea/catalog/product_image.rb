module Workarea
  module Catalog
    class ProductImage
      include ApplicationDocument
      extend Dragonfly::Model

      field :option, type: String
      field :position, type: Integer
      field :image_name, type: String
      field :image_uid, type: String

      #
      # The values for the following fields are automatically populated via
      # Dragonfly built-in analysers. The values can be accessed by the "magic
      # attributes" that are dynamically added to the model.
      #
      # More info:
      # - http://markevans.github.io/dragonfly/imagemagick/#analysers
      # - http://markevans.github.io/dragonfly/models/#magic-attributes
      #
      field :image_width, type: Integer         # image.width         # => 900
      field :image_height, type: Integer        # image.height        # => 450
      field :image_aspect_ratio, type: Float    # image.aspect_ratio  # => 2.0
      field :image_portrait, type: Boolean      # image.portrait?     # => true
      field :image_landscape, type: Boolean     # image.landscape?    # => false
      field :image_format, type: String         # image.format        # => 'png'
      field :image_image, type: Boolean         # image.image?        # => true

      embedded_in :product,
        class_name: 'Workarea::Catalog::Product',
        inverse_of: :images,
        touch: true

      dragonfly_accessor :image, app: :workarea

      after_save { _parent.touch }
      after_destroy { _parent.touch }

      default_scope -> { order_by(position: :asc, updated_at: :desc) }

      def valid?(*)
        self.position ||= _parent.images.length - 1
        super
      end

      def placeholder?
        false
      end

      def respond_to_missing?(method_name, include_private = false)
        super || image.respond_to?(method_name)
      end

      def method_missing(sym, *args, &block)
        image.send(sym, *args, &block) if image.respond_to?(sym)
      end
    end
  end
end
