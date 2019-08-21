module Workarea
  module Releasable
    extend ActiveSupport::Concern
    include Mongoid::DocumentPath

    included do
      field :active, type: Boolean, default: true, localize: Workarea.config.localized_active_fields

      has_many :changesets,
        class_name: 'Workarea::Release::Changeset',
        as: :releasable

      validate :slug_unchanged, on: :update

      scope :active, -> { where(active: true) }
      scope :inactive, -> { where(active: false) }

      around_create :save_activate_with
      before_update :save_release_changes
      after_find :load_release_changes
      after_destroy :destroy_embedded_changesets

      if Workarea.config.localized_active_fields
        I18n.for_each_locale { index("active.#{I18n.locale}" => 1) }
      else
        index(active: 1)
      end

      attr_accessor :activate_with
    end

    # A hash of changes for being set on the changeset. It's just a filtered
    # version of #changes from Mongoid.
    #
    # @return [Hash]
    #
    def release_changes
      changes.keys.inject({}) do |memo, key|
        old_value, new_value = *changes[key]

        if Release::Changeset.track_change?(key, old_value, new_value)
          memo[key] = new_value
        end

        memo
      end
    end

    # Skip the release changeset for the duration of the block. Used when
    # publishing a changeset, i.e. don't apply/save the release changes since
    # we actually want to publish.
    #
    # @return whatever the block returns
    #
    def skip_changeset
      @_skip_changeset = true
      result = yield
      @_skip_changeset = false
      result
    end

    # Whether this model becomes active with the current release. Used for some
    # funny business when displaying content blocks in the admin. :(
    #
    # @return [Boolean]
    #
    def activates_with_current_release?
      return false if Release.current.blank?
      active? && active_changed? && !was_active?
    end

    # Persist a to be recalled for publishing later. This is where changesets
    # make it to the database.
    #
    # Will raise an error if the persistence goes wrong (it shouldn't)
    #
    # @param release_id [String]
    #
    def save_changeset(release_id)
      return unless release_id.present?

      changeset = Release::Changeset.find_or_initialize_by(
        releasable_id: id,
        releasable_type: self.class.name,
        release_id: release_id
      )

      if changeset.persisted? && release_changes.present?
        # This is to avoid triggering callbacks - calling #save on a
        # persisted Changeset is causing Mongoid to run callbacks on the
        # parent document, which resets the changeset changes to previous
        # values, not allowing updates to a changeset. #set merges a hash
        # field's new value into the old, so a call to #unset is necessary
        # to ensure any removed changes are properly deleted.
        #
        # TODO check in with this before v3 to see if Mongoid has fixed or
        # open a Mongoid PR
        #
        changeset.unset(:changeset)
        changeset.set(changeset: release_changes)
      elsif release_changes.present?
        changeset.document_path = document_path
        changeset.changeset = release_changes
        changeset.save!
      elsif changeset.persisted?
        changeset.destroy
      end

      changes.each do |field, change|
        attributes[field] = change.first
      end
    end

    def releasable?
      true
    end

    private

    def load_release_changes
      # Documents found with .only cause issues
      return if readonly? || Release.current.blank?

      changeset = changesets.find_by(release_id: Release.current.id) rescue nil
      changeset.apply_to(self) if changeset.present?
    end

    def save_release_changes
      save_changeset(Release.current.try(:id)) unless @_skip_changeset
    end

    def destroy_embedded_changesets
      Release::Changeset.by_document_path(self).destroy_all
    end

    def slug_unchanged
      if Release.current.present? && changes['slug'].present?
        errors.add(:slug, 'cannot be changed for releases')
      end
    end

    def save_activate_with
      self.active = false if activate_with?
      yield
      create_activation_changeset(activate_with) if activate_with?
    end

    def activate_with?
      activate_with.present? && BSON::ObjectId.legal?(activate_with)
    end

    def create_activation_changeset(release_id)
      set = changesets.find_or_initialize_by(release_id: release_id)
      set.document_path = document_path

      active_changeset = if Workarea.config.localized_active_fields
        { 'active' => { I18n.locale => true } }
      else
        { 'active' => true }
      end

      set.changeset = active_changeset
      set.save!
    end

    def was_active?
      (Workarea.config.localized_active_fields && active_was[I18n.locale]) ||
        (!Workarea.config.localized_active_fields && active_was)
    end
  end
end
