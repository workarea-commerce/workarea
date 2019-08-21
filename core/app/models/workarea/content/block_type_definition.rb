module Workarea
  class Content
    # @deprecated Use `Workarea.define_content_block_types` instead.
    def self.define_block_types(&block)
      warn <<~eos
        [DEPRECATION] `Workarea::Content.define_block_types` is deprecated and will be removed in
        version 3.6.0. Please use `Workarea.define_content_block_types` instead.
      eos
      definition = BlockTypeDefinition.new
      definition.instance_eval(&block)
    end

    class BlockTypeDefinition
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
