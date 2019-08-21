module Workarea
  class UndoRelease
    include Sidekiq::Worker

    def perform(release_id)
      release = Release.find(release_id)
      system_user = User.find_system_user!(release.name, 'Release')

      Mongoid::AuditLog.record(system_user) { release.undo! }

    rescue Mongoid::Errors::DocumentNotFound
      # Doesn't matter, release has been removed
    end
  end
end
