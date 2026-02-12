module Workarea
  class << self
    delegate :add_append, to: :'Workarea::Plugin'

    %w(stylesheets javascripts partials).each do |type|
      delegate :"append_#{type}", :"#{type}_appends", to: :'Workarea::Plugin'
    end
  end

  # Colors used for styling executable output
  COLOR_CODES = {
    red: 31,
    green: 32,
    yellow: 33
  }

  # Shortcut for configuration, passes config
  # to the block given.
  #
  # @example Set an option
  #   Workarea.configure do |config|
  #     config.some_value = true
  #   end
  #
  def self.configure
    yield(config)
  end

  # A shortcut to the Rails' application config
  # relevant to Workarea.
  #
  # @return [Workarea::Configuration::AdministrableOptions]
  #
  def self.config
    @custom_config.presence || Configuration.config
  end

  def self.with_config
    @custom_config ||= config.deep_dup
    yield(@custom_config)
  ensure
    @custom_config = nil
  end

  # A [Redis] client for general application use.
  #
  # @return [Redis]
  #
  def self.redis
    @redis ||= Redis.new(Configuration::Redis.persistent.to_h)
  end

  # The [Elasticsearch::Client] for general application use.
  #
  # @return [Elasticsearch::Client]
  #
  def self.elasticsearch
    @elasticsearch ||= ::Elasticsearch::Client.new(
      Configuration::Elasticsearch.find
    )
  end

  # The [Fog::Storage::AWS] instance for internal application S3 use.
  #
  # @return [Fog::Storage::AWS]
  #
  def self.s3
    @s3 ||= begin
      options = { region: Configuration::S3.region.to_s }

      if Configuration::S3.use_iam_profile?
        options.merge!(use_iam_profile: true)
      else
        options.merge!(
          aws_access_key_id: Configuration::S3.access_key_id.to_s,
          aws_secret_access_key: Configuration::S3.secret_access_key.to_s
        )
      end

      Fog.mock! unless Configuration::S3.configured?
      Fog::AWS::Storage.new(options)
    end
  end

  # Use this to parse a referrer. It's globalized here because each instantiation
  # will read a file, and we may need an instance on every request if there's a
  # segment setup for referrer.
  #
  # @return [RefererParser::Parser]
  #
  def self.referrer_parser
    @referrer_parser ||= RefererParser::Parser.new
  end

  # Define block types for use by administrators. A block type represents a
  # row of content on the storefront, self-contained with its own styles and
  # responsive logic.
  #
  # == Defining new block types
  #
  #    Workarea.define_content_block_types do
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
  #    Workarea.define_content_block_types do
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
  def self.define_content_block_types(&block)
    Configuration::ContentBlocks.building_blocks << block
  end

  # Use this deprecation to warn about the next minor release.
  #
  # @return [ActiveSupport::Deprecation]
  #
  def self.deprecation
    @deprecation ||= ActiveSupport::Deprecation.new('3.6', 'Workarea')
  end

  # Whether the app should skip connecting to external services on boot,
  # such as Mongo, Elasticsearch, or Redis. Note that this will break
  # functionality relying on these services.
  #
  # @return [Boolean]
  #
  def self.skip_services?
    !!(ENV['WORKAREA_SKIP_SERVICES'] =~ /true/)
  end
end

require 'workarea/core'
