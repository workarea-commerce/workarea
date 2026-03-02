require 'capybara/rails'

require 'puma'
require 'workarea/integration_test'
require 'workarea/testing/custom_capybara_matchers'
require 'workarea/testing/headless_chrome'

# get options on load to ensure initial configuration is captured.
# Capybara.register_driver does not execute the passed block immediately, which
# can cause issues with the aliasing of Workarea.config.headless_chrome_options.
# This can be removed in the upcoming minor to rename that configuration.
chrome_options = Workarea::HeadlessChrome.options

Capybara.server_errors = [Exception]
Capybara.automatic_label_click = true
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.fetch(:args, []).each { |arg| options.add_argument(arg) }

  # Enable browser logging so we can capture JS errors.
  options.logging_prefs = { browser: 'ALL' }

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :headless_chrome

# Because each plugin adds more time to template resolution, more plugins mean
# slower tests. This is accommodate that slowdown :(
default = ENV['WORKAREA_CAPYBARA_MAX_WAIT_TIME'].presence || 10
Capybara.default_max_wait_time = [Workarea::Plugin.installed.size, default.to_i].max

# When you change a route, it doesn't see that JS routes needs to be expired.
FileUtils.rm_rf(Rails.root.join('tmp', 'cache', 'assets', 'sprockets'))

# Default screenshots to simple output of file path
ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] ||= 'simple'

# JS error patterns to ignore during system tests. These occur during
# normal authentication testing flows and are not real failures.
WORKAREA_IGNORED_JS_ERROR_PATTERNS = [
  /(login|current_user\.json) - Failed to load resource: the server responded with a status of (401|422)/
].freeze

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

    # Default to headless Chrome, but allow local/dev environments without Chrome
    # installed to run non-system tests.
    if ENV['WORKAREA_SKIP_SYSTEM_TESTS'] =~ /true/i
      driven_by :rack_test
    else
      driven_by :headless_chrome
    end

    setup do
      reset_window_size
    end

    teardown do
      check_for_js_errors if javascript?
    end

    # This is to make sure Chrome chills out and allows XHR requests to finish
    # before going nuts on the page. Theoretically, Capybara does this for you.
    # Of course in theory, theory works.
    #
    (%i(visit refresh go_back go_forward within within_frame) + Capybara::Session::NODE_METHODS).each do |method|
      class_eval <<-ruby
        def #{method}(*args, **kwargs, &block)
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
      javascript_errors = collect_js_errors
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

    def currency
      Money.default_currency.symbol
    end

    private

    def finished_all_xhr_requests?
      return unless javascript?

      page.evaluate_script("!window['jQuery'] || jQuery.active === 0")
    end

    # Collect browser log entries that indicate JavaScript errors.
    # Uses the Selenium logging API, which works across selenium-webdriver 4.x.
    def collect_js_errors
      logs = begin
        page.driver.browser.logs.get(:browser)
      rescue NoMethodError, Selenium::WebDriver::Error::WebDriverError
        begin
          page.driver.browser.manage.logs.get(:browser)
        rescue NoMethodError, Selenium::WebDriver::Error::WebDriverError
          []
        end
      end

      logs.select do |entry|
        entry.level == 'SEVERE' && /Uncaught/.match?(entry.message)
      end
    end

    # Check for unhandled JS errors at the end of each test.
    # Raises if SEVERE/Uncaught errors are found (excluding filtered patterns).
    def check_for_js_errors
      errors = collect_js_errors.reject do |entry|
        WORKAREA_IGNORED_JS_ERROR_PATTERNS.any? { |pat| pat.match?(entry.message) }
      end

      return if errors.blank?

      raise Minitest::Assertion, <<~msg
        JavaScript errors detected during test:
          #{errors.map(&:message).join("\n  ")}
      msg
    end
  end
end
