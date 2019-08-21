
require 'test_helper'

module Workarea
  class ReleasePreviewingTest < TestCase
    class Foo
      include Mongoid::Document
      include Mongoid::Timestamps
      include Releasable
      field :name, type: String
      field :description, type: String
    end

    def test_basic_previewing
      first_release = create_release(publish_at: 1.day.from_now)
      second_release = create_release(publish_at: 2.days.from_now)

      model = Foo.create!(name: 'Test')
      first_release.as_current do
        model.name = 'Changed'
        model.save!
      end

      model.reload
      second_release.as_current do
        model.description = 'Description'
        model.save!
      end

      first_release.as_current do
        model.reload
        assert_equal('Changed', model.name)
        assert_nil(model.description)
      end

      second_release.as_current do
        model.reload
        assert_equal('Changed', model.name)
        assert_equal('Description', model.description)
      end
    end
  end
end
