module Workarea
  class MailInterceptor
    def self.delivering_email(message)
      message.perform_deliveries = false unless deliver?(message)
    end

    def self.deliver?(message)
      if Workarea.config.send_email.respond_to?(:call)
        Workarea.config.send_email.call(message)
      else
        !!Workarea.config.send_email
      end
    end
  end
end
