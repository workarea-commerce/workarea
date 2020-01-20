module Workarea
  class Content::Page
    include ApplicationDocument
    include Mongoid::Document::Taggable
    include Releasable
    include Navigable
    include Contentable
    include Commentable

    field :_id, type: StringId, default: -> { BSON::ObjectId.new }
    field :name, type: String, localize: true
    field :show_navigation, type: Boolean, default: false
    field :template, type: String, default: 'generic'
    field :display_h1, type: Boolean, default: true

    belongs_to :copied_from,
      class_name: 'Workarea::Content::Page',
      optional: true

    validates :name, presence: true
  end
end
