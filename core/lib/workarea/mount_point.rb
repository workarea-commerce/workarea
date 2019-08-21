module Workarea
  module MountPoint
    mattr_accessor :cache

    def self.find(klass)
      self.cache ||= {}
      return cache[klass] if cache[klass]

      cache[klass] = Rails.application.routes.named_routes.detect do |route|
        route.last.app.app == klass
      end.try(:first)
    end

    def mount_point
      Workarea::MountPoint.find(self)
    end

    def mounted?
      mount_point.present?
    end

    def mount_path
      return nil unless mounted?
      routes.url_helpers.root_path
    end
  end
end
