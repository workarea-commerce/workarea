module Workarea
  module Configuration
    module ContentBlocks
      extend self

      def building_blocks
        @building_blocks ||= []
      end

      def load
        building_blocks.each do |block|
          Content::BlockTypeDefinition.define(&block)
        end
      end
    end
  end
end
