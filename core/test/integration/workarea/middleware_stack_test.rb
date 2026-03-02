# frozen_string_literal: true

require 'test_helper'

module Workarea
  # Tests for Rack::Attack middleware placement in the stack.
  #
  # The production initializer (config/initializers/10_rack_middleware.rb) uses
  # a delete-then-insert pattern to place Rack::Attack at index 1 (immediately
  # after Rack::Timeout).  The pattern is skipped in test/development, so these
  # tests validate the algorithm directly on an isolated array rather than
  # asserting a specific index in the live test-env stack.
  class MiddlewareStackTest < ActionDispatch::IntegrationTest
    # -----------------------------------------------------------------------
    # Guard: no duplicate Rack::Attack entries in any environment
    # -----------------------------------------------------------------------

    test 'Rack::Attack appears at most once in middleware stack' do
      stack = Rails.application.middleware.middlewares.map(&:name)
      count = stack.count('Rack::Attack')
      assert count <= 1,
        "Expected Rack::Attack at most once in stack, got #{count}. Stack:\n  #{stack.join("\n  ")}"
    end

    # -----------------------------------------------------------------------
    # Algorithm tests: simulate the production initializer logic
    #
    # The initializer does:
    #   app.config.middleware.insert 0, Rack::Timeout
    #   app.config.middleware.delete(Rack::Attack)   # removes any Railtie copy
    #   app.config.middleware.insert 1, Rack::Attack
    #
    # These tests verify the algorithm is correct regardless of Rails.env.
    # -----------------------------------------------------------------------

    test 'delete-then-insert places Rack::Attack immediately after Rack::Timeout' do
      # Simulate a realistic stack where the rack-attack Railtie already
      # inserted Rack::Attack somewhere in the middle.
      stack = [
        'Rack::Sendfile',
        'Rack::Timeout',
        'ActionDispatch::Static',
        'Rack::Attack',
        'Rails::Rack::Logger'
      ]

      # Reproduce the initializer algorithm
      stack.delete('Rack::Attack')
      stack.insert(1, 'Rack::Attack')

      timeout_idx = stack.index('Rack::Timeout')
      attack_idx  = stack.index('Rack::Attack')

      assert_equal 1, stack.count('Rack::Attack'),
        "Expected exactly one Rack::Attack after re-insert. Stack: #{stack.inspect}"

      assert_equal timeout_idx + 1, attack_idx,
        "Expected Rack::Attack at index #{timeout_idx + 1} (immediately after Rack::Timeout), " \
        "got #{attack_idx}. Stack: #{stack.inspect}"
    end

    test 'insert is safe when Rack::Attack is not yet present (Railtie absent)' do
      # delete is a no-op when the entry is absent; insert must still land correctly.
      stack = [
        'Rack::Sendfile',
        'Rack::Timeout',
        'ActionDispatch::Static',
        'Rails::Rack::Logger'
      ]

      stack.delete('Rack::Attack') # no-op
      stack.insert(1, 'Rack::Attack')

      timeout_idx = stack.index('Rack::Timeout')
      attack_idx  = stack.index('Rack::Attack')

      assert_equal 1, stack.count('Rack::Attack'),
        "Expected exactly one Rack::Attack after insert. Stack: #{stack.inspect}"

      assert_equal timeout_idx + 1, attack_idx,
        "Expected Rack::Attack immediately after Rack::Timeout even when not pre-existing. " \
        "Stack: #{stack.inspect}"
    end

    test 'delete-then-insert is idempotent when called twice' do
      # Running the initializer code twice should not create duplicates.
      stack = [
        'Rack::Sendfile',
        'Rack::Timeout',
        'ActionDispatch::Static',
        'Rails::Rack::Logger'
      ]

      2.times do
        stack.delete('Rack::Attack')
        stack.insert(1, 'Rack::Attack')
      end

      assert_equal 1, stack.count('Rack::Attack'),
        "Expected exactly one Rack::Attack after idempotent double-insert. Stack: #{stack.inspect}"

      timeout_idx = stack.index('Rack::Timeout')
      attack_idx  = stack.index('Rack::Attack')

      assert_equal timeout_idx + 1, attack_idx,
        "Expected Rack::Attack immediately after Rack::Timeout after idempotent run. " \
        "Stack: #{stack.inspect}"
    end
  end
end
