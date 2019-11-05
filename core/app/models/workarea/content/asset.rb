module Workarea
  class Content::Asset
    include ApplicationDocument
    include Mongoid::Document::Taggable
    include Commentable
    extend Dragonfly::Model

    field :name, type: String
    field :type, type: String
    field :alt_text, type: String

    #
    # The values for the following fields are automatically populated via
    # Dragonfly built-in analysers. The values can be accessed by the "magic
    # attributes" that are dynamically added to the model.
    #
    # More info:
    # - http://markevans.github.io/dragonfly/imagemagick/#analysers
    # - http://markevans.github.io/dragonfly/models/#magic-attributes
    #
    field :file_name, type: String # asset.name => placeholder.png
    field :file_uid, type: String # asset.file_uid => 2017/01/17/9pjq0x9bct_placeholder.png
    field :file_width, type: Integer # asset.width => 900
    field :file_height, type: Integer # asset.height => 450
    field :file_aspect_ratio, type: Float # asset.aspect_ratio => 2.0
    field :file_portrait, type: Boolean # asset.portrait? => true
    field :file_landscape, type: Boolean # asset.landscape? => false
    field :file_format, type: String # asset.format => 'png'
    field :file_image, type: Boolean # asset.image? => true
    field :file_inverse_aspect_ratio, type: Float # asset.inverse_aspect_ratio => 0.5

    dragonfly_accessor :file, app: :workarea do
      after_assign do |attachment|
        if FastImage.type(attachment.file) == :jpeg
          file.encode!('jpg', Workarea.config.jpg_encode_options)
        end
      end
    end

    validates :file, presence: true

    scope :of_type, ->(t) { where(type: t) }

    index({ file_name: 1 })

    after_validation :set_name
    after_validation :set_type

    def self.image_placeholder
      find_by(file_name: Workarea.config.image_placeholder_image_name)

    rescue Mongoid::Errors::DocumentNotFound
      create!(
        file: FindPipelineAsset.new(
          Workarea.config.image_placeholder_image_name
        ).path
      )
    end

    def self.open_graph_placeholder
      find_by(file_name: Workarea.config.open_graph_placeholder_image_name)

    rescue Mongoid::Errors::DocumentNotFound
      create!(
        file: FindPipelineAsset.new(
          Workarea.config.open_graph_placeholder_image_name
        ).path
      )
    end

    def self.favicon_placeholder
      find_by(file_name: Workarea.config.favicon_placeholder_image_name)

    rescue Mongoid::Errors::DocumentNotFound
      create!(
        file: FindPipelineAsset.new(
          Workarea.config.favicon_placeholder_image_name
        ).path
      )
    end

    def self.favicons(type = nil)
      tagged_with(['favicon', type].compact.join('-'))
    end

    def self.open_graph_default
      tagged_with('og-default').first
    end

    def favicon?
      tags.any? { |t| t.starts_with?('favicon') }
    end

    def image_placeholder?
      file_name == Workarea.config.image_placeholder_image_name
    end

    def open_graph_placeholder?
      file_name == Workarea.config.open_graph_placeholder_image_name
    end

    def favicon_placeholder?
      file_name == Workarea.config.favicon_placeholder_image_name
    end

    Workarea.config.asset_types.each do |asset_type|
      define_method "#{asset_type}?" do
        self.type == asset_type
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      super || file.respond_to?(method_name)
    end

    def method_missing(sym, *args, &block)
      if file.respond_to?(sym)
        file.send(sym, *args, &block)
      else
        super
      end
    end

    private

    def set_name
      return if errors.present? || file_name.blank? || name.present?
      self.name = File.basename(file_name, File.extname(file_name))
    end

    def set_type
      return if errors.present? || file.blank? || skip_type?

      if FastImage.type(file.file).in?(%i(gif jpeg png tiff bmp))
        self.type = 'image'
      else
        Workarea.config.asset_types.each do |name|
          self.type = name if file.mime_type.include?(name)
        end
      end

      self.type = 'unknown' if type.blank?
    end

    def skip_type?
      new_record? && type.present?
    end
  end
end
