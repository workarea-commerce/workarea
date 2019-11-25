module Workarea
  module Reports
    class CustomEvent
      include ApplicationDocument

      field :name, type: String
      field :occurred_at, type: Time

      index({ occurred_at: 1 });

      validates :name, presence: true
      validates :occurred_at, presence: true

      scope :occurred_between, ->(starts_at: nil, ends_at: nil) do
        where(
          :occurred_at.gte => starts_at,
          :occurred_at.lte => ends_at
        )
      end
    end
  end
end
