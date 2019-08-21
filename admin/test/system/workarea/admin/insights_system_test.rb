require 'test_helper'

module Workarea
  module Admin
    class InsightsSystemTest < SystemTest
      include Admin::IntegrationTest

      # Smoke test to ensure all insights can render and handle blank data
      def test_can_render_insights
        Workarea::Insights::Base.subclasses.each(&:create!)
        visit admin.root_path
      end
    end
  end
end
