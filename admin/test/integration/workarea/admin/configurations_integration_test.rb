require 'test_helper'

module Workarea
  module Admin
    class ConfigurationsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_update
        patch admin.configuration_path,
          params: {
            'configuration' => {
              'allow_shipping_address_po_box' => 'false'
            }
          }

        assert_redirected_to(admin.configuration_path)
        refute(Workarea.config.allow_shipping_address_po_box)
      end
    end
  end
end
