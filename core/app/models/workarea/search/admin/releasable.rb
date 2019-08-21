module Workarea
  module Search
    class Admin
      module Releasable
        def facets
          super.merge(upcoming_changes: upcoming_release_ids_with_changesets)
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
          model.changesets.any_in(release_id: upcoming_release_ids)
        end

        def content_changesets
          return [] unless model.is_a?(Contentable)

          Workarea::Content.for(model)
            .changesets
            .any_in(release_id: upcoming_release_ids)
        end

        def upcoming_release_ids
          @upcoming_release_ids ||= Workarea::Release.upcoming.map(&:id)
        end
      end
    end
  end
end
