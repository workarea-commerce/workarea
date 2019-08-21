module Workarea
  class BrowseNavigationSeeds
    def perform
      puts 'Adding browsing navigation...'

      if new = Catalog::Category.find_by(name: 'New') rescue nil
        taxon = Navigation::Taxon.root.children.create!(navigable: new)
        menu = Navigation::Menu.create!(taxon: taxon)
      end

      Workarea.config.default_seeds_taxonomy.each do |top_level, children|
        page = Content::Page.find_by(name: top_level)
        categories = Catalog::Category.any_in(name: children)
        taxon = Navigation::Taxon.root.children.create!(navigable: page)
        menu = Navigation::Menu.create!(taxon: taxon)
        next if categories.blank?

        content = Content.for(menu)
        content.blocks.create!(
          type: 'taxonomy',
          data: { start: taxon.id, show_starting_taxon: false }
        )

        categories.each do |category|
          taxon.children.create!(navigable: category)
        end
      end
    end
  end
end
