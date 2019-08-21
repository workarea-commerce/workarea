require 'test_helper'

module Workarea
  module Admin
    class StyleGuidesSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_contains_a_partial_from_the_admin
        visit admin.style_guides_path

        within '#settings' do
          click_on 'color-variables'
        end
        assert(page.has_content?('$off-black'))
      end
    end
  end
end
