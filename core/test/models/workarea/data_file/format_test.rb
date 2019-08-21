require 'test_helper'

module Workarea
  module DataFile
    class FormatTest < TestCase
      class Bar; end
      class Foo < Bar; end

      def test_model_class_for
        operation = DataFile::Export.new(
          model_type: 'Workarea::DataFile::FormatTest::Bar'
        )
        format = Format.new(operation)
        type = 'Workarea::DataFile::FormatTest::Foo'

        assert_equal(format.model_class_for, format.model_class)
        assert_equal(format.model_class_for(_type: type), Foo)
        assert_equal(format.model_class_for(type: type), Foo)
        assert_equal(format.model_class_for('_type' => type), Foo)
        assert_equal(format.model_class_for('type' => type), Foo)
      end
    end
  end
end
