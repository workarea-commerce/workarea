module Workarea
  module Metrics
    class CalculatePercentiles
      delegate :[], to: :results

      def initialize(collection, field)
        @collection = collection
        @field = field
      end

      def results
        @results ||= (aggregation.first || {}).except('_id')
      end

      def aggregation
        @collection.aggregate(
          [
            { '$project' => { @field => 1 } },
            { '$match' => { @field => { '$gt' => 0 } } },
            { '$sort' => { @field => 1 } },
            { '$group' => { '_id' => nil, 'values' => { '$push' => "$#{@field}" } } },
            {
              '$project' => (0..99).reduce({}) do |memo, percentile|
                memo.merge(percentile => {
                  '$arrayElemAt' => [
                    '$values',
                    {
                      '$floor' => {
                        '$multiply' => [percentile / 100.to_f, { '$size' => '$values' }]
                      }
                    }
                  ]
                })
              end
            }
          ],
          allow_disk_use: true
        )
      end
    end
  end
end
