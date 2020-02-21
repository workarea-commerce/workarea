require 'test_helper'

module Workarea
  class Content
    class BlockNameTest < TestCase
      def test_not_erroring_for_configured_blocks
        assert_nothing_raised do
          Configuration::ContentBlocks.types.each do |type|
            block = Block.new(type: type, data: type.defaults)
            BlockName.new(block).to_s
          end
        end
      end

      def test_name_is_human_readable
        Configuration::ContentBlocks.types.each do |type|
          block = Block.new(type: type, data: type.defaults)
          name = BlockName.new(block).to_s

          refute_match(/\[/, name)
        end
      end
    end
  end
end
