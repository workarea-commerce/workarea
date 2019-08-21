module Workarea
  module Search
    class Admin
      class Release < Search::Admin
        def search_text
          "release #{model.name}"
        end

        def jump_to_text
          tmp = model.name.dup

          if model.publish_at.present?
            tmp << " (#{model.publish_at.to_s(:short)})"
          else
            tmp << " (Not scheduled)"
          end

          tmp
        end

        def jump_to_position
          13
        end

        def facets
          super.merge(publishing: model.statuses)
        end

        def as_document
          super.merge(published_at: model.published_at)
        end
      end
    end
  end
end
