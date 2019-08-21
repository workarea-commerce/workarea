require 'test_helper'

class PasswordValidatorTest < Workarea::TestCase
  class FooModel
    include Mongoid::Document
    attr_accessor :password, :strength
  end

  setup :set_instances

  def set_instances
    @validator = PasswordValidator.new(attributes: { foo: 'bar' })
    @model = FooModel.new
  end

  def test_w3bl1nc_is_a_valid_password
    @validator.validate_each(@model, :password, 'W3bl1nc!')
    assert(@model.errors.empty?)
  end

  def test_123456_is_an_invalid_password
    @validator.validate_each(@model, :password, '123456')
    refute(@model.errors.empty?)
    assert_includes(
      @model.errors.messages[:password],
      I18n.t('mongoid.errors.messages.password_weak_requirements', min: 7)
    )
  end

  def test_w3bl1nc_is_an_invalid_strong_password
    strong_validator = PasswordValidator.new(
      attributes: { foo: 'bar' },
      strength: :strong
    )

    strong_validator.validate_each(@model, :password, 'w3bl1nc')

    refute(@model.errors.empty?)
    assert_includes(
      @model.errors.messages[:password],
      I18n.t('mongoid.errors.messages.password_strong_requirements', min: 8)
    )
  end

  def test_passing_in_method_to_determine_strength
    validator = PasswordValidator.new(
      attributes: { foo: 'bar' },
      strength: :strength
    )

    @model.strength = :strong
    validator.validate_each(@model, :password, 'w3bl1nc')
    refute(@model.errors[:password].empty?)

    @model.errors.clear
    @model.strength = :weak
    validator.validate_each(@model, :password, 'w3bl1nc')
    assert(@model.errors[:password].empty?)
  end
end
