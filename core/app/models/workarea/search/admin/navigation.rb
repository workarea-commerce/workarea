module Workarea
  module Search
    class Admin
      class Navigation < Search::Admin
        def keywords
          []
        end

        def id
          model.first
        end

        def type
          'Admin Pages'
        end

        def name
          model.first
        end

        def search_text
          model.first
        end

        def jump_to_text
          model.first
        end

        def jump_to_route_helper
          model.last
        end

        def jump_to_param
        end

        def jump_to_position
          0
        end

        def created_at
          Time.current
        end

        def updated_at
          Time.current
        end
      end
    end
  end
end
