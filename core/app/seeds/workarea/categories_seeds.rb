module Workarea
  class CategoriesSeeds
    def perform
      puts 'Adding categories...'

      rules = [
        { name: 'price', operator: 'greater_than', value: 40 },
        { name: 'price', operator: 'less_than', value: 40 },
        { name: 'search', operator: 'equals', value: '*' },
        { name: 'search', operator: 'equals', value: 'awesome' },
        { name: 'search', operator: 'equals', value: 'intelligent OR sleek' },
        { name: 'available_inventory', operator: 'less_than', value: '25' }
      ]

      Sidekiq::Callbacks.disable do
        Catalog::Category.create!(
          name: 'New',
          default_sort: Sort.newest,
          product_rules: [
            {
              name: 'search',
              operator: 'equals',
              value: 'created_at:[now-30d TO now]'
            }
          ]
        )

        Workarea.config.default_seeds_taxonomy.values.flatten.each do |name|
          Catalog::Category.create!(
            name: name,
            product_rules: [rules.sample],
            default_sort: Search::CategoryBrowse.available_sorts.sample
          )
        end
      end
    end

    # TODO remove in v3.5 as this is no longer used
    def find_unique_name
      department = Faker::Commerce.department(1)
      categories = Catalog::Category.all.to_a

      until categories.select { |c| c.name == department }.empty?
        department = Faker::Commerce.department(2)
      end

      department
    end
  end
end
