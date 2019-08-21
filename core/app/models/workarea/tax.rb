module Workarea::Tax
  # Finds the appropriate tax rate for a code/price/location
  #
  # @param [String] code
  # @param [Money] price
  # @param [Workarea::Address] address
  #
  # @return [Workarea::Tax::Rate]
  #
  def self.find_rate(code, price, address)
    category = Workarea::Tax::Category.find_by_code(code)
    return Workarea::Tax::Rate.new unless category.present?

    has_address_requirements = [:country, :region, :postal_code].inject(true) do |memo, detail|
      memo && address.send(detail).present?
    end

    return Workarea::Tax::Rate.new unless has_address_requirements

    rate = category.find_rate(
      price,
      address.country,
      address.region,
      address.postal_code
    )

    rate || Workarea::Tax::Rate.new
  end
end
