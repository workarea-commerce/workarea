module Workarea
  class Storefront::Checkout::AddressesViewModel < ApplicationViewModel
    include Storefront::CheckoutContent

    delegate :email, to: :order

    # Whether to show the email field. Only show it if we
    # have a user for the checkout.
    #
    # @return [Boolean]
    #
    def show_email_field?
      user.blank?
    end

    # Whether to show the shipping address. Only show it if
    # the order requires shipping (has non-digital items).
    #
    # @return [Boolean]
    #
    def show_shipping_address?
      order.requires_shipping?
    end

    # The current billing address for the order.
    # Used for errors and form fields.
    #
    # @return [Workarea::Address]
    #
    def billing_address
      payment.address || Address.new
    end

    # The current shipping address for the order.
    # Used for errors and form fields.
    #
    # @return [Shipping::Address]
    #
    def shipping_address
      shipping.try(:address) || Shipping::Address.new
    end

    # Return the default shipping address id of the current
    # user. Returns nil if not logged in or no addresses.
    # Used as HTML data for JS address-selection functionality.
    #
    # @return [User::SavedAddress, nil]
    #
    def default_shipping_address_id
      user.try(:default_shipping_address).try(:id)
    end


    # Return the default billing address id of the current
    # user. Returns nil if not logged in or no addresses.
    # Used as HTML data for JS address-selection functionality.
    #
    # @return [User::SavedAddress, nil]
    #
    def default_billing_address_id
      user.try(:default_billing_address).try(:id)
    end

    # Returns an array of saved addresses for the current user.
    # Used as HTML data for JS address-selection functionality.
    #
    # @return [Array<User::SavedAddress>]
    #
    def saved_addresses
      user.try(:addresses)
    end
  end
end
