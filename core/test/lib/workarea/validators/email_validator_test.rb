require 'test_helper'

class EmailValidatorTest < Workarea::TestCase
  class FooModel
    include ActiveModel::Validations
    attr_accessor :email
  end

  def test_validate_each
    validator = EmailValidator.new(attributes: { foo: 'bar' })
    model = FooModel.new

    validator.validate_each(model, :email, 'mdalton-test@workarea.com')
    assert(model.errors.empty?)

    validator.validate_each(model, :email, 'mdalton-test@foo.workarea.com')
    assert(model.errors.empty?)

    validator.validate_each(model, :email, 'mdalton-test')
    assert(model.errors.present?)

    validator.validate_each(model, :email, 'mdalton-test@workarea')
    assert(model.errors.present?)
  end
end
