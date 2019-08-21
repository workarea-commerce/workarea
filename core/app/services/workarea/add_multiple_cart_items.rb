module Workarea
  class AddMultipleCartItems
    def initialize(order, items_params = [])
      @order = order
      @items_params = items_params
    end

    def perform
      items.all?(&:save)
    end

    def perform!
      return false unless items.all?(&:valid?)
      perform
    end

    def items
      @items ||= @items_params.map { |params| Item.new(@order, params) }
    end
  end
end
