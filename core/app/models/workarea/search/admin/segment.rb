module Workarea
  module Search
    class Admin
      class Segment < Search::Admin
        def type
          'segment'
        end

        def search_text
          "segment #{model.name}"
        end

        def jump_to_text
          model.name
        end
      end
    end
  end
end
