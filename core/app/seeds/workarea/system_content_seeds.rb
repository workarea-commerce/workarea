module Workarea
  class SystemContentSeeds
    def perform
      puts 'Adding system content...'
      add_home_page
      add_layout_content
      add_checkout
      add_search
      add_contact_us
      add_offline
    end

    private

    def add_home_page
      content = Content.for('Home Page')
      content.blocks.build(type: 'hero', data: Content::BlockType.find(:hero).defaults)
      content.blocks.build(type: 'category_summary', data: Content::BlockType.find(:category_summary).defaults)
      content.blocks.build(type: 'video_and_text', data: Content::BlockType.find(:video_and_text).defaults)
      content.blocks.build(type: 'product_insights', data: Content::BlockType.find(:product_insights).defaults)
      content.blocks.build(type: 'social_networks', data: Content::BlockType.find(:social_networks).defaults)
      content.save!
    end

    def add_layout_content
      content = Content.for('Layout')
      content.blocks.create!(
        area: 'header_promo',
        type: 'html',
        data: { html: '<p>Get free shipping on any order! Use the promo code FREESHIPPING at checkout.</p>' }
      )
      content.blocks.create!(
        area: 'footer_navigation',
        type: 'taxonomy',
        data: {
          header: 'Customer Service',
          show_starting_taxon: false,
          start: Navigation::Taxon
                  .where(name: 'Customer Service')
                  .first
                  .id
        }
      )
      content.blocks.create!(
        area: 'privacy_popup',
        type: 'html',
        data: {
          html: <<~HTML
            <p>
              We use cookies to provide services, make offers, and improve your experience.
              Cookies are required to use the site. If you'd like to learn more, please read
              <a href="#{Storefront::Engine.routes.url_helpers.page_path(id: 'privacy-policy')}">
              the privacy policy</a>.
            </p>
          HTML
        }
      )
    end

    def add_checkout
      Content.for('checkout').blocks.create!(
        area: 'confirmation',
        type: 'html',
        data: { html: '<p>Thanks for your order!</p>' }
      )
    end

    def add_search
      Content.for('search').blocks.create!(
        area: 'no_results',
        type: 'html',
        data: {
          html: <<-eos.strip_heredoc
            <h3>Suggestions:</h3>
            <ul>
              <li>Make sure all words are spelled correctly.</li>
              <li>Try different keywords.</li>
              <li>Try more general keywords.</li>
            </ul>
          eos
        }
      )
    end

    def add_contact_us
      Content.for('contact_us').blocks.create!(
        type: 'html',
        data: { html: '<p>We will get back to you as soon as possible.</p>' }
      )
    end

    def add_offline
      Content.for('offline').blocks.create!(
        type: 'html',
        data: {
          html: <<-eos.strip_heredoc
            <h1>It looks like you've lost your Internet connection</h1>
            <p>You may need to reconnect to Wi-Fi.</p>
          eos
        }
      )
    end
  end
end
