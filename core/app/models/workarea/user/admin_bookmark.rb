module Workarea
  class User
    class AdminBookmark
      include ApplicationDocument

      field :name, type: String
      field :path, type: String

      belongs_to :user, class_name: 'Workarea::User', index: true

      validates :name, presence: true
      validates :path, presence: true

      before_validation :sanitize_path

      default_scope -> { desc(:created_at) }
      scope :by_user, ->(u) { where(user_id: u.id) }
      index({ created_at: -1 })

      def self.bookmarked?(user, path)
        by_user(user).where(path: sanitize_path(path)).count > 0
      end

      def self.sanitize_path(path)
        parsed = URI.parse(path)

        result = [parsed.path, parsed.query].join('?')
        result = "/#{result}" unless result.starts_with?('/')
        result = result[0..-2] if result.ends_with?('?')
        result
      end

      private

      def sanitize_path
        self.path = self.class.sanitize_path(path)
      end
    end
  end
end
