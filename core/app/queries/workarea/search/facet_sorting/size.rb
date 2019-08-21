module Workarea
  module Search
    class FacetSorting
      class Size
        def self.call(name, results)
          Hash[results.sort_by { |key, _| [sort.index(key) || 999, key] }]
        end

        def self.sort
          Workarea.config.search_facet_size_sort
        end
      end
    end
  end
end
