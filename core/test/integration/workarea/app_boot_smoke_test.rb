require 'test_helper'

require 'open3'
require 'timeout'

module Workarea
  class AppBootSmokeTest < Workarea::TestCase
    def test_dummy_app_can_boot
      core_root = File.expand_path('../../..', __dir__)

      env = {
        'RAILS_ENV' => 'test',
        # This smoke test validates boot across appraisals without requiring
        # running external services (MongoDB, Elasticsearch, Redis).
        'WORKAREA_SKIP_SERVICES' => 'true'
      }

      stdout = +''
      stderr = +''
      status = nil

      Timeout.timeout(60) do
        stdout, stderr, status = Open3.capture3(
          env,
          'bin/rails',
          'runner',
          "puts 'BOOT_OK'",
          chdir: core_root
        )
      end

      assert(status.success?, <<~MSG)
        Expected Workarea dummy app to boot successfully.

        Command:
          (cd #{core_root} && WORKAREA_SKIP_SERVICES=true bin/rails runner "puts 'BOOT_OK'")

        stdout:
        #{stdout}

        stderr:
        #{stderr}
      MSG

      assert_includes(stdout, 'BOOT_OK')
    end
  end
end
