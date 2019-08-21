module Workarea
  module Admin
    module FacetsHelper
      def facet_value_display_name(facet, value)
        if facet.system_name == 'tags'
          value
        elsif facet.system_name == 'upcoming_changes'
          Release.where(id: value).pluck(:name).first
        else
          value.titleize
        end
      end
    end
  end
end
