module Workarea
  module JbuilderAppendPartials
    def append_partials(name, locals = {})
      appends = ::Workarea::Plugin.partials_appends[name]
      return if appends.blank?

      appends.inject([]) do |arr, paths|
        Array.wrap(paths).each do |path|
          @context.render(partial: path, locals: locals.merge(json: self))
        end
      end
    end
  end
end

JbuilderTemplate.prepend(Workarea::JbuilderAppendPartials)
