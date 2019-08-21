module Workarea
  module Admin::InventoryHelper
    def inventory_policies
      @policy_options ||= Workarea.config.inventory_policies.map do |class_name|
        [class_name.demodulize.titleize, class_name.demodulize.underscore]
      end
    end
  end
end
