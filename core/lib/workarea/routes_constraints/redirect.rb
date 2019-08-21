module Workarea
  module RoutesConstraints
    class RedirectConstraint
      def matches?(request)
        request.path != '/sitemap.xml'        || # ignore root sitemap
        request.path !~ /\A\/sitemaps\/.*\z/i || # ignore all sitemaps
        request.path !~ /\A.*\.(jpe?g|png|gif|swf|css|js|xml)\z/i # ignore assets
      end
    end
  end
end
