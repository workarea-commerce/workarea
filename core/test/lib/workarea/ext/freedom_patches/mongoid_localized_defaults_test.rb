require 'test_helper'

module Workarea
  class MongoidLocalizedDefaultsTest < TestCase
    class Foo
      include Mongoid::Document

      field :name, type: String, default: -> { 'foo' }, localize: true
      field :config, type: Hash, default: { foo: 'bar' }, localize: true
    end

    def test_localized_defaults
      set_locales(available: [:en, :es], default: :en, current: :en)

      instance = Foo.new
      assert_equal('foo', instance.name)
      assert_equal({ foo: 'bar' }, instance.config)

      I18n.locale = :es

      assert_equal('foo', instance.name)
      assert_equal({ foo: 'bar' }, instance.config)
    end
  end
end
