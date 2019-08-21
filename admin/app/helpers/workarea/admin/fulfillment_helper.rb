module Workarea
  module Admin::FulfillmentHelper
    def fulfillment_policies
      @fullfillment_policies ||=
        Workarea.config.fulfillment_policies.map do |class_name|
          [class_name.demodulize.titleize, class_name.demodulize.underscore]
        end
    end
  end
end
