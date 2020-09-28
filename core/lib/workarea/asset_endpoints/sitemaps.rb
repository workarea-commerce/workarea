module Workarea
  module AssetEndpoints
    class Sitemaps < Base
      def result
        Workarea::Sitemap.find_by_index(params[:index]).try(:file)
      end
    end
  end
end
