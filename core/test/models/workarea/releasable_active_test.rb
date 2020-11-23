require 'test_helper'

module Workarea
  class ReleasableActiveTest < TestCase
    class Foo
      include Mongoid::Document
      include Mongoid::Timestamps
      include Releasable
      field :name, type: String
      field :blank_field, type: String
      field :slug, type: String
      validates :name, presence: true

      embeds_many :bars
      embeds_one :baz
    end

    class Bar
      include Mongoid::Document
      include Releasable
      field :name, type: String
      embedded_in :foo
    end

    class Baz
      include Mongoid::Document
      include Releasable
      field :name, type: String
      embedded_in :foo
    end

    setup :set_release

    def set_release
      @release = create_release
    end

    def active?(changeset)
      if Workarea.config.localized_active_fields
        changeset['active'][I18n.locale.to_s]
      else
        changeset['active']
      end
    end

    def test_save_can_schedule_activation
      model = Foo.create!(
        name: 'Test',
        active: true,
        activate_with: @release.id
      )

      model.reload

      refute(model.active)
      assert_equal(1, model.changesets.length)
      assert_equal(@release.id, model.changesets.first.release_id)
      assert_equal(1, model.changesets.first.changeset.size)
      assert(active?(model.changesets.first.changeset))
      assert_equal(1, model.changesets.first.original.size)
      refute(active?(model.changesets.first.original))
    end

    def test_save_can_schedule_activation_for_an_embedded_document
      model = Foo.create!(name: 'Test')

      embedded_1 = model.bars.create!(
        name: 'Bar',
        active: true,
        activate_with: @release.id
      )

      embedded_2 = model.bars.create!(
        name: 'Baz',
        active: true,
        activate_with: @release.id
      )

      model.reload

      refute(embedded_1.active)
      assert_equal(1, embedded_1.changesets.length)
      assert_equal(@release.id, embedded_1.changesets.first.release_id)
      assert_equal(1, embedded_1.changesets.first.changeset.size)
      assert(active?(embedded_1.changesets.first.changeset))
      assert_equal(1, embedded_1.changesets.first.original.size)
      refute(active?(embedded_1.changesets.first.original))

      refute(embedded_2.active)
      assert_equal(1, embedded_2.changesets.length)
      assert_equal(@release.id, embedded_2.changesets.first.release_id)
      assert_equal(1, embedded_2.changesets.first.changeset.size)
      assert(active?(embedded_2.changesets.first.changeset))
      assert_equal(1, embedded_2.changesets.first.original.size)
      refute(active?(embedded_2.changesets.first.original))
    end

    def test_creating_and_activating_embedded
      model = Foo.create!(name: 'Foo')

      embedded = Release.with_current(@release.id) do
        model.bars.create!(
          name: 'Test',
          active: true,
          activate_with: @release.id
        )
      end

      model.reload

      refute(embedded.active)
      assert_equal(1, embedded.changesets.length)
      assert_equal(@release.id, embedded.changesets.first.release_id)
      assert_equal(1, embedded.changesets.first.changeset.size)
      assert(active?(embedded.changesets.first.changeset))
      assert_equal(1, embedded.changesets.first.original.size)
      refute(active?(embedded.changesets.first.original))
      assert(embedded.changesets.first.document_path.present?)
    end
  end
end
