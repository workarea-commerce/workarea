require 'test_helper'
require 'generators/workarea/pricing_calculator/pricing_calculator_generator'

module Workarea
  class PricingCalculatorGeneratorTest < GeneratorTest
    tests Workarea::PricingCalculatorGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination
      run_generator %w(Customizations)
    end

    def test_model
      assert_file 'app/models/workarea/pricing/calculators/customizations_calculator.rb' do |model|
        assert_match('class CustomizationsCalculator', model)
      end
    end

    def test_test
      assert_file 'test/models/workarea/pricing/calculators/customizations_calculator_test.rb' do |test|
        assert_match('class CustomizationsCalculatorTest', test)
      end
    end
  end
end
