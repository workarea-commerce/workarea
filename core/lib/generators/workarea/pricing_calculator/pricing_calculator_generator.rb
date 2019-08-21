module Workarea
  class PricingCalculatorGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def copy_calculator
      template(
        'calculator.rb.erb',
        "app/models/workarea/pricing/calculators/#{file_name}_calculator.rb"
      )
    end

    def copy_test
      template(
        'test.rb.erb',
        "test/models/workarea/pricing/calculators/#{file_name}_calculator_test.rb"
      )
    end

    def notify_of_changes
      say %{
      Review the pricing guides to learn how to customize your new calculator
      and insert it into the chain of calculators
      }
    end
  end
end
