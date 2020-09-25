module Workarea
  class Sitemap
    include ApplicationDocument
    extend Dragonfly::Model

    field :file_uid, type: String
    field :index, type: String

    dragonfly_accessor :file, app: :workarea

    def self.find_or_initialize_by_index(index)
      find_by_index(index) || new(index: index)
    end

    def self.find_by_index(index)
      where(index: index).first
    end
  end
end
