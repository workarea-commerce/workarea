module Workarea
  module Search
    class Customization
      include ApplicationDocument
      include Releasable
      include Contentable
      include Commentable
      include FeaturedProducts
      include ProductList

      field :_id, type: String
      field :query, type: String
      field :rewrite, type: String
      field :redirect, type: String

      index({ query: 1 })

      validates :query, presence: true
      validate :not_star_query
      list_field :product_ids

      alias_method :name, :query

      def self.autocomplete(string)
        regex = /^#{::Regexp.quote(string)}/
        where(query: regex).pluck(:query)
      end

      def self.find_by_query(query)
        result = find_or_initialize_by(id: QueryString.new(query).id)
        result.query ||= query
        result
      end

      def self.positions_for_product(id)
        self.in(product_ids: Array(id)).reduce({}) do |memo, sort|
          memo[sort.id] = sort.product_ids.index(id.to_s)
          memo
        end
      end

      def self.sorts
        [Workarea::Sort.newest, Workarea::Sort.query]
      end

      def query=(value)
        super(value.downcase)
      end

      def redirect
        value = read_attribute(:redirect)

        return unless value.present?
        return value if UrlValidator.valid_url?(value)

        case value
        when /\A\//
          value
        when /[\.{2,}]/
          "http://#{value}"
        else
          "/#{value}"
        end
      end

      def rewrite?
        rewrite.present?
      end

      def redirect?
        redirect.present?
      end

      def not_star_query
        if query.to_s.strip == '*'
          errors.add(:query, I18n.t('workarea.errors.messages.not_star_query'))
        end
      end
    end
  end
end
