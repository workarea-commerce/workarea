module Workarea
  module Catalog
    class ProductImage
      include ApplicationDocument
      extend Dragonfly::Model

      field :option, type: String, localize: Workarea.config.localized_image_options
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
      field :image_width, type: Integer
      field :image_height, type: Integer
      field :image_aspect_ratio, type: Float
      field :image_portrait, type: Boolean
      field :image_landscape, type: Boolean
      field :image_format, type: String
      field :image_image, type: Boolean
      field :image_inverse_aspect_ratio, type: Float

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

      def image_inverse_aspect_ratio
        return if image_aspect_ratio.blank? || image_aspect_ratio.zero?
        1 / image_aspect_ratio.to_f
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
