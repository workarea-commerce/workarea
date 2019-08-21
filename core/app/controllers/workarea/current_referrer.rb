module Workarea
  module CurrentReferrer
    def current_referrer
      return @current_referrer if defined?(@current_referrer)

      referrer = cookies['workarea_referrer']
      return unless referrer.present?

      @current_referrer ||= TrafficReferrer.new(
        Workarea.referrer_parser.parse(referrer).slice(:source, :medium, :uri)
      )
    end
  end
end
