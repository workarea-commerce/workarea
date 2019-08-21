module Mongoid
  module Errors
    class MongoidError < StandardError
      def as_json
        {
          'problem' => problem,
          'summary' => summary,
          'resolution' => resolution
        }
      end

      def to_json
        as_json.to_json
      end
    end
  end
end
