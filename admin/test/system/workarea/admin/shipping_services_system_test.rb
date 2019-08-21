require 'test_helper'

module Workarea
  module Admin
    class ShippingServicesSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_managing_shipping_services
        visit admin.shipping_services_path

        click_link 'add_shipping_service'
        fill_in 'service[name]', with: 'Testing Shipping Service'
        fill_in 'new_rates[][price]', with: '7.00'
        click_button 'create_shipping_service'

        click_link 'Testing Shipping Service'
        fill_in 'service[name]', with: 'Edited Shipping Service'
        click_button 'save_shipping_service'

        assert(page.has_content?('Edited Shipping Service'))

        click_link 'Edited Shipping Service'
        click_link t('workarea.admin.actions.delete')

        visit admin.shipping_services_path
        assert(page.has_no_content?('Edited Shipping Service'))
      end
    end
  end
end
