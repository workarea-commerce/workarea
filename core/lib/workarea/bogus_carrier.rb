module Workarea
  class BogusCarrier < ActiveShipping::Workarea
    MESSAGE = 'SUCCESS - 0000 Success'

    def create_shipment(origin, destination, packages, options = {})
      labels = [ActiveShipping::Label.new(generate_tracking_number, image)]
      ActiveShipping::LabelResponse.new(true, MESSAGE, {}, labels: labels)
    end

    def generate_tracking_number
      "1ZX1A#{Array.new(13) { rand(0..9) }.join}"
    end

    def image
      IO.read(Core::Engine.root.join('test', 'fixtures', 'label.png'))
    end
  end
end
