module Workarea
  class OrderReminder
    include Sidekiq::Worker

    def perform(*)
      # This while loop is necessary because
      # we're changing the count as we go
      while Order.need_reminding.any?
        Order.need_reminding.each_by(50) do |order|
          order.mark_as_reminded!
          Storefront::OrderMailer.reminder(order.id).deliver_now
        end
      end
    end
  end
end
