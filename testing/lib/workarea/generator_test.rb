# frozen_string_literal: true

module Workarea
  class GeneratorTest < Rails::Generators::TestCase
    extend TestCase::Decoration
    include TestCase::Setup
    include TestCase::Teardown
    include TestCase::Configuration
  end
end
