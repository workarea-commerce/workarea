module Workarea
  module ShippingCarrierViewModel
    def carrier
      carrier_info.first if model.present?
    end

    def tracking_link
      "#{carrier_info.last}#{model.tracking_number}" if model.present?
    end

    private

    def carrier_info
      return [] unless model.tracking_number.present?

      tuple = tracking_links.detect { |r, _| r.match(model.tracking_number) }
      tuple ? tuple.last : []
    end

    def tracking_links
      Workarea.config.shipping_service_tracking_links
    end
  end
end
