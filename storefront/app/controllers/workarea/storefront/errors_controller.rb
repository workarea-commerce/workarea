module Workarea
  module Storefront
    class ErrorsController < Storefront::ApplicationController
      after_action :skip_session

      def not_found
        redirect_url = Navigation::Redirect.find_destination(
          request.env['action_dispatch.original_path']
        )

        if redirect_url.present?
          redirect_to redirect_url, status: :moved_permanently
        else
          render_error_page(404)
        end
      end

      def internal
        # This ensures any exception handling (e.g. Airbrake or Sentry) will see
        # the error in their middleware, and then report on it.
        request.env['rack.exception'] = request.env['action_dispatch.exception']
        render_error_page(500)
      end

      def offline
        content = Content.for('offline')
        @content = ContentViewModel.wrap(content)

        render('workarea/storefront/errors/show')
      end

      private

      def render_error_page(error_status)
        name = Rack::Utils::HTTP_STATUS_CODES[error_status].titleize

        respond_to do |format|
          format.all do
            if !request.format.html?
              head error_status
            elsif content = Content.for(name)
              @content = ContentViewModel.new(content)

              render(
                template: 'workarea/storefront/errors/show',
                status: error_status
              )
            else
              render(
                file: "#{Rails.root}/public/#{error_status}.html",
                layout: nil,
                status: error_status
              )
            end
          end
        end
      end

      def skip_session
        request.session_options[:skip] = true
      end
    end
  end
end
