module Workarea
  class Fulfillment
    include ApplicationDocument

    # The _id field will be the order id
    field :_id, type: String, default: -> { BSON::ObjectId.new.to_s }

    embeds_many :items, class_name: 'Workarea::Fulfillment::Item'

    # Finds statuses of fulfillments based on multiple order ids
    # Used when displaying account order history.
    #
    # @param idss [Array<String>]
    # @return [Hash]
    #
    def self.find_statuses(*ids)
      fulfillments = any_in(id: ids).to_a

      ids.inject({}) do |memo, id|
        fulfillment = fulfillments.detect { |f| f.id == id }

        memo[id] = fulfillment ? fulfillment.status : :not_available
        memo
      end
    end

    # For compatibility with admin features, models must respond to this method
    #
    # @return [String]
    #
    def name
      id
    end

    def status
      calculators = Workarea.config.fulfillment_status_calculators.map(&:constantize)
      StatusCalculator.new(calculators, self).result
    end

    def events
      items.map(&:events).flatten
    end

    def find_package(tracking_number)
      packages.detect do |package|
        package.tracking_number.to_s.casecmp?(tracking_number.to_s)
      end
    end

    def packages
      Package.create(events)
    end

    def pending_items
      items.select { |i| i.quantity_pending > 0 }
    end

    def canceled_items
      items.select { |i| i.quantity_canceled > 0 }
    end

    # Add shipped event to a {Workarea::Fulfillment::Item}. Does not persist
    # the changes.
    #
    # @param [Hash] data data used to generate event
    # @option data [String] :id The order item's id
    # @option data [Integer] :quantity The quantity to be marked shipped
    # @option data [String] :tracking_number Tracking number for shipping
    #
    # @return [Workarea::Fulfillment::Event] the newly initialized event
    #
    def mark_item_shipped(data)
      data = data.with_indifferent_access
      occured_at = Time.current

      item = items.detect { |i| i.order_item_id == data[:id].to_s }
      return if item.blank? || data[:quantity].to_i < 1

      item.events.build(
        status: 'shipped',
        quantity: data[:quantity].to_i,
        created_at: occured_at,
        updated_at: occured_at,
        data: data.except(:id, :quantity)
      )
    end

    # Ship items in the fulfillment
    #
    # The hashes should contain 'id', the order_item_id and 'quantity' the amount
    # being shipped, any other key/values will be stored on the Fulfillment::Event#data
    #
    # ship_items('1Z923A', [
    #   { 'id' => '1234', 'quantity' => 1, 'serial_number' => '1234' },
    #   { 'id' => '4321', 'quantity' => 2 }
    # ])
    #
    # @param [String] tracking_number
    # @param [Array<Hash>] shipped_items
    # @return [Boolean]
    #
    def ship_items(tracking_number, shipped_items)
      shipped_items.each do |shipped_item|
        mark_item_shipped(
          shipped_item.merge(tracking_number: tracking_number.downcase)
        )
      end

      save.tap do |result|
        if result && Workarea.config.send_transactional_emails
          Storefront::FulfillmentMailer
            .shipped(id, tracking_number)
            .deliver_later
        end
      end
    end

    # Cancel items in the fulfillment
    #
    # The hashes should contain 'id', the order_item_id and 'quantity' the amount
    # to be canceled, any other key/values will be stored on the Fulfillment::Event#data
    #
    # cancel_items([
    #   { 'id' => '1234', 'quantity' => 4, 'replacement_sku' => '9999' },
    #   { 'id' => '4321', 'quantity' => 1 }
    # ])
    #
    # @param [Array<Hash>] canceled_items
    # @return [Boolean]
    #
    def cancel_items(canceled_items)
      return false unless canceled_items.present?

      occured_at = Time.current

      canceled_items = canceled_items.map do |canceled_item|
        canceled_item = canceled_item.with_indifferent_access
        next unless canceled_item['quantity'].to_i > 0

        item = items.detect { |i| i.order_item_id == canceled_item['id'].to_s }
        next unless item.present?

        item.events.build(
          status: 'canceled',
          quantity: canceled_item['quantity'],
          created_at: occured_at,
          updated_at: occured_at,
          data: canceled_item.except('id', 'quantity')
        )
        [canceled_item['id'].to_s, canceled_item['quantity']]
      end.compact

      return unless canceled_items.present?

      result = save

      if result && Workarea.config.send_transactional_emails
        Storefront::FulfillmentMailer
          .canceled(id, Hash[canceled_items])
          .deliver_later
      end

      result
    end
  end
end
