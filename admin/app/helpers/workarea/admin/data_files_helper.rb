module Workarea
  module Admin
    module DataFilesHelper
      def generic_admin_search_query_id(options)
        AdminSearchQueryWrapper.new(options).to_gid_param
      end
    end
  end
end
