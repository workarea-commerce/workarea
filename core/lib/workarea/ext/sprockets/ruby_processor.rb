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

  # Sprockets 4 removed `register_engine` in favor of `register_mime_type` +
  # `register_transformer`. Sprockets 3 uses `register_engine` with the
  # `silence_deprecation` option to suppress the upgrade warning.
  # We detect the version at load-time and call the appropriate API so the
  # `.ruby` extension works across both Sprockets 3.x and 4.x.
  if Gem::Version.new(Sprockets::VERSION) >= Gem::Version.new('4.0')
    # Sprockets 4 API:
    # 1. Register the MIME type for the .ruby extension (maps to text/x-ruby).
    # 2. Register a transformer that converts text/x-ruby → text/plain by
    #    running RubyProcessor. The output MIME type (text/plain) is what
    #    allows further processors (e.g. EJS) to pick up the result.
    register_mime_type 'text/x-ruby', extensions: ['.ruby']
    register_transformer 'text/x-ruby', 'text/plain', RubyProcessor
  else
    # Sprockets 3 API (deprecated but functional in 3.7.x):
    register_engine '.ruby', RubyProcessor, mime_type: 'text/plain', silence_deprecation: true
  end
end
