module Workarea
  module BreakpointHelpers
    # Resizes the headless browser viewport width & height to a given breakpoint
    # as defined in Workarea.config.storefront_break_points.
    # Height is calculated as 16:9 aspect ratio.
    #
    def resize_window_to(breakpoint_name)
      breakpoint = breakpoint_for(breakpoint_name)
      return unless breakpoint.present?
      resize_window_by(breakpoint, aspect_ratio_height(breakpoint))
    end

    private

    def resize_window_by(width, height)
      page.driver.browser.manage.window.resize_to(width, height)
    end

    def breakpoint_for(size_name)
      Workarea.config.storefront_break_points[size_name.to_sym]
    end

    def aspect_ratio_height(width)
      width / (9 / 16.0)
    end
  end
end
