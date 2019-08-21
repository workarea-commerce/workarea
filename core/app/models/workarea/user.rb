module Workarea
  class User
    include ApplicationDocument
    include Mongoid::Document::Taggable
    include User::Authorization
    include Passwords
    include Login
    include Addresses
    include NormalizeEmail
    include SystemUsers
    include Commentable
    include Avatar

    field :_id, type: StringId, default: -> { BSON::ObjectId.new }
    field :email, type: String
    field :first_name, type: String
    field :last_name, type: String
    field :name, type: String
    field :created_by_id, type: String

    index({ email: 1 }, { unique: true })
    index({ created_at: 1 })
    index({ updated_at: 1 })
    index({ status_email_recipient: 1, email: 1 })

    validates :email, presence: true, email: true, uniqueness: true

    before_validation :set_name

    # Find a user by email, case-insensitive
    #
    # @param [String] email
    #
    # @return [User]
    #
    def self.find_by_email(email)
      return nil if email.blank?
      find_by(email: email.to_s.downcase.strip) rescue nil
    end

    # Find an admin user by id. This searches
    # across sites, but limited to only
    # admin users.
    #
    # @param [String] id
    # @return [User, nil]
    #
    def self.find_admin(id)
      admins.find(id) rescue nil
    end

    # Returns public display name.
    # Always includes initials, optionally includes city if present.
    #
    # @return [String]
    #
    def public_info
      return nil unless first_name.present? && last_name.present?
      city = default_billing_address.try(:city)

      if city.present?
        "#{initials} from #{city}"
      else
        initials
      end
    end

    # Returns initials from name fields, falling back to email initial.
    #
    # @return [String]
    #
    def initials
      if first_name.present? && last_name.present?
        [first_name[0], last_name[0]].join
      else
        email[0]
      end
    end

    private

    def set_name
      self.name = if first_name.present? && last_name.present?
                    "#{first_name} #{last_name}"
                  else
                    email
                  end
    end
  end
end
