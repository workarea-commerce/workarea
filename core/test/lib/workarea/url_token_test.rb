require 'test_helper'

module Workarea
  class UrlTokenTest < TestCase
    class UrlTokenModel
      include Mongoid::Document
      include UrlToken
      create_indexes
    end

    def test_setting_tokens
      instance = UrlTokenModel.create!
      refute(instance.token.blank?)
      assert_equal(instance, UrlTokenModel.find_by_token(instance.token))

      instance.token = nil
      instance.valid?
      refute(instance.token.blank?)
    end
  end
end
