module Workarea
  module Search
    class Admin
      class ContentPage < Search::Admin
        include Admin::Releasable

        def type
          'content_page'
        end

        def jump_to_text
          model.name
        end

        def jump_to_position
          7
        end

        def search_text
          "content page #{model.name} #{model.tag_list}"
        end
      end
    end
  end
end
