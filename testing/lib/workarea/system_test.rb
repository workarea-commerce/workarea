require 'capybara/rails'
require 'webdrivers'
require 'puma'
require 'capybara/chromedriver/logger'
require 'workarea/integration_test'
require 'workarea/testing/custom_capybara_matchers'
require 'workarea/testing/headless_chrome'
require 'workarea/testing/chromedriver_logger_cleaner'

# get options on load to ensure initial configuration is captured.
# Capybara.register_driver does not execute the passed block immediately, which
# can cause issues with the aliasing of Workarea.config.headless_chrome_options.
# This can be removed in the upcoming minor to rename that configuration.
chrome_options = Workarea::HeadlessChrome.options

Capybara.server_errors = [Exception]
Capybara.automatic_label_click = true
Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: chrome_options,
      loggingPrefs: {
        browser: 'ALL'
      }
    )
  )
end

# Fail tests when JS errors are thrown.
Capybara::Chromedriver::Logger.raise_js_errors = true

# Ignore common error responses for `/current_user.json` and /login`.
# These occur during the normal course of testing authentication, so
# they don't need to be output in the test results.
Capybara::Chromedriver::Logger.filters = [
  /(login|current_user\.json) - Failed to load resource: the server responded with a status of (401|422)/
]

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :headless_chrome

# If builds want to stick to poltegeist to avoid the pain of upgrading, see if
# we can define the driver for them. TODO remove in v4
if defined?(Capybara::Poltergeist)
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: true)
  end
end

# Because each plugin adds more time to template resolution, more plugins mean
# slower tests. This is accommodate that slowdown :(
default = ENV['WORKAREA_CAPYBARA_MAX_WAIT_TIME'].presence || 10
Capybara.default_max_wait_time = [Workarea::Plugin.installed.size, default.to_i].max

# When you change a route, it doesn't see that JS routes needs to be expired.
FileUtils.rm_rf(Rails.root.join('tmp', 'cache', 'assets', 'sprockets'))

# Default screenshots to simple output of file path
ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] ||= 'simple'

module Workarea
  class SystemTest < ActionDispatch::SystemTestCase
    extend TestCase::Decoration
    include TestCase::Configuration
    include TestCase::Workers
    include TestCase::SearchIndexing
    include TestCase::Mail
    include TestCase::RunnerLocation
    include TestCase::Locales
    include TestCase::S3
    include TestCase::Encryption
    include TestCase::Geocoder
    include Factories
    include IntegrationTest::Configuration
    include IntegrationTest::Locales
    include Rails.application.routes.mounted_helpers

    driven_by :headless_chrome

    setup do
      reset_window_size
    end

    teardown do
      Capybara::Chromedriver::Logger::TestHooks.after_example! if javascript?
    end

    # This is to make sure Chrome chills out and allows XHR requests to finish
    # before going nuts on the page. Theoretically, Capybara does this for you.
    # Of course in theory, theory works.
    #
    (%i(visit refresh go_back go_forward within within_frame) + Capybara::Session::NODE_METHODS).each do |method|
      class_eval <<-ruby
        def #{method}(*)
          return super unless javascript?

          wait_for_xhr
          super.tap { wait_for_xhr }
        end
      ruby
    end

    # Waits until all XHR requests have finished, according
    # to jQuery. Times out according to Capybara's set timeout.
    # Used to solve race conditions between XHR requests and
    # assertions.
    #
    def wait_for_xhr(time=Capybara.default_max_wait_time)
      Timeout.timeout(time) do
        loop until finished_all_xhr_requests?
      end
    rescue Timeout::Error => error
      javascript_errors = page.driver.browser.manage.logs.get(:browser).each do |log_entry|
        log_entry.level == 'SEVERE' && /Uncaught/.match?(log_entry.message)
      end
      if javascript_errors.present?
        raise(
          Timeout::Error,
          <<~eos
            Problem:
              JavaScript errors were detected during Workarea::SystemTest#wait_for_xhr.
              You might have an error in an XHR callback.  wait_for_xhr is a test helper
              that checks if there are any unfinished XHR requests.  This is called
              automatically throughout testing in Capybara interactions to ensure
              consistency in test results.
            Errors:
              #{javascript_errors.map(&:message).join("\r")}
          eos
        )
      else
        raise error
      end
    end

    # Resets the dimensions of the testing browser
    def reset_window_size
      return unless javascript?

      page.driver.browser.manage.window.resize_to(
        Workarea.config.capybara_browser_width,
        Workarea.config.capybara_browser_height
      )
    end

    def javascript?
      Capybara.current_driver == Capybara.javascript_driver
    end

    def scroll_to_bottom
      page.execute_script('window.scrollBy(0, 9999999)')
    end

    def scroll_to_bottom
      page.execute_script('window.scrollBy(0, 9999999)')
    end

    def currency
      Money.default_currency.symbol
    end

    private

    def finished_all_xhr_requests?
      return unless javascript?

      page.evaluate_script("!window['jQuery'] || jQuery.active === 0")
    end
  end
end
