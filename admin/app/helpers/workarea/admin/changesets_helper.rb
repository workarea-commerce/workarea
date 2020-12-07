module Workarea
  module Admin::ChangesetsHelper
    def changeset_icon(changeset, options = {})
      type = changeset.root.model_name.element
      inline_svg_tag(releasable_icon_path(type), options)
    end

    def releaseable_icon(model, options = {})
      type = model.model_name.element
      inline_svg(releasable_icon_path(type), options)
    end

    def releasable_icon_path(type)
      default = 'workarea/admin/icons/release.svg'
      return default unless type.present?

      path = Workarea.config.releasable_icons[type.to_sym] ||
             "workarea/admin/icons/#{type}.svg"

      Rails.application.assets.find_asset(path).present? ? path : default
    end
  end
end
