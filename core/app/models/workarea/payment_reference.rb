module Workarea
  class PaymentReference
    attr_reader :user, :order

    def initialize(user, order = nil)
      @user = user
      @order = order
    end

    def email
      (@user.try(:email) || @order.try(:email)).try(:downcase)
    end

    def id
      @user.try(:id) || @order.try(:user_id).presence || @order.try(:id)
    end
  end
end
