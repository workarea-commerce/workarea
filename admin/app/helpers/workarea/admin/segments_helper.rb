module Workarea
  module Admin
    module SegmentsHelper
      def segment_rule_types_options
        Workarea.config.segment_rule_types.map do |string|
          rule = string.constantize
          [t("workarea.admin.fields.#{rule.slug}", default: rule.slug.to_s), rule.slug]
        end
      end

      def traffic_referrer_medium_options
        {
          t('workarea.admin.segment_rules.select_a_medium') => nil,
          t('workarea.admin.segment_rules.email') => 'email',
          t('workarea.admin.segment_rules.social') => 'social',
          t('workarea.admin.segment_rules.search') => 'search'
        }
      end

      def traffic_referrer_source_options
        Workarea.referrer_parser.sources
      end

      def segments
        @segments ||= Segment.all
      end

      def selected_segment_geolocation_options(selected)
        selected.map { |l| [Segment::Rules::GeolocationOption[l]&.name || l, l] }
      end

      def browser_info_options
        {
          t('workarea.admin.segment_rules.browser_info.bot') => 'bot',
          t('workarea.admin.segment_rules.browser_info.chrome') => 'chrome',
          t('workarea.admin.segment_rules.browser_info.edge') => 'edge',
          t('workarea.admin.segment_rules.browser_info.firefox') => 'firefox',
          t('workarea.admin.segment_rules.browser_info.ie') => 'ie',
          t('workarea.admin.segment_rules.browser_info.opera') => 'opera',
          t('workarea.admin.segment_rules.browser_info.safari') => 'safari'
        }
      end

      def device_type_options
        {
          t('workarea.admin.segment_rules.devices.console') => 'console',
          t('workarea.admin.segment_rules.devices.ipad') => 'ipad',
          t('workarea.admin.segment_rules.devices.iphone') => 'iphone',
          t('workarea.admin.segment_rules.devices.ipod_touch') => 'ipod_touch',
          t('workarea.admin.segment_rules.devices.kindle') => 'kindle',
          t('workarea.admin.segment_rules.devices.mobile') => 'mobile',
          t('workarea.admin.segment_rules.devices.nintendo') => 'nintendo',
          t('workarea.admin.segment_rules.devices.playstation') => 'playstation',
          t('workarea.admin.segment_rules.devices.tablet') => 'tablet',
          t('workarea.admin.segment_rules.devices.tv') => 'tv',
          t('workarea.admin.segment_rules.devices.xbox') => 'xbox'
        }
      end

      def platform_options
        {
          t('workarea.admin.segment_rules.platform.android') => 'android',
          t('workarea.admin.segment_rules.platform.blackberry') => 'blackberry',
          t('workarea.admin.segment_rules.platform.ios') => 'ios',
          t('workarea.admin.segment_rules.platform.linux') => 'linux',
          t('workarea.admin.segment_rules.platform.mac') => 'mac',
          t('workarea.admin.segment_rules.platform.windows') => 'windows'
        }
      end

      def last_order_options
        {
          t('workarea.admin.segment_rules.last_order.ordered') => true,
          t('workarea.admin.segment_rules.last_order.not_ordered') => false
        }
      end
    end
  end
end
