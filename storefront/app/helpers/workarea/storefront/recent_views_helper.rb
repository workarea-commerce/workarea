module Workarea
  module Storefront
    module RecentViewsHelper
      def recent_view_content(config)
        { '_method' => 'patch' }.merge(config).to_json
      end
    end
  end
end
