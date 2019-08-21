module Workarea
  module Search
    class Help
      include Elasticsearch::Document

      def as_document
        {
          id: model.id,
          name: model.name,
          facets: { category: model.category },
          body: model.body,
          created_at: model.created_at
        }
      end
    end
  end
end
