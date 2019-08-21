module Workarea
  class Comment
    include ApplicationDocument

    field :author_id, type: String
    field :body, type: String
    field :viewed_by_ids, type: Array, default: []

    validates :body, presence: true
    belongs_to :commentable, polymorphic: true, index: true

    default_scope -> { asc(:created_at) }
    index({ created_at: 1 })
  end
end
