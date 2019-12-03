module Workarea
  module Admin::TaxonsHelper
    def navigable_types
      [
        [
          t('workarea.admin.navigation_taxons.types.page'),
          'page',
          { data: { new_navigation_taxon_endpoint: content_pages_path(format: :json) } }
        ],
        [
          t('workarea.admin.navigation_taxons.types.category'),
          'category',
          { data: { new_navigation_taxon_endpoint: catalog_categories_path(format: :json) } }
        ],
        [
          t('workarea.admin.navigation_taxons.types.product'),
          'product',
          { data: { new_navigation_taxon_endpoint: catalog_products_path(format: :json) } }
        ]
      ]
    end

    def taxonomy_select(name, current = nil)
      current = Navigation::Taxon.where(id: current).first

      content_tag(
        :div,
        hidden_field_tag(name, current.try(:id)) +
          render(
            'workarea/admin/navigation_taxons/select',
            taxon: current
          ) +
          content_tag(
            :button,
            t('workarea.admin.navigation_taxons.select.reset_button'),
            value: 'reset',
            class: 'button button--small'
          ),
        data: { taxon_select: '' }
      )
    end

    def taxon_icon(taxon, options = {})
      if taxon.resource_name.category?
        inline_svg_tag('workarea/admin/icons/categories.svg', options)
      elsif taxon.resource_name.page?
        inline_svg_tag('workarea/admin/icons/pages.svg', options)
      else
        inline_svg_tag('workarea/admin/icons/link.svg', options)
      end
    end

    def taxonomy_insert(taxon)
      content_tag(
        :div,
        render(
          'workarea/admin/navigation_taxons/insert',
          parent: taxon.parent || Navigation::Taxon.root,
          taxon: taxon
        ),
        data: { taxon_insert: '' }
      )
    end
  end
end
