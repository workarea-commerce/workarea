module Workarea
  class Login
    attr_reader :user, :current_order

    def initialize(user, current_order)
      @user = user
      @current_order = current_order
    end

    def previous_order
      @previous_order ||= Order
                            .carts
                            .where(user_id: user.id)
                            .order_by(:created_at.desc)
                            .first
    end

    def perform
      user.login_success!

      if previous_order &&
           !previous_order.checking_out? &&
           previous_order.items.present? &&
           previous_order != current_order

        OrderMerge.new(previous_order).merge(current_order)
        @current_order = previous_order
      elsif current_order.persisted?
        if current_order.started_checkout?
          Checkout.new(current_order).continue_as(user)
        else
          current_order.update_attributes!(user_id: user.id)
        end
      end

      self
    end
  end
end
