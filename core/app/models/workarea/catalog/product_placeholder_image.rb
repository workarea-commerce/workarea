module Workarea
  module Catalog
    class ProductPlaceholderImage
      include ApplicationDocument
      extend Dragonfly::Model

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

      dragonfly_accessor :image, app: :workarea

      class << self
        def cached
          @image ||= first || create_from_pipeline!
        end

        private

        def create_from_pipeline!
          create!(
            image: FindPipelineAsset.new(
                    Workarea.config.product_placeholder_image_name
                  ).path
          )
        end
      end

      def placeholder?
        true
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
