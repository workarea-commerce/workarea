module Workarea
  module Recommendation
    class UserActivity
      include ApplicationDocument

      # id will be either current_user.id if present or session id
      field :_id, type: String, default: -> { BSON::ObjectId.new.to_s }
      field :product_ids, type: Array, default: []
      field :category_ids, type: Array, default: []
      field :searches, type: Array, default: []

      index({ updated_at: 1 })

      def self.save_product(id, product_id)
        prepend_field(id, :product_ids, product_id)
      end

      def self.save_category(id, category_id)
        prepend_field(id, :category_ids, category_id)
      end

      def self.save_search(id, search)
        prepend_field(id, :searches, search)
      end

      def self.prepend_field(id, field, values)
        timestamp = Time.current

        result = collection.update_one(
          { _id: id.to_s },
          {
            '$set' => { updated_at: timestamp },
            '$push' => {
              field => {
                '$each' => Array(values),
                '$position' => 0,
                '$slice' => Workarea.config.max_user_activities
              }
            }
          },
          upsert: true
        )

        if result.documents[0]['nModified'].zero?
          collection.update_one(
            { _id: id.to_s },
            { '$set' => { created_at: timestamp } }
          )
        end
      end
    end
  end
end
