module Workarea
  module Admin
    class OrderTimelineViewModel < ApplicationViewModel
      class Entry
        attr_reader :slug, :occured_at, :modifier, :model

        def initialize(slug, occured_at, modifier, model)
          @slug = slug
          @occured_at = occured_at
          @modifier = modifier
          @model = model
        end

        def modifier_id
          modifier.try(:id)
        end
      end

      include Enumerable
      delegate :each, :empty?, to: :entries

      def entries
        @entries ||=
          begin
            result = []
            result << created_entry if created_entry.present?
            result << placed_entry if placed_entry.present?
            result += payment_entries
            result += fulfillment_entries
            result << canceled_entry if canceled_entry.present?
            result += comment_entries
            result += copied_entries
            result << price_override_entry if price_override_entry.present?

            result
              .reject { |r| r.occured_at.blank? }
              .sort_by(&:occured_at)
              .reverse
          end
      end

      def by_day
        @days ||= entries.reduce({}) do |memo, entry|
          day = entry.occured_at.to_date
          memo[day] ||= []
          memo[day] << entry
          memo
        end
      end

      def created_entry
        return if model.created_at.blank?
        Entry.new(:created, model.created_at, checkout_by, model)
      end

      def placed_entry
        return if model.placed_at.blank?
        Entry.new(:placed, model.placed_at, checkout_by, model)
      end

      def payment_entries
        # TODO v4 - use payment.transactions
        transactions = Payment::Transaction.where(payment_id: payment.id).to_a
        transactions.reduce([]) do |memo, transaction|
          admin_modifier = transaction.audit_log_entries.first.try(:modifier)

          memo << Entry.new(
            transaction.action.to_sym,
            transaction.created_at,
            admin_modifier || checkout_by,
            transaction
          )
        end
      end

      def fulfillment_entries
        results = []
        grouped = fulfillment.events.group_by do |event|
          [event.status, event.created_at]
        end

        grouped.each do |(type, created_at), events|
          # Try to find the audit log entry based on rounding creation to
          # nearest second.
          audit_log_entry = fulfillment.audit_log_entries.detect do |entry|
            entry.created_at.round.to_i == created_at.round.to_i
          end

          results << Entry.new(
            type == 'canceled' ? :canceled_fulfillment : type.to_sym,
            created_at,
            audit_log_entry.try(:modifier),
            events
          )
        end

        results
      end

      def comment_entries
        model.comments.map do |comment|
          Entry.new(
            :comment,
            comment.created_at,
            User.where(id: comment.author_id).first,
            comment
          )
        end
      end

      def copied_entries
        Order.copied_from(model.id).map do |order|
          copier = order.audit_log_entries.desc(:created_at).first.try(:modifier)
          Entry.new(:copied, order.created_at, copier, order)
        end
      end

      def canceled_entry
        return if model.canceled_at.blank?

        audit_log_entry = model.audit_log_entries.detect do |event|
          event.tracked_changes['canceled_at'].present? &&
            event.tracked_changes['canceled_at'].first.blank? &&
            event.tracked_changes['canceled_at'].last.present?
        end

        Entry.new(
          :canceled,
          model.canceled_at,
          audit_log_entry.try(:modifier),
          model
        )
      end

      def checkout_by
        @checkout_by ||=
          User.where(id: model.checkout_by_id).first ||
          User.where(id: model.user_id).first ||
          User.new(
            email: model.email,
            name: "#{payment.first_name} #{payment.last_name}"
          )
      end

      def price_override_entry
        return @price_override_entry if defined?(@price_override_entry)
        override = Pricing::Override.find(model.id)

        @price_override_entry =
          if override.has_adjustments?
            Admin::OrderTimelineViewModel::Entry.new(
              :price_overridden,
              override.created_at,
              User.find(override.created_by_id),
              override
            )
          end
      rescue Mongoid::Errors::DocumentNotFound
        @price_override_entry = nil
      end
    end
  end
end
