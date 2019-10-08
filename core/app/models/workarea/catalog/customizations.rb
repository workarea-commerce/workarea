# This is the base class for creating types of product
# customizations. To make a new type of customizations,
# simply inherit this class, add the list of customized_fields,
# and add the appropriate {ActiveModel::Validations}.
#
# @example Subclass {Catalog::Customizations}
#   class Catalog::Customizations::Monogram < Catalog::Customizations
#     customized_fields :first, :second, :third
#     validates_presence_of :first, :second, :third
#   end
#
class Workarea::Catalog::Customizations
  include ActiveModel::Validations

  attr_reader :product_id, :attributes

  # Called by classes that inherit from Catalog::Customizations
  # to indicate the fields that need to be stored. All field names are
  # converted to +snake_case+ format.
  #
  # @param fields [Array<Symbol>]
  # @return [void]
  #
  def self.customized_fields(*fields)
    class_eval do
      cattr_accessor :fields
      self.fields = fields

      fields.each { |field| attr_reader field }
    end
  end

  # Find Catalog::Customizations for a product. The implementation class
  # is decided based on the customizations that the product supports.
  #
  # @param product_id [String, BSON::ObjectId]
  # @param attributes [Hash]
  # @return [Catalog::Customizations]
  #
  def self.find(product_id, attributes)
    product = Workarea::Catalog::Product.find(product_id)
    return nil unless product && product.customizations.present?

    klass = "Workarea::Catalog::Customizations::#{product.customizations.classify}".constantize
    klass.new(product_id, attributes)
  end

  def initialize(product_id, attributes)
    @product_id = product_id
    @attributes = attributes.with_indifferent_access

    attributes.each do |name, value|
      instance_variable_set("@#{name.to_s.underscore.optionize('_')}", value)
    end
  end

  # Customizations are only present if the customized
  # fields are present.
  #
  # @return [Boolean]
  #
  def present?
    to_h.present? && super
  end

  # A {Hash} representation of the customizations. This will
  # be stored with the {Order::Item}.
  #
  # @return [Hash]
  #
  def to_h
    @hash ||=
      begin
        present_fields = self.class.fields.select do |field|
          attributes[field].present?
        end

        attributes.slice(*present_fields)
      end
  end
end
