module Workarea::Contentable
  extend ActiveSupport::Concern

  included do
    has_one :content,
      class_name: 'Workarea::Content',
      as: :contentable
  end
end
