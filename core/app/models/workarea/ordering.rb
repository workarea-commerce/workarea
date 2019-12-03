module Workarea
  # TODO extract to gem
  module Ordering
    extend ActiveSupport::Concern

    included do
      field :position, type: Integer

      after_validation :set_position
      after_create :move_lower_blocks_down
      after_destroy :move_lower_blocks_up

      default_scope -> { asc(:position) }
    end

    def lower_siblings
      siblings.where(:position.gte => position).excludes(id: id)
    end

    def higher_siblings
      siblings.where(:position.lte => position).excludes(id: id)
    end

    private

    def siblings
      return self.class.all unless embedded?
      return self.class.none unless _parent.present?

      _parent.send(association_name).criteria
    end

    def set_position
      if position.blank?
        self.position = siblings.exists(position: true).length
      end
    end

    def move_lower_blocks_down
      lower_siblings.select(&:persisted?).each { |b| b.inc(position: 1) }
    end

    def move_lower_blocks_up
      lower_siblings.select(&:persisted?).each { |b| b.inc(position: -1) }
    end
  end
end
