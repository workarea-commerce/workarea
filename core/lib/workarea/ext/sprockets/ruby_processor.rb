module Sprockets
  module RubyProcessor
    VERSION = '1'

    def self.cache_key
      @cache_key ||= "#{name}:#{VERSION}".freeze
    end

    def self.call(input)
      context = input[:environment].context_class.new(input)
      context.extend(Workarea::Plugin::AssetAppendsHelper)
      context.extend(ActionView::Helpers)
      context.extend(InlineSvg::ActionView::Helpers)
      context.instance_eval(input[:data])
    end
  end

  register_engine '.ruby', RubyProcessor, mime_type: 'text/plain', silence_deprecation: true
end
