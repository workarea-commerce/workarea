decorate JbuilderTemplate, with: :workarea do
  def _cache_fragment_for(*)
    return yield if workarea_admin?

    super
  end

  def _cache_key(*)
    super.tap do |result|
      result << workarea_cache_varies if workarea_cache_varies.present?
    end
  end

  private

  def workarea_admin?
    @context&.controller&.current_user&.admin?
  rescue ::RuntimeError
    false
  end

  def workarea_cache_varies
    workarea_request_env['workarea.cache_varies']
  end

  def workarea_request_env
    @context.controller.request.env || {}
  end
end
