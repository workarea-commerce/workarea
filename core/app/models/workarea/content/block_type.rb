module Workarea
  class Content
    class BlockType
      include AssetLookup

      # @return [String] admin-facing name of the block type.
      attr_reader :name

      # @return [Array<Workarea::Content::Fieldset>] list of fieldsets
      attr_reader :fieldsets

      # @return [String] miscellaneous configuration specified in the DSL
      attr_reader :config

      # Find a {Workarea::Content::BlockType} by its id (which should be a
      # symbol).
      #
      # @param [Symbol]
      # @return [Workarea::Content::BlockType, nil]
      #
      def self.find(id)
        Configuration::ContentBlocks.types.detect { |bt| bt.id == id }
      end

      def initialize(name)
        @name = name
        @fieldsets = []
        @config = {}
      end

      # The unique identifier for this block type. Used to determine which
      # partial to render for this block type and which view model to try to
      # use. It is based on the block type's name.
      #
      # @return [Symbol]
      #
      def id
        name.to_s.systemize.to_sym
      end
      alias_method :slug, :id

      # Get a path to an icon to show to represent the block type to the admin
      # user when selecting block types. Based on the name by default, can be
      # specified in the content block DSL.
      #
      # @return [String]
      #
      def icon(value = nil)
        @icon = value.presence ||
          @icon.presence ||
          "workarea/admin/content_block_types/#{name.systemize}.svg"
      end

      # A short description to describe the block type to the admin user when
      # selecting a block type.
      #
      # @return [String]
      #
      def description(value = nil)
        @description = value.presence || @description.presence || name
      end

      # Tags are used to filter block types for admin users when selecting which
      # type they'd like for the new block.
      #
      # @return [Array<String>]
      #
      def tags(value = nil)
        @tags = value.presence || @tags.presence || []
      end

      # The string representing the view model class to be used to render this
      # content block type. This value will get constantized when rendering to
      # get the class constant.
      #
      # @return [String]
      #
      def view_model(value = nil)
        @view_model = value.presence ||
          @view_model.presence ||
          "Workarea::Storefront::ContentBlocks::#{slug.to_s.camelize}ViewModel"
      end

      # Define a fieldset on the block type. The block will be evaluated in the
      # {Workarea::Content::Fieldset} to provide the DSL. See more info on the
      # block type DSL at {Workarea.define_content_block_types}.
      #
      # @param name [String]
      # @yield evaluated in the {Workarea::Content::Fieldset} for DSL
      #
      def fieldset(name, replaces: nil, &block)
        remove_fieldset(replaces) if replaces.present?
        fieldset = find_or_initialize_fieldset(name)
        fieldset.instance_eval(&block)
      end

      # Remove a previously-defined fieldset on the block type. Used by
      # the {replaces:} option in {fieldset} to remove a fieldset prior
      # to creating a new one with the new name in its place.
      #
      # @param name [String]
      #
      def remove_fieldset(name)
        @fieldsets.reject! { |fieldset| fieldset.name == name }
      end

      # A series allows multiple instances of the same fields in a group. This
      # can be useful when you want to reuse the same fields multiple times in
      # the content block, like image groups or multiple-column blocks.
      #
      # Each member of the series corresponds to a fieldset and a view model
      # that will be instanciated for that instance.
      #
      # Each block type can only have one series.
      #
      # @param size [Integer]
      # @yield evaluated in the {Workarea::Content::Fieldset} for DSL
      #
      def series(size = @series, &block)
        @series = size

        1.upto(@series.to_i).map do |i|
          fieldset = find_or_initialize_fieldset(i.ordinalize)
          fieldset.field_suffix = " #{i}"
          fieldset.instance_eval(&block) if block_given?
          fieldset
        end
      end

      # Define a {Workarea::Content::Field} on this block type. Given that this
      # is being declared without a {Workarea::Content::Fieldset}, this will be
      # added to a default {Workarea::Content::Fieldset} called 'Settings'. See
      # more info on the block type DSL at {Workarea.define_content_block_types}
      #
      # @param name [String]
      # @param type [Symbol] a slug version of a {Workarea::Content::Field} subclass
      # @param options [Hash]
      #
      def field(name, type, options = {})
        settings = find_or_initialize_fieldset('Settings')
        settings.field(name, type, options)
      end

      # All fields that belong to this block type.
      #
      # @return [Array<Workarea::Content::Field>]
      #
      def fields
        fieldsets.map(&:fields).reduce(&:+) || []
      end

      # The default values for this block type's fields in a hash of the form
      #   :field_slug => 'field default value'
      #
      # @return [Hash]
      #
      def defaults
        fields.reduce({}) do |memo, field|
          memo[field.slug] = field.default
          memo
        end
      end

      # Passes data through the typecasting system provided by
      # {Workarea::Content::Field}. Values on the hash get converted by the
      # correlating {Workarea::Content::Field}.
      #
      # @param data [Hash] hash of data to be converted
      #
      # @return [Hash]
      #
      def typecast!(data)
        data.deep_dup.tap do |hash|
          fields.each do |field|
            hash[field.slug.to_s] = field.typecast(hash[field.slug.to_s])
          end
        end
      end

      def method_missing(name, *args, &block)
        @config[name] = args.first
      end

      private

      def find_or_initialize_fieldset(name)
        existing = @fieldsets.detect { |f| f.name == name }
        return existing if existing.present?

        @fieldsets << Fieldset.new(name)
        @fieldsets.last
      end
    end
  end
end
