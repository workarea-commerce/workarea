require 'test_helper'

module Workarea
  class I18nHelperTest < ViewTest
    def test_switch_locale_fields
      params[:utf8] = 'check'
      params[:controller] = 'controller'
      params[:action] = 'action'
      params[:foo] = 'bar'
      params[:locale] = 'es'

      assert_includes(switch_locale_fields, 'foo')
      assert_includes(switch_locale_fields, 'bar')
      refute_includes(switch_locale_fields, 'utf8')
      refute_includes(switch_locale_fields, 'controller')
      refute_includes(switch_locale_fields, 'action')
      refute_includes(switch_locale_fields, 'locale')
    end
  end
end
