module Workarea
  module Admin
    class TransactionViewModel < ApplicationViewModel
      def order_id
        model.payment_id
      end

      def payment_type
        if model.tender.present?
          model.tender.class.name.demodulize.underscore
        else
          t('workarea.admin.payment_transactions.tender.missing')
        end
      end

      def payment_title
        if model.tender.present?
          payment_type.titleize
        else
          t('workarea.admin.payment_transactions.tender.title')
        end
      end

      def status
        if canceled?
          t('workarea.admin.payment_transactions.status.canceled')
        elsif success?
          t('workarea.admin.payment_transactions.status.success')
        else
          t('workarea.admin.payment_transactions.status.failure')
        end
      end

      def can_be_captured?
        model.action == 'authorize'
      end
    end
  end
end
