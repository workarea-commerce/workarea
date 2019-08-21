module Workarea
  class Payment
    class Transaction
      include ApplicationDocument

      field :tender_id, type: String
      field :action, type: String
      field :amount, type: Money
      field :success, type: Boolean, default: false
      field :response, type: ActiveMerchant::Billing::Response
      field :cancellation, type: ActiveMerchant::Billing::Response
      field :canceled_at, type: Time

      belongs_to :payment,
        class_name: 'Workarea::Payment',
        index: true,
        touch: true

      belongs_to :reference,
        class_name: 'Workarea::Payment::Transaction',
        optional: true

      validates :amount, presence: true
      validates :action, presence: true

      default_scope -> { desc(:created_at) }

      scope :successful, -> { where(success: true) }
      scope :authorizes, -> { where(action: 'authorize') }
      scope :captures, -> { where(action: 'capture') }
      scope :captures_or_purchased, -> { where(:action.in => %w(capture purchase)) }
      scope :refunds, -> { where(action: 'refund') }
      scope :not_canceled, -> { where(canceled_at: nil) }

      index({ created_at: -1 })
      index({ tender_id: 1, action: 1, created_at: 1 })
      index({ success: 1, action: 1, reference_id: 1, created_at: -1 })
      index({ action: 1 })
      index(
        {
          tender_id: 1,
          success: 1,
          action: 1,
          canceled_at: 1,
          created_at: -1
        },
        {
          name: 'tender_amounts_index'
        }
      )

      before_validation :set_success
      after_save :touch_reference

      # For compatibility with admin features, models must respond to this method
      #
      # @return [String]
      #
      def name
        action
      end

      def success?
        response.try(:success?) || super
      end

      def failure?
        !success?
      end

      def canceled?
        !!canceled_at
      end

      def authorize?
        action == 'authorize'
      end

      def capture?
        action == 'capture'
      end

      def tender=(val)
        self.tender_id = val.try(:id)
        @tender = val
      end

      def tender
        return @tender if defined?(@tender)
        @tender = payment.tenders.detect { |t| t.id.to_s == tender_id }
      end

      def captures
        self.class.successful.captures.where(reference_id: id)
      end

      def captured_amount
        return amount if %w(purchase capture).include?(action)
        captures.not_canceled.to_a.sum(&:amount)
      end

      def complete!(options = {})
        operation(options).complete!
        with(write: { w: "majority", j: true }) { save! }
      end

      def cancel!(options = {})
        operation(options).cancel!
        self.canceled_at = Time.current
        with(write: { w: "majority", j: true }) { save! }
      end

      def message
        if success?
          response.message
        elsif failure? && response.present? && response.message.present?
          I18n.t('workarea.payment.transaction_failure', message: response.message)
        else
          I18n.t('workarea.payment.transaction_error')
        end
      end

      private

      def set_success
        self.success = response.success? if response.present?
        true # to ensure setting is to false doesn't abort the persistence
      end

      def touch_reference
        reference.try(:touch)
      end

      def operation(options)
        klass = "Workarea::Payment::#{operation_type}::#{tender_type}".constantize
        klass.new(tender, self, options)
      end

      def operation_type
        action.camelize
      end

      def tender_type
        tender.class.name.demodulize
      end
    end
  end
end
