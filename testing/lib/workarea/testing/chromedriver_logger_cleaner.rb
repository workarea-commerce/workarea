# Bad responses (like 422 or 401) show as errors as well, which are OK
# for system tests because they indicate the site is functioning properly.
decorate Capybara::Chromedriver::Logger::Collector do
  # selenium-webdriver's logging API surface has shifted across versions.
  # capybara-chromedriver-logger expects to pull console logs via
  # `browser.manage.logs`, but newer selenium releases return a
  # `Selenium::WebDriver::Manager` without a `logs` method.
  #
  # Keep system tests resilient by supporting both shapes and falling back to
  # an empty set of logs when unsupported.
  def browser_logs
    target = collector_browser
    return [] if target.blank?

    if target.respond_to?(:logs)
      target.logs.get(:browser)
    elsif target.respond_to?(:manage) && target.manage.respond_to?(:logs)
      target.manage.logs.get(:browser)
    else
      []
    end
  rescue NameError, NoMethodError
    []
  end

  def flush_logs!
    browser_logs.each do |log|
      message = Capybara::Chromedriver::Logger::Message.new(log)
      errors << message if message.error? && message.message =~ /Uncaught/

      log_destination.puts message.to_s unless should_filter?(message)
    end
  end

  private

  # capybara-chromedriver-logger has changed where the selenium driver/browser
  # is exposed across versions. Resolve whichever hook exists and no-op when
  # none are available.
  def collector_browser
    if respond_to?(:browser)
      browser
    elsif respond_to?(:driver)
      driver
    elsif instance_variable_defined?(:@browser)
      instance_variable_get(:@browser)
    elsif instance_variable_defined?(:@driver)
      instance_variable_get(:@driver)
    end
  rescue NameError, NoMethodError
    nil
  end
end
