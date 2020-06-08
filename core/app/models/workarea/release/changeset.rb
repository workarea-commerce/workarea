# This fixes Release::Changes == Mongoid::AuditLog::Changes in development
require_dependency 'workarea/release/changes'

module Workarea
  class Release
    class Changeset
      include ApplicationDocument

      field :changeset, type: Hash, default: {}
      field :original, type: Hash, default: {}
      field :undo, type: Hash, default: {} # TODO deprecated, remove in v3.6

      embeds_many :document_path, class_name: 'Mongoid::DocumentPath::Node'

      belongs_to :release, class_name: 'Workarea::Release', index: true
      belongs_to :releasable, polymorphic: true, index: true, optional: true

      index({ 'document_path.type' => 1, 'document_path.document_id' => 1 })
      index('changeset.product_ids' => 1)
      index('original.product_ids' => 1)
      index('releasable_type' => 1, 'releasable_id' => 1)

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

      def includes_change?(key, new_value)
        changed_fields.include?(key) && changeset[key] == new_value
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
      # @return [Boolean]
      #
      def publish!
        return false if releasable_from_document_path.blank?

        apply_to(releasable_from_document_path)

        releasable_from_document_path.skip_changeset do
          releasable_from_document_path.save!
        end

        save!
      end

      def build_undo(attributes = {})
        # Ensure the appropriate Release.current for building the undo
        # This can be nil, which is essential if there is some other arbitrary
        # release as Release.current.
        Release.with_current(release.previous) do
          releasable_from_document_path.reload

          Changeset.new(
            attributes.reverse_merge(
              releasable: releasable,
              document_path: document_path,
              changeset: changeset.keys.inject({}) do |memo, key|
                old_value = releasable_from_document_path.attributes[key]
                new_value = changeset[key]

                memo[key] = old_value if Changes.tracked_change?(key, old_value, new_value)
                memo
              end
            )
          )
        end

      ensure
        releasable_from_document_path.reload
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

      private

      def apply_changeset(model, changeset)
        changeset.each do |field, new_value|
          model.send(:attribute_will_change!, field) # required for correct dirty tracking
          model.attributes[field] = new_value
        end
      end
    end
  end
end
