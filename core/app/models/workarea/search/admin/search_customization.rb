module Workarea
  module Search
    class Admin
      class SearchCustomization < Search::Admin
        include Admin::Releasable

        def type
          'search_customization'
        end

        def search_text
          model.name
        end

        def jump_to_text
          "#{model.id} - #{model.name}"
        end

        def jump_to_position
          99
        end
      end
    end
  end
end
