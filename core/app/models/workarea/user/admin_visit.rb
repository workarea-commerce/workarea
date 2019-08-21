module Workarea
  class User
    class AdminVisit
      include ApplicationDocument

      field :name, type: String
      field :path, type: String
      field :user_id, type: String

      index({ user_id: 1 })
      index({ created_at: 1 }, { expire_after_seconds: 4.weeks.seconds.to_i })

      def self.most_visited(user_id, limit = Workarea.config.admin_max_most_visited)
        results = collection.aggregate([
          {
            '$match' => { 'user_id' => user_id.to_s }
          },
          {
            '$group' => {
              '_id' => '$path',
              'name' => { '$first' => '$name' },
              'count' => { '$sum' => 1 }
            }
          },
          {
            '$sort' => { 'count' => -1 }
          },
          {
            '$limit' => limit
          }
        ])

        results.map do |result|
          { name: result['name'], path: result['_id'] }
        end
      end
    end
  end
end
