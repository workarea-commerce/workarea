# frozen_string_literal: true
module Workarea
  module Reports
    class CustomEvent
      include ApplicationDocument

      field :name, type: String
      field :occurred_at, type: Time

      index({ occurred_at: 1 });

      validates :name, presence: true
      validates :occurred_at, presence: true

      # Mongoid scopes pass arguments positionally; Ruby 3 keyword-arg
      # separation means we can't rely on keyword params here.
      scope :occurred_between, ->(options = {}) do
        starts_at = options[:starts_at]
        ends_at = options[:ends_at]

        where(
          :occurred_at.gte => starts_at,
          :occurred_at.lte => ends_at
        )
      end
    end
  end
end
