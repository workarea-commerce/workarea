module Workarea
  class AnonymizeUserData
    include Sidekiq::Worker

    def perform(request_id)
      deletion_request = Email::DeletionRequest.find(request_id)
      @anon_email = "anonymized_#{SecureRandom.hex(10)}@#{SecureRandom.hex(3)}.#{SecureRandom.hex(2)}"

      orders = Order.where(email: deletion_request.email).to_a
      return if orders_in_progress?(orders)
      orders.each(&method(:anonymize_order))

      user = User.find_by_email(deletion_request.email)
      anonymize_user(user) if user.present?

      profiles = Payment::Profile.where(email: deletion_request.email).to_a
      profiles.each(&method(:anonymize_payment_profile))

      metrics = Metrics::User.find(deletion_request.email) rescue nil
      anonymize_user_metrics(metrics) if metrics.present?
      anonymize_insights(deletion_request.email)

      Storefront::DeletionMailer.complete(deletion_request.email).deliver_later
      deletion_request.complete!(@anon_email)
    end

    private

    def orders_in_progress?(orders)
      fulfillments = Fulfillment.in(id: orders.map(&:id)).to_a
      fulfillments.any? { |f| f.pending_items.present? }
    end

    def anonymize_user(user)
      user.email = @anon_email
      user.first_name = 'Anonymized'
      user.last_name = 'User'
      user.addresses = []
      user.save!
    end

    def anonymize_payment_profile(profile)
      profile.email = @anon_email
      profile.credit_cards = []
      profile.save!
    end

    def anonymize_order(order)
      shippings = Shipping.by_order(order.id)
      shippings.each do |shipping|
        shipping.address.update!(anonymous_address(shipping.address))
      end

      payment = Payment.find(order.id) rescue nil
      payment.address.update!(anonymous_address(payment.address)) if payment.present?

      order.update!(email: @anon_email, ip_address: nil)
    end

    def anonymous_address(address)
      {
        first_name: 'Anonymized',
        last_name: 'User',
        street: '1 Anonymized St.',
        street_2: nil,
        company: nil,
        phone_number: address.phone_number.to_s.gsub('\d', rand(9).to_s),
        phone_extension: nil
      }
    end

    def anonymize_user_metrics(metrics)
      new_metric = metrics.dup.tap { |m| m.id = @anon_email }
      new_metric.save!
      metrics.destroy!
    end

    def anonymize_insights(email)
      Insights::Base
        .subclasses
        .select { |i| i.dashboards.include?('people') }
        .each do |klass|
          klass.all.each do |insight|
            insight.results.each do |result|
              result['_id'] = @anon_email if result['_id'] == email
            end
            insight.save! if insight.changed?
          end
        end
    end
  end
end
