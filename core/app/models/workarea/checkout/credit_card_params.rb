module Workarea
  class Checkout::CreditCardParams
    attr_accessor :params

    def initialize(params)
      @params = params
      @card_params = params.fetch(:credit_card, {})
    end

    # Whether these params represent setting a new card as
    # payment on the order.
    #
    # @return [Boolean]
    #
    def new?
      params[:payment] == 'new_card'
    end

    # New credit card params.
    #
    # @return [Hash]
    #
    def new_card
      @card_params
    end

    # The new credit card number for these params
    #
    # @return [String]
    #
    def number
      @card_params[:number]
    end

    # Do these params represent using a saved credit card as payment?
    #
    # @return [Boolean]
    #
    def saved?
      saved_card_id.present?
    end

    # The saved card id for these params. Returns the `:payment` param
    # if it is a legal {BSON::ObjectId}
    #
    # @return [String]
    #
    def saved_card_id
      if BSON::ObjectId.legal?(params[:payment])
        params[:payment]
      end
    end
  end
end
