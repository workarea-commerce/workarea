module Workarea
  class CustomerServiceNavigationSeeds
    def perform
      puts 'Adding customer service navigation...'

      content = Navigation::Taxon.create!(
        name: 'Customer Service',
        position: 9999
      )

      Content::Page.tagged_with('customer service').each do |page|
        content.children.create!(navigable: page)
      end
    end
  end
end
