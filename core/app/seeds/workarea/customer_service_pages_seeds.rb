module Workarea
  class CustomerServicePagesSeeds
    def perform
      puts 'Adding auxiliary pages...'

      Content::Page.create!(
        name: 'Shipping Policy',
        tag_list: 'customer service'
      )

      Content::Page.create!(
        name: 'Privacy Policy',
        tag_list: 'customer service'
      )

      Content::Page.create!(
        name: 'Returns',
        tag_list: 'customer service'
      )

      Content::Page.create!(
        name: 'Credit Card Security Code'
      )

      internal_error_page = Content.for('Internal Server Error')
      internal_error_page.save!

      not_found_content = Content.for('Not Found')
      not_found_content.blocks.build(
        type: :html,
        data: {
          html: '<p>Try searching or <a href="/">start at the home page</a>.</p>'
        }
      )
      not_found_content.save!
    end
  end
end
