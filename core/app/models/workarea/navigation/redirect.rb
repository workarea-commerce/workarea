module Workarea
  module Navigation
    class Redirect
      include ApplicationDocument

      field :path, type: String
      field :destination, type: String

      index({ path: 1 }, { unique: true })
      index({ destination: 1 })

      validates :path, presence: true, uniqueness: true
      validates :destination, presence: true

      before_validation :sanitize_path

      def self.find_by_path(path)
        find_by(path: sanitize_path(path)) rescue nil
      end

      def self.find_destination(path)
        find_by_path(path).try(:destination)
      end

      def self.search(query)
        return all unless query.present?

        regex = /^\/?#{::Regexp.quote(query)}/
        any_of(
          { path:  regex },
          { destination: regex }
        )
      end

      def self.sanitize_path(path)
        encoded_path = if path =~ URI::ESCAPED
                         path
                       else
                         URI.encode(path)
                       end
        uri = URI.parse(encoded_path)

        result = uri.path
        result = "/#{result}" unless result.starts_with?('/')
        result = result[0..-2] if result.ends_with?('/')
        result = "#{result}?#{uri.query}" if uri.query.present?
        result
      end

      def self.sorts
        [Sort.newest, Sort.path, Sort.destination, Sort.modified]
      end

      private

      def sanitize_path
        self.path = self.class.sanitize_path(path)
      end
    end
  end
end
