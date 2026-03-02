# frozen_string_literal: true
module Workarea
  module Email
    class Signup
      include ApplicationDocument
      include NormalizeEmail

      field :email, type: String
      validates :email, presence: true, email: true, uniqueness: true

      index({ email: 1 }, { unique: true })
      index(created_at: 1)

      # Mongoid scopes pass arguments positionally; Ruby 3 keyword-arg
      # separation means we can't rely on keyword params here.
      scope :by_date, ->(options = {}) do
        starts_at = options[:starts_at]
        ends_at = options[:ends_at]

        where(:created_at.gte => starts_at, :created_at.lte => ends_at)
      end
    end
  end
end
