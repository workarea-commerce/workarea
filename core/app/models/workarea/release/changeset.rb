module Workarea
  class Release
    class Changeset
      include ApplicationDocument

      field :changeset, type: Hash, default: {}
      field :undo, type: Hash, default: {}

      embeds_many :document_path, class_name: 'Mongoid::DocumentPath::Node'

      belongs_to :release, class_name: 'Workarea::Release', index: true
      belongs_to :releasable, polymorphic: true, index: true, optional: true

      index({ 'document_path.type' => 1, 'document_path.document_id' => 1})

      # Whether these value changes to this field should be included when
      # saving a changeset. Used in building changeset hashes.
      #
      # @param attribute [String]
      # @param old_value [Object]
      # @param new_value [Object]
      #
      # @return [Boolean]
      #
      def self.track_change?(attribute, old_value, new_value)
        !attribute.in?(Workarea.config.untracked_release_changes_fields) &&
          (old_value.present? || new_value.present?)
      end

      # Finds changeset by whether the passed document is in the document
      # path of the changeset. Useful for showing embedded changes in the
      # admin, e.g. showing content block changes as part of the timeline
      # for the content object.
      #
      # @param document [Mongoid::Document]
      # @return [Mongoid::Criteria]
      #
      def self.by_document_path(document)
        where(
          'document_path.type' => document.class.name,
          'document_path.document_id' => document.id.to_s
        )
      end

      # Find changesets by whether the passed class is in the document path of
      # the changeset. Used in the admin for display embedded changesets by
      # parent type, e.g. filtering activity by content and seeing content
      # block changes.
      #
      # @param klass [Class]
      # @return [Mongoid::Criteria]
      #
      def self.by_document_path_type(klass)
        where('document_path.type' => klass.name)
      end

      def changed_fields
        changeset.keys
      end

      # Apply (but do not save) the changes represented by this changeset to
      # the model passed in.
      #
      # @param model [Mongoid::Document]
      #
      def apply_to(model)
        apply_changeset(model, changeset)
      end

      # Make the changes represented by this changeset live. Used when
      # publishing a release.
      #
      # Builds and saves the undo in case that's desired later.
      #
      # @return [Boolean]
      #
      def publish!
        return false if releasable_from_document_path.blank?

        build_undo
        apply_to(releasable_from_document_path)

        releasable_from_document_path.skip_changeset do
          releasable_from_document_path.save!
        end

        save! # saves undo
      end

      # Apply the changes in the undo hash on this changeset and save to make
      # them live. Used when undoing a release.
      #
      # @return [Boolean]
      #
      def undo!
        apply_changeset(releasable_from_document_path, undo)

        releasable_from_document_path.skip_changeset do
          releasable_from_document_path.save!
        end
      end

      private

      def apply_changeset(model, changeset)
        changeset.each do |field, new_value|
          model.send(:attribute_will_change!, field) # required for correct dirty tracking
          model.attributes[field] = new_value
        end
      end

      def releasable_from_document_path
        return @releasable_from_document_path if defined?(@releasable_from_document_path)

        @releasable_from_document_path =
          begin
            Mongoid::DocumentPath.find(document_path)
          rescue Mongoid::Errors::DocumentNotFound
            nil
          end
      end

      def build_undo(model = releasable_from_document_path)
        self.undo = changeset.keys.inject({}) do |memo, key|
          old_value = model.attributes[key]
          new_value = changeset[key]

          if self.class.track_change?(key, old_value, new_value)
            memo[key] = old_value
          end

          memo
        end
      end
    end
  end
end
