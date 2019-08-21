module Workarea
  class Segment
    include ApplicationDocument
    include Commentable
    include Mongoid::Document::Taggable

    field :name, type: String
    embeds_many :rules, class_name: 'Workarea::Segment::Rules::Base', inverse_of: :segment
    validates :name, presence: true

    def self.find_qualifying(visit)
      all.select { |s| s.qualifies?(visit) }
    end

    def qualifies?(visit)
      return false if rules.blank? || visit.blank?
      rules.all? { |r| r.qualifies?(visit) }
    end
  end
end
