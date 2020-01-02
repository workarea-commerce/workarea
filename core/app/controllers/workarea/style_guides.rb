module Workarea
  module StyleGuides
    def index
    end

    def show
      module_path = self.class.module_parent.name.underscore
      category = "#{module_path}/style_guides/#{params[:category]}"

      if lookup_context.exists?(params[:id], [category], true)
        @style_guide_partial = "#{category}/#{params[:id]}"
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
