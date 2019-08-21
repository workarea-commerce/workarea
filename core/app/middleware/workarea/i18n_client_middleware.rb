module Workarea
  class I18nClientMiddleware
    def call(worker, msg, queue, *)
      msg['locale'] = I18n.locale.to_s
      yield
    end
  end
end
