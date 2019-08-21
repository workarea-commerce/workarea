module Workarea
  module Admin::ChangesetsHelper
    def changeset_icon(changeset, options = {})
      type = changeset.root.model_name.element
      inline_svg(icon_path(type), options)
    end

    private

    def icon_path(type)
      Workarea.config.releasable_icons[type.to_sym] || "workarea/admin/icons/#{type}.svg"
    end
  end
end
