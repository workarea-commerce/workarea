module Workarea
  module ProductList
    extend ActiveSupport::Concern

    included do
      embeds_many :product_rules,
        class_name: 'Workarea::ProductRule',
        inverse_of: :product_list
    end
  end
end
