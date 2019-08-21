module Workarea
  class Address
    include ApplicationDocument

    ATTRIBUTES_FOR_LENGTH_VALIDATION = [
      :first_name,
      :last_name,
      :company,
      :street,
      :street_2,
      :city,
      :region,
      :postal_code,
      :country,
      :phone_number,
      :phone_extension
    ]

    field :first_name, type: String
    field :last_name, type: String
    field :company, type: String
    field :street, type: String
    field :street_2, type: String
    field :city, type: String
    field :region, type: String
    field :postal_code, type: String
    field :country, type: Country
    field :phone_number, type: String
    field :phone_extension, type: String

    embedded_in :addressable, polymorphic: true

    ATTRIBUTES_FOR_LENGTH_VALIDATION.each do |field|
      validates field, length: { maximum: 500 }
    end

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :street, presence: true
    validates :city, presence: true
    validates :country, presence: true
    validate :region_presence
    validate :postal_code_presence
    validate :not_po_box, unless: :allow_po_box?

    # Sets the phone number of the address, while removing
    # any non-digit characters.
    #
    # @param value
    # @return [void]
    #
    def phone_number=(val)
      if val.nil?
        super(val)
      else
        super(val.to_s.gsub(/\D/, ''))
      end
    end

    # Ensures the following situations work:
    # address.country = 'US'
    # address.country = 'USA'
    # address.country = 'United States of America'
    # address.country = Country['US']
    #
    # @param value
    #
    def country=(value)
      super(Country.search_for(value)&.alpha2)
    end

    # Whether or not to allow a PO BOX address. Can be overridden in subclasses
    # to configure this behavior.
    #
    # @return [Boolean] If the address can be a PO BOX
    #
    def allow_po_box?
      true
    end

    # Whether the address is a PO BOX address
    #
    # @return [Boolean] If the address is PO BOX or not
    #
    def po_box?
      street.present? && street.strip =~ Workarea.config.po_box_regex ||
        street_2.present? && street_2.strip =~ Workarea.config.po_box_regex
    end

    # If this address is the same as another address. Addresses
    # are equal if the address-relevant attributes are the same,
    # ignoring case. Used to check whether we should save an
    # additional address for a user.
    #
    # @return [Boolean]
    #
    def address_eql?(address)
      Workarea.config.address_attributes.inject(true) do |memo, attr|
        other = address.send(attr).to_s.downcase.gsub(/\s+/, '')
        selfs = self.send(attr).to_s.downcase.gsub(/\s+/, '')

        memo && other == selfs
      end
    end

    # Returns the full name for the region
    #
    # @return [String]
    #
    def region_name
      return '' if region.blank?
      country.subdivisions[region].try(:name) || region
    end

    def as_json(*args)
      super.tap do |hash|
        hash['country'] = self.country.try(:alpha2)
      end
    end

    private

    def region_presence
      return unless country.try(:subdivisions).present?

      if country.subdivisions[region].blank?
        errors.add(:region, I18n.t('errors.messages.invalid'))
      end
    end

    def postal_code_presence
      return unless country.try(:postal_code?)

      if postal_code.blank?
        errors.add(:postal_code, I18n.t('errors.messages.blank'))
      end
    end

    def not_po_box
      return unless po_box?

      if street.present? && street.strip =~ Workarea.config.po_box_regex
        errors.add(:street, I18n.t('workarea.errors.messages.po_box'))
      else
        errors.add(:street_2, I18n.t('workarea.errors.messages.po_box'))
      end
    end
  end
end
