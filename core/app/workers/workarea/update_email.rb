module Workarea
  class UpdateEmail
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { User => :update, with: -> { [id, changes] } }
    )

    def perform(id, changes)
      return unless changes['email'].present? && changes['email'].first.present?

      old_email, new_email = changes['email']
      update_payment_profile(id, old_email, new_email)
      update_metrics(old_email, new_email)
    end

    def update_payment_profile(id, old_email, new_email)
      user = User.find(id)
      user.email = old_email # set old email so we lookup by old email value

      Payment::Profile.update_email(PaymentReference.new(user), new_email)
    end

    def update_metrics(old_email, new_email)
      old_metrics = Metrics::User.find(old_email) rescue nil
      return if old_metrics.blank?

      new_metrics = Metrics::User.find_or_initialize_by(id: new_email)
      new_metrics.merge!(old_metrics)
    end
  end
end
