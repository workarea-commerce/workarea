module Workarea
  module Admin
    module SegmentRulesHelper
      def segment_rule_types_options
        Workarea.config.segment_rule_types.map do |string|
          rule = string.constantize
          [t("workarea.admin.fields.#{rule.slug}", default: rule.slug.to_s), rule.slug]
        end
      end

      def traffic_referrer_medium_options
        {
          t('workarea.admin.segment_rules.unknown') => 'unknown',
          t('workarea.admin.segment_rules.email') => 'email',
          t('workarea.admin.segment_rules.social') => 'social',
          t('workarea.admin.segment_rules.search') => 'search'
        }
      end
    end
  end
end
