module Workarea
  class Content
    class Email
      include ApplicationDocument

      field :type, type: String
      field :content, type: String, localize: true

      index({ type: 1 }, { unique: true })

      validates :type, presence: true, uniqueness: true

      def self.find_content(type)
        find_by_type(type).try(:content).to_s
      end

      def self.find_by_type(type)
        find_by(type: type) rescue nil
      end

      # The given +:type+ of this email, titleized. Used in the activity
      # feed to display when this email's content was edited.
      #
      # @example type="account_creation"
      #   Account Creation
      def name
        type.titleize
      end
    end
  end
end
