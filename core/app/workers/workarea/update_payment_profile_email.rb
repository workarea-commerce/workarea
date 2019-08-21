module Workarea
  class UpdatePaymentProfileEmail
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { User => :update, with: -> { [id, changes] } }
    )

    def perform(id, changes)
      if changes['email'].present? && changes['email'].first.present?
        old_email = changes['email'].first
        new_email = changes['email'].last

        user = User.find(id)
        user.email = old_email # set old email so we lookup by old email value

        Payment::Profile.update_email(PaymentReference.new(user), new_email)
      end
    end
  end
end
