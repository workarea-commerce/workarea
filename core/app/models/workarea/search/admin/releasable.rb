module Workarea
  module Search
    class Admin
      module Releasable
        def facets
          super.merge(
            upcoming_changes: upcoming_release_ids_with_changesets,
            active_by_segment: active_segment_ids
          )
        end

        def status
          if model.active?
            'active'
          else
            'inactive'
          end
        end

        private

        def upcoming_release_ids_with_changesets
          (model_changesets + content_changesets).map(&:release_id)
        end

        def model_changesets
          Workarea::Release::Changeset
            .by_document_path(model)
            .any_in(release_id: upcoming_release_ids)
        end

        def content_changesets
          return [] unless content.present?
          content.changesets.any_in(release_id: upcoming_release_ids)
        end

        def upcoming_release_ids
          @upcoming_release_ids ||= Workarea::Release.upcoming.map(&:id)
        end

        def content
          return unless model.is_a?(Contentable)
          @content ||= Workarea::Content.for(model)
        end

        def active_segment_ids
          result = model.active_segment_ids_with_children +
            (content&.active_segment_ids_with_children || [])

          result.uniq
        end
      end
    end
  end
end
