module Workarea
  module Email
    class Signup
      include ApplicationDocument
      include NormalizeEmail

      field :email, type: String
      validates :email, presence: true, email: true, uniqueness: true

      index({ email: 1 }, { unique: true })
      index(created_at: 1)

      scope :by_date, ->(starts_at:, ends_at:) do
        where(:created_at.gte => starts_at, :created_at.lte => ends_at)
      end
    end
  end
end
