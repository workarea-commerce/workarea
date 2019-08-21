require 'test_helper'

module Workarea
  class ApplicationDocumentTest < TestCase
    class FooModel
      include ApplicationDocument
      field :name, type: String, localize: true
      field :ids, type: Array
      field :tags, type: Array, localize: true
    end

    def test_cleaning_array_values
      model = FooModel.create!(ids: ['1', '', '2'])
      assert_equal(['1', '2'], model.ids)
    end

    def test_cleaning_array_values_when_nil
      model = FooModel.create!
      assert_nil(model.ids)
    end

    def test_cleaning_localized_array_values
      model = FooModel.create!(tags: ['1', '', '2'])
      assert_equal(['1', '2'], model.tags)
    end

    def test_cleaning_when_array_tanslations
      model = FooModel.create!(
        tags_translations: {
          'en' => [''],
          'ts' => nil,
          'jp' => ['', 'sale']
        }
      )

      assert_equal({ 'en' => [], 'ts' => nil, 'jp' => ['sale']}, model.tags_translations)
    end
  end
end
