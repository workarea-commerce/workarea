require 'test_helper'

module Workarea
  class ReleasableTest < TestCase
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

    def test_find
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!

        model.baz.name = 'Baz Changed'
        model.baz.save!
      end

      assert_equal('Test', model.name)
      assert_equal('Bar', model.bars.first.name)
      assert_equal('Baz', model.baz.name)

      Release.with_current(@release.id) do
        new_instance = Foo.find(model.id)
        assert_equal('Changed', new_instance.name)
        assert_equal('Bar Changed', new_instance.bars.first.name)
        assert_equal('Baz Changed', new_instance.baz.name)
      end

      new_instance = Foo.find(model.id)
      assert_equal('Test', new_instance.name)
      assert_equal('Bar', new_instance.bars.first.name)
      assert_equal('Baz', new_instance.baz.name)

      Release.with_current(@release.id) do
        new_instance = Foo.where(id: model.id).first
        assert_equal('Changed', new_instance.name)
        assert_equal('Bar Changed', new_instance.bars.first.name)
        assert_equal('Baz Changed', new_instance.baz.name)
      end

      new_instance = Foo.find(model.id)
      assert_equal('Test', new_instance.name)
      assert_equal('Bar', new_instance.bars.first.name)
      assert_equal('Baz', new_instance.baz.name)

      Release.with_current(@release.id) do
        new_instance = Foo.find_or_create_by(name: 'Test')
        assert_equal('Changed', new_instance.name)
        assert_equal('Bar Changed', new_instance.bars.first.name)
        assert_equal('Baz Changed', new_instance.baz.name)
      end
    end

    def test_save_logs_release_changes_if_current_release
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!

        model.baz.name = 'Baz Changed'
        model.baz.save!
      end

      model.reload

      assert_equal('Test', model.name)
      assert_equal(1, model.changesets.length)
      assert_equal(@release.id, model.changesets.first.release_id)
      assert_equal('Changed', model.changesets.first.changeset['name'])

      assert_equal('Bar', model.bars.first.name)
      assert_equal(1, model.bars.first.changesets.length)
      assert_equal(@release.id, model.bars.first.changesets.first.release_id)
      assert_equal('Bar Changed', model.bars.first.changesets.first.changeset['name'])

      assert_equal('Baz', model.baz.name)
      assert_equal(1, model.baz.changesets.length)
      assert_equal(@release.id, model.baz.changesets.first.release_id)
      assert_equal('Baz Changed', model.baz.changesets.first.changeset['name'])
    end

    def test_save_does_not_log_undone_changes
      model = Foo.create!(
        name: 'Test',
        blank_field: 'test'
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.blank_field = 'changed'
        model.save!

        model.name = 'Test'
        model.blank_field = 'changed'
        model.save!
      end

      assert(model.changesets.first.present?)
      assert_equal('changed', model.changesets.first.changeset['blank_field'])
      assert_nil(model.changesets.first.changeset['name'])

      Release.with_current(@release.id) do
        model.blank_field = 'test'
        model.save!
      end

      assert(model.changesets.empty?)
    end

    def test_save_does_not_log_release_changes_if_invalid
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = ''
        model.bars.first.name = 'Bar Changed'
        model.baz.name = 'Baz Changed'
        refute(model.save)
      end

      assert_equal('', model.name)
      assert(model.changesets.empty?)
      assert(model.bars.first.changesets.empty?)
      assert(model.baz.changesets.empty?)

      model.reload

      assert_equal('Test', model.name)
      assert_equal('Bar', model.bars.first.name)
      assert_equal('Baz', model.baz.name)
      assert(model.changesets.empty?)
      assert(model.bars.first.changesets.empty?)
      assert(model.baz.changesets.empty?)
    end

    def test_save_does_not_make_more_than_one_release_change_per_release
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed 1'
        model.save!

        model.bars.first.name = 'Bar Changed 1'
        model.bars.first.save!

        model.baz.name = 'Baz Changed 1'
        model.baz.save!

        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!

        model.baz.name = 'Baz Changed'
        model.baz.save!
      end

      model.reload

      assert_equal('Test', model.name)
      assert_equal(1, model.changesets.length)
      assert_equal(@release.id, model.changesets.first.release_id)
      assert_equal('Changed', model.changesets.first.changeset['name'])

      assert_equal('Bar', model.bars.first.name)
      assert_equal(1, model.bars.first.changesets.length)
      assert_equal(@release.id, model.bars.first.changesets.first.release_id)
      assert_equal('Bar Changed', model.bars.first.changesets.first.changeset['name'])

      assert_equal('Baz', model.baz.name)
      assert_equal(1, model.baz.changesets.length)
      assert_equal(@release.id, model.baz.changesets.first.release_id)
      assert_equal('Baz Changed', model.baz.changesets.first.changeset['name'])
    end

    def test_save_does_not_save_timestamp_changes
      model = Foo.create!(name: 'Test')

      Release.with_current(@release.id) do
        model.update_attributes!(name: 'Changed')
      end

      fields_in_change = model.changesets.first.changeset.keys
      refute_includes(fields_in_change, 'updated_at')
    end

    def test_save_does_not_save_slug_changes
      model = Foo.create!(name: 'Test', slug: 'test')

      Release.with_current(@release.id) do
        model.update_attributes(slug: 'test-changed')

        refute(model.valid?)
        assert_includes(
          model.errors.full_messages,
          'Slug cannot be changed for releases'
        )
      end
    end

    def test_save_does_not_save_blank_to_blank_changes
      model = Foo.create!(name: 'Test', blank_field: nil)

      Release.with_current(@release.id) do
        model.update_attributes!(name: 'Changed', blank_field: '')
      end

      fields_in_change = model.changesets.first.changeset.keys
      refute_includes(fields_in_change, 'blank_field')
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
      assert(model.changesets.first.changeset['active'])
    end

    def test_save_ignores_illegal_values
      model = Foo.create!(
        name: 'Test',
        active: true,
        activate_with: 'now'
      )

      model.reload

      assert(model.active)
      assert_equal(0, model.changesets.length)
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
      assert(embedded_1.changesets.first.changeset['active'])

      refute(embedded_2.active)
      assert_equal(1, embedded_2.changesets.length)
      assert_equal(@release.id, embedded_2.changesets.first.release_id)
      assert(embedded_2.changesets.first.changeset['active'])
    end

    def test_destroys_related_changesets
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!
      end

      model.destroy

      assert_equal(0, Release::Changeset.count)
    end

    def test_destroy_cleans_its_parents_changesets_if_embedded
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!
      end

      model.bars.first.destroy
      model.reload

      assert_equal(1, Release::Changeset.count)
      assert_equal(1, model.changesets.length)
      assert_equal(@release.id, model.changesets.first.release_id)
      assert_equal('Changed', model.changesets.first.changeset['name'])
    end

    def test_destroys_a_changeset_where_it_is_the_only_change_if_embedded
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.bars.first.name = 'Bar Changed'
        model.save!
      end

      model.bars.first.destroy
      model.reload

      assert_equal(0, model.changesets.length)
    end

    def test_publish
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!

        model.baz.name = 'Baz Changed'
        model.baz.save!
      end

      @release.changesets.each(&:publish!)
      model.reload

      assert_equal('Changed', model.name)
      assert_equal('Bar Changed', model.bars.first.name)
      assert_equal('Baz Changed', model.baz.name)
    end

    def test_undo
      model = Foo.create!(
        name: 'Test',
        bars: [{ name: 'Bar' }],
        baz: { name: 'Baz' }
      )

      Release.with_current(@release.id) do
        model.name = 'Changed'
        model.save!

        model.bars.first.name = 'Bar Changed'
        model.bars.first.save!

        model.baz.name = 'Baz Changed'
        model.baz.save!
      end

      @release.changesets.each(&:publish!)
      model.reload

      assert_equal('Changed', model.name)
      assert_equal('Bar Changed', model.bars.first.name)
      assert_equal('Baz Changed', model.baz.name)

      @release.changesets.each(&:undo!)
      model.reload

      assert_equal('Test', model.name)
      assert_equal('Bar', model.bars.first.name)
      assert_equal('Baz', model.baz.name)
    end

    def test_activates_with_current_release
      model = Foo.create!(name: 'Test', active: false)
      refute(model.activates_with_current_release?)

      Release.with_current(@release.id) do
        model.active = true
        model.save!

        model.reload
        assert(model.activates_with_current_release?)
      end

      model.reload
      refute(model.activates_with_current_release?)
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
      assert(embedded.changesets.first.changeset['active'])
      assert(embedded.changesets.first.document_path.present?)
    end
  end
end
