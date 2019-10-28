module Workarea
  class Content
    # @deprecated Use `Workarea.define_content_block_types` instead.
    class << self
      def define_block_types(&block)
        definition = BlockTypeDefinition.new
        definition.instance_eval(&block)
      end
      Workarea.deprecation.deprecate_methods(
        self,
        define_block_types: 'Use `Workarea.define_content_block_types` instead.'
      )
    end

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
          Workarea.config.content_block_types.push(block_type)
        end
      end
    end
  end
end
