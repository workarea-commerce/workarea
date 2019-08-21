module Workarea
  class Storefront::CreditCardViewModel < ApplicationViewModel
    def selected?
      model.id.to_s == options[:selected].to_s
    end
  end
end
