module Workarea
  module Admin::ChangesetsHelper
    def changeset_icon(changeset, options = {})
      type = changeset.root.model_name.element

      inline_svg_tag(
        releasable_icon_path(type),
        options.reverse_merge(fallback: default_releasable_icon_path)
      )
    end

    def releaseable_icon(model, options = {})
      type = model.model_name.element
      inline_svg_tag(
        releasable_icon_path(type),
        options.reverse_merge(fallback: default_releasable_icon_path)
      )
    end

    def releasable_icon_path(type)
      return default_releasable_icon_path unless type.present?

      Workarea.config.releasable_icons[type.to_sym] ||
      "workarea/admin/icons/#{type}.svg"
    end

    def default_releasable_icon_path
      'workarea/admin/icons/release.svg'
    end
  end
end
