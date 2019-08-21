require 'test_helper'

module Workarea
  module Storefront
    class StyleGuidesSystemTest < Workarea::SystemTest
      def test_contains_a_partial_from_the_storefront
        visit storefront.style_guides_path

        within '#settings' do
          click_on 'color-variables'
        end
        assert(page.has_content?('$black'))
      end
    end
  end
end
