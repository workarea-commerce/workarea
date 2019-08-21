module Workarea
  module Search
    class Storefront
      class Search < Storefront
        def id
          CGI.escape("#{type}-#{model.query_id}")
        end

        def content
          { name: model.query_string }
        end

        def slug
          model.query_string.try(:parameterize)
        end

        def active
          { now: true }
        end

        def type
          'search'
        end
      end
    end
  end
end
