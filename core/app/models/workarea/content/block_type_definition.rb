module Workarea
  class Content
    class BlockTypeDefinition
      def self.define(&block)
        new.instance_eval(&block)
      end

      def block_type(name, &block)
        block_type = BlockType.new(name)

        if existing = BlockType.find(block_type.slug)
          existing.instance_eval(&block) if block_given?
        else
          block_type.instance_eval(&block) if block_given?
          Configuration::ContentBlocks.types.push(block_type)
        end
      end
    end
  end
end
