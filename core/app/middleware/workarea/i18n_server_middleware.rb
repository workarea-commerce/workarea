module Workarea
  class I18nServerMiddleware
    def call(worker, msg, queue)
      if msg['locale'].present?
        ::I18n.with_locale(msg['locale']) { yield }
      else
        yield
      end
    end
  end
end
