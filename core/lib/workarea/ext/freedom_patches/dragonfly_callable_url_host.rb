#
# This adds basic support for running +#call+ on the +url_host+
# configuration given to Dragonfly during app initialization. It's
# currently an open pull request on markevans/dragonfly, but it doesn't
# seem likely that it will be merged anytime soon. However, if this does
# become a feature of Dragonfly in the future, the following code can be
# removed from our platform after we upgrade to the newest version.
#
# PR: https://github.com/markevans/dragonfly/pull/502
#
decorate Dragonfly::Server do
  decorated do
    attr_writer :url_host
  end

  def call(env)
    @request = Rack::Request.new(env)
    super
  end

  def url_host
    if !@url_host.nil? && @url_host.respond_to?(:call)
      @url_host.call(@request)
    else
      @url_host
    end
  end
end
