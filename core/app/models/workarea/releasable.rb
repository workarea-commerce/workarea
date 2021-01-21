module Workarea
  module Releasable
    extend ActiveSupport::Concern
    include Mongoid::DocumentPath
    include Release::Activation
    include Segmentable

    included do
      field :active, type: Boolean, default: true, localize: Workarea.config.localized_active_fields
      attr_accessor :release_id

      has_many :changesets,
        class_name: 'Workarea::Release::Changeset',
        as: :releasable

      validate :slug_unchanged, on: :update

      define_model_callbacks :save_release_changes
      before_update :handle_release_changes
      after_find :load_release_changes
      after_destroy :destroy_embedded_changesets

      if Workarea.config.localized_active_fields
        I18n.for_each_locale { index("active.#{I18n.locale}" => 1) }
      else
        index(active: 1)
      end
    end

    def changesets_with_children
      criteria = Release::Changeset.or(
        { releasable_type: self.class.name, releasable_id: id }
      )

      embedded_children.each do |child|
        if child.respond_to?(:changesets_with_children)
          criteria.merge!(child.changesets_with_children)
        end
      end

      criteria
    end

    # A hash of changes for being set on the changeset. It's just a filtered
    # version of #changes from Mongoid.
    #
    # @return [Hash]
    #
    def release_changes
      ::Workarea::Release::Changes.new(self).to_h
    end

    def release_originals
      ::Workarea::Release::Changes.new(self).to_originals_h
    end

    # Get a new instance of this model loaded with changes for the release
    # passed in.
    #
    # @return [Releasable]
    #
    def in_release(release)
      if release.blank? && !changed? # No extra work necessary, return a copy
        result = dup
        result.id = id
        result.release_id = nil
        result
      elsif release.present? && !changed? # We don't have to reload from DB, just apply release changes to a copy
        result = dup
        result.id = id
        result.release_id = release.id
        release.preview.changesets_for(self).each { |cs| cs.apply_to(result) }
        result
      else
        Release.with_current(release) do
          Mongoid::QueryCache.uncached { self.class.find(id) }
        end
      end
    end

    # Get a new instance of this model without any release changes. This a new
    # instance without any release changes applied.
    #
    # @return [Releasable]
    #
    def without_release
      in_release(nil)
    end

    # Skip the release changeset for the duration of the block. Used when
    # publishing a changeset, i.e. don't apply/save the release changes since
    # we actually want to publish.
    #
    # @return whatever the block returns
    #
    def skip_changeset
      @_skip_changeset = true
      yield

    ensure
      @_skip_changeset = false
    end

    # Persist a to be recalled for publishing later. This is where changesets
    # make it to the database.
    #
    # Will raise an error if the persistence goes wrong (it shouldn't)
    #
    # @param release_id [String]
    #
    def save_changeset(release)
      return unless release.present?

      changeset = release.changesets.find_or_initialize_by(releasable: self)

      run_callbacks :save_release_changes do
        if changeset.persisted? && release_changes.present?
          changeset.update!(changeset: release_changes, original: release_originals)
        elsif release_changes.present?
          changeset.document_path = document_path
          changeset.changeset = release_changes
          changeset.original = release_originals
          changeset.save!
        elsif changeset.persisted?
          changeset.destroy
        end
      end

      changes.each do |field, change|
        attributes[field] = change.first
      end
    end

    def destroy(*)
      if embedded? && Release.current.present?
        update!(active: false)
      else
        super
      end
    end

    private

    def load_release_changes
      return if readonly? || Release.current.blank? # Documents found with .only cause issues

      Release.current.preview.changesets_for(self).each { |c| c.apply_to(self) }
      self.release_id = Release.current.id
    end

    def handle_release_changes
      save_changeset(Release.current) unless @_skip_changeset
    end

    def destroy_embedded_changesets
      Release::Changeset.by_document_path(self).destroy_all
    end

    def slug_unchanged
      if Release.current.present? && changes['slug'].present?
        errors.add(:slug, 'cannot be changed for releases')
      end
    end
  end
end
