# These fixes allow us to default locale to nil so routes in tests can be
# generated as expected. This is unbelievably shitty and makes me really sad.
# Details on this can be found here: https://github.com/rspec/rspec-rails/issues/255
# This combination of monkey patchs are the only thing I could find to cover
# all cases.

class ActionView::TestCase::TestController
  def default_url_options(options={})
    if options.key?(:locale) || options.key?('locale')
      options
    else
      { locale: nil }.merge(options)
    end
  end
end

class ActionDispatch::Routing::RouteSet
  module WorkareaLocaleFixes
    def default_url_options
      result = super

      if !result.key?(:locale) && !result.key?('locale')
        result[:locale] = nil
      end

      result
    end
  end
end

ActionDispatch::Routing::RouteSet.prepend(
  ActionDispatch::Routing::RouteSet::WorkareaLocaleFixes
)
