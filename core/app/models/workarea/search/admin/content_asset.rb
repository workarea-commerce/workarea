module Workarea
  module Search
    class Admin
      class ContentAsset < Search::Admin
        def status
          'active'
        end

        def search_text
          [
            'content asset',
            model.name,
            model.file_name,
            model.tag_list
          ].join(' ')
        end

        def jump_to_text
          "#{model.name} - #{model.file_name}"
        end

        def jump_to_position
          8
        end

        def facets
          super.merge(file_type: model.type, image_dimensions: image_dimensions)
        end

        def should_be_indexed?
          !model.image_placeholder? &&
            !model.open_graph_placeholder? &&
            !model.favicon_placeholder?
        end

        private

        def image_dimensions
          if model.image? && model.format != 'svg'
            "#{model.width} x #{model.height}"
          end
        end
      end
    end
  end
end
