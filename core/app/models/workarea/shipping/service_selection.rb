module Workarea
  class Shipping
    class ServiceSelection
      include ApplicationDocument

      field :carrier, type: String
      field :name, type: String
      field :service_code, type: String
      field :tax_code, type: String

      embedded_in :shipping, class_name: 'Workarea::Shipping'
      validates :name, presence: true
    end
  end
end
