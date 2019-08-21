module Workarea
  class BrowsingPagesSeeds
    def perform
      puts 'Adding browsing pages...'

      Workarea.config.default_seeds_taxonomy.each do |top_level, children|
        page = Content::Page.create!(name: top_level, tag_list: 'browsing')
        content = Content.for(page)

        children.each do |category|
          content.blocks.build(
            type: :category_summary,
            data: { category: Catalog::Category.find_by(name: category).id }
          )
        end

        content.save!
      end
    end

    # TODO remove in v3.5 as this is no longer used
    def find_unique_name
      department = Faker::Commerce.department(1)
      pages = Content::Page.all.to_a

      until pages.select { |p| p.name == department }.empty?
        department = Faker::Commerce.department(1)
      end

      department
    end
  end
end
