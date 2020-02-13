module Workarea
  module Configuration
    module ContentBlocks
      extend self

      def types
        @types ||= []
      end

      def types=(values)
        @types = values
      end

      def building_blocks
        @building_blocks ||= []
      end

      def load
        building_blocks.each do |block|
          Content::BlockTypeDefinition.define(&block)
        end

        # TODO remove in v3.6, this exists to help with a backwards incompatible
        # patch to fix copying of Workarea.config in multisite.
        Workarea.config.content_block_types = types
        Workarea.deprecation.deprecate_methods(
          AdministrableOptions,
          content_block_types: 'use Configuration::ContentBlocks.types instead'
        )
      end
    end
  end
end
