module Workarea
  module Inventory
    # This class is responsible for decrementing inventory levels.
    # Used in {Sku}#capture, when a {Policies::Base} wants to actually
    # decrement the levels for purchasing.
    #
    class Capture
      attr_reader :result

      def initialize(sku, available, backordered)
        @sku = sku
        @available = available
        @backordered = backordered
      end

      # Total number of units to be captured.
      #
      # @return [Integer]
      #
      def total
        @available + @backordered
      end

      # Whether the operation is completed and was successful. Returns false if
      # the #perform method hasn't been called.
      #
      # @return [Boolean]
      #
      def success?
        !!(@database_result &&
             @database_result.available == capture_attributes[:available])
      end

      # Run the MongoDB update to commit the changes.
      # Uses MongoDB's findAndModify command.
      #
      # @return [self]
      #
      def perform
        return self if @result.present?

        assert_availability
        find_and_modify!

        @result = {
          success: success?,
          available: success? ? @available : 0,
          backordered: success? ? @backordered : 0,
          backordered_until: @sku.backordered_until
        }

        self
      end

      private

      def assert_availability
        if @sku.available < @available || @sku.backordered < @backordered
          raise(
            InsufficientError,
            "insufficient inventory for SKU: #{@sku.id}"
          )
        end
      end

      def find_and_modify!
        @database_result = Sku
                            .with(read: { mode: :primary }) do
                              Sku
                                .where(find_options)
                                .find_one_and_update(
                                  { '$set' => capture_attributes },
                                  return_document: :after
                                )
                            end
      end

      def find_options
        {
          _id: @sku.id,
          available: @sku.available,
          backordered: @sku.backordered,
          purchased: @sku.purchased
        }.tap { |h| h[:sellable] = @sku.sellable if tracks_sellable? }
      end

      def capture_attributes
        {
          available: @sku.available - @available,
          backordered: @sku.backordered - @backordered,
          purchased: @sku.purchased + total
        }.tap { |h| h[:sellable] = @sku.sellable - total if tracks_sellable? }
      end

      def tracks_sellable?
        @sku.read_attribute(:sellable).to_i.positive?
      end
    end
  end
end
