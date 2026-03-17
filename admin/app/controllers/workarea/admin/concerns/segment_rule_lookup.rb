# frozen_string_literal: true

module Workarea
  module Admin
    module SegmentRuleLookup
      extend ActiveSupport::Concern

      private

      def segment_rule_class_for(rule_type)
        slug = rule_type.to_s.underscore
        Workarea.config.segment_rule_types
          .map { |t| t.constantize }
          .find { |klass| klass.slug.to_s == slug }
      end
    end
  end
end
