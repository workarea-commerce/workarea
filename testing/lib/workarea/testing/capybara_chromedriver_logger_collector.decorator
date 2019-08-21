# Bad responses (like 422 or 401) show as errors as well, which are OK
# for system tests because they indicate the site is functioning properly.
decorate Capybara::Chromedriver::Logger::Collector do
  def flush_logs!
    browser_logs.each do |log|
      message = Capybara::Chromedriver::Logger::Message.new(log)
      errors << message if message.error? && message.message =~ /Uncaught/

      log_destination.puts message.to_s unless should_filter?(message)
    end
  end
end
