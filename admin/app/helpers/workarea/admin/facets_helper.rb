module Workarea
  module Admin
    module FacetsHelper
      def facet_value_display_name(facet, value)
        if facet.system_name == 'tags'
          value
        elsif facet.system_name == 'upcoming_changes'
          Release.where(id: value).pluck(:name).first
        elsif facet.system_name == 'active_by_segment'
          Segment.where(id: value).pluck(:name).first ||
          t('workarea.admin.segments.missing', id: value[0..4])
        else
          value.titleize
        end
      end
    end
  end
end
