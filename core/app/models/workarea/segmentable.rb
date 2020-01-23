module Workarea
  module Segmentable
    extend ActiveSupport::Concern

    included do
      field :active_segment_ids, type: Array, default: [], localize: true
      after_find :mark_segmented_content
    end

    class_methods do
      def active
        if embedded?
          scoped.select(&:active?)
        else
          Workarea.deprecation.warn(
            <<~eos.squish
              The active scope is being called on a root document. This won't
              respect segments. Rewrite this to use #active?, like: scope.select(&:active?)
            eos
          )
          scoped.where(active: true)
        end
      end

      def inactive
        if embedded?
          scoped.reject(&:active?)
        else
          Workarea.deprecation.warn(
            <<~eos.squish
              The inactive scope is being called on a root document. This won't
              respect segments. Rewrite this to use !#active?, like: scope.reject(&:active?)
            eos
          )
          scoped.where(active: false)
        end
      end
    end

    def active?
      default = super
      return default unless Segment.enabled?
      return false unless default

      if active_segment_ids.blank?
        true
      else
        allowed_ids = active_segment_ids.map(&:to_s)
        Segment.current.any? { |s| allowed_ids.include?(s.id.to_s) }
      end
    end

    def segmented?
      active_segment_ids.present?
    end

    def segments
      @segments ||= active_segment_ids.blank? ? [] : Segment.in(id: active_segment_ids)
    end

    def active_segment_ids_with_children
      children = embedded_children.reduce([]) do |memo, child|
        memo += child.active_segment_ids if child.respond_to?(:active_segment_ids)
        memo
      end

      (active_segment_ids + children).uniq
    end

    private

    def mark_segmented_content
      # If loaded with `.only` this might be missing
      return if attribute_missing?(:active_segment_ids)

      CurrentSegments.has_segmented_content! if active_segment_ids.present?
    end
  end
end
