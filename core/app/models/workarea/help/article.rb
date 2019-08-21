module Workarea
  module Help
    class Article
      TOP_CATEGORY_COUNT = 3
      TOP_ARTICLE_COUNT = 3

      include ApplicationDocument
      extend Dragonfly::Model

      field :_id, type: String, default: -> { name.to_s.parameterize }
      field :name, type: String
      field :category, type: String
      field :matching_url, type: String
      field :summary, type: String
      field :body, type: String
      field :thumbnail_name, type: String
      field :thumbnail_uid, type: String

      dragonfly_accessor :thumbnail, app: :workarea

      validates :name, presence: true
      validates :category, presence: true
      before_validation :set_unique_id, if: :new_record?

      scope :in_category, ->(c) { where(category: c) }
      scope :recent, -> { desc(:updated_at) }
      scope :top, -> { limit(TOP_ARTICLE_COUNT) }

      index({ category: 1, updated_at: 1 })

      def self.find_matching_url(url)
        results = []

        all.each_by(50) do |article|
          next if article.matching_url.blank?

          regex = ::Regexp.new("^#{article.matching_url}$")
          results << article if article.matching_url == url || regex =~ url
        end

        results
      end

      def self.top_categories
        aggregation = collection.aggregate(
          [
            { '$group' => { '_id' => '$category', 'count' => { '$sum' => 1 } } },
            { '$sort' => { 'count' => -1 } },
            { '$limit' => TOP_CATEGORY_COUNT }
          ]
        )

        aggregation.to_a.map { |r| r['_id'] }
      end

      private

      def set_unique_id
        unique_id = name.to_s.parameterize
        counter = 0

        until self.class.where(id: unique_id).count.zero?
          counter += 1
          unique_id = "#{name.to_s.parameterize}-#{counter}"
        end

        self.id = unique_id
      end
    end
  end
end
