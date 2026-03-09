# frozen_string_literal: true

require 'test_helper'

module Workarea
  # Guardrails around Rails versioned defaults.
  #
  # Workarea is an engine, so `config.load_defaults` lives in the dummy apps.
  # Bumping it can introduce silent behavioral changes (cookies, cache formats,
  # middleware defaults, etc.). This test is intentionally simple: it forces any
  # `load_defaults` bump to be explicit + reviewed.
  #
  # Checklist reference:
  #   docs/rails7-migration-patterns/load-defaults-behavioral-flags.md
  class LoadDefaultsGuardrailTest < ActiveSupport::TestCase
    REPO_ROOT = Rails.root.join('../../..').expand_path.freeze

    DUMMY_APPS = {
      admin:      REPO_ROOT.join('admin/test/dummy/config/application.rb'),
      core:       Rails.root.join('config/application.rb'),
      storefront: REPO_ROOT.join('storefront/test/dummy/config/application.rb')
    }.freeze

    test 'dummy apps pin load_defaults explicitly (review required to change)' do
      expected = 'config.load_defaults 6.1'

      DUMMY_APPS.each do |name, path|
        assert File.exist?(path), "Expected dummy app config to exist for #{name}: #{path}"

        content = File.read(path)
        assert_includes(
          content,
          expected,
          <<~MSG
            Expected #{name} dummy app to include: #{expected}

            If you are intentionally bumping `config.load_defaults`, update the dummy app config
            and run through the checklist:
              docs/rails7-migration-patterns/load-defaults-behavioral-flags.md

            File: #{path}
          MSG
        )
      end
    end
  end
end
