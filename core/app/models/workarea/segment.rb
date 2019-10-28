module Workarea
  class Segment
    include ApplicationDocument
    include Commentable
    include Mongoid::Document::Taggable

    field :name, type: String
    embeds_many :rules, class_name: 'Workarea::Segment::Rules::Base', inverse_of: :segment

    validates :name, presence: true
    validate do |segment| # Don't decorate this
      if Segment.count >= 15
        segment.errors.add(:base, I18n.t('workarea.errors.messages.max_allowed_segments'))
      end
    end

    def self.find_qualifying(visit)
      all.select { |s| s.qualifies?(visit) }
    end

    def self.current
      Thread.current[:current_segments] || []
    end

    def self.current=(*segments)
      Thread.current[:current_segments] = Array.wrap(segments).flatten
    end

    def self.enabled?
      !!Thread.current[:enable_segmentation]
    end

    def self.enabled
      Thread.current[:enable_segmentation] = true
      yield
    ensure
      Thread.current[:enable_segmentation] = nil
    end

    def self.with_current(*segments)
      previous = current

      self.current = segments
      enabled { yield }
    ensure
      self.current = previous
    end

    def qualifies?(visit)
      return false if visit.blank?
      rules.all? { |r| r.qualifies?(visit) }
    end
  end
end
