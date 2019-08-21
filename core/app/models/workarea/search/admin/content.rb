module Workarea
  module Search
    class Admin
      # This class exists to represent system content (as opposed to content
      # pages defined in Content::Page). Content will only get indexed in the
      # Admin index in this case.
      #
      class Content < Search::Admin
        include Admin::Releasable

        def should_be_indexed?
          model.system?
        end

        def type
          'system_page'
        end

        def jump_to_text
          model.name
        end

        def jump_to_position
          6
        end

        def jump_to_route_helper
          'content_path'
        end

        def search_text
          "system content page #{model.name}"
        end
      end
    end
  end
end
