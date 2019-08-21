require 'test_helper'

class ParameterValidatorTest < Workarea::TestCase
  class FooModel
    include ActiveModel::Validations
  end

  def test_validate_each
    validator = ParameterValidator.new(attributes: { foo: 'bar' })
    model = FooModel.new

    string = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).join + '-_'
    validator.validate_each(model, :string, string)
    assert(model.errors.empty?)

    validator.validate_each(model, :string, ' &#.?')
    assert(model.errors.present?)
  end
end
