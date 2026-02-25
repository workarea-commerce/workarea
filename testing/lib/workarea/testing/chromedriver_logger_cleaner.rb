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
    if browser.respond_to?(:logs)
      browser.logs.get(:browser)
    elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:logs)
      browser.manage.logs.get(:browser)
    else
      []
    end
  rescue NoMethodError
    []
  end

  def flush_logs!
    browser_logs.each do |log|
      message = Capybara::Chromedriver::Logger::Message.new(log)
      errors << message if message.error? && message.message =~ /Uncaught/

      log_destination.puts message.to_s unless should_filter?(message)
    end
  end
end
