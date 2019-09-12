module Workarea
  class SavePublishing
    delegate :errors, to: :release, allow_nil: true

    def initialize(releasable, params)
      @releasable = releasable
      @params = params
    end

    def perform
      return false if release.present? && !release.valid?
      return true if @releasable.blank?

      Release.with_current(release.try(:id)) do
        @releasable.update!(active: activate?, active_segment_ids: active_segment_ids)
      end
    end

    def release
      return if @params[:activate].in?(%w(now never))

      @release ||=
        if @params[:activate] == 'new_release'
          Release.create(@params[:release])
        else
          Release.find(@params[:activate])
        end
    end

    def activate?
      @params[:activate] != 'never'
    end

    def active_segment_ids
      Array.wrap(@params[:active_segment_ids])
    end
  end
end
