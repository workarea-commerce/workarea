module Workarea
  module Admin
    class DataFileMailer < Admin::ApplicationMailer
      include NavigationHelper

      helper_method :index_url_for
      rescue_from Mongoid::Errors::DocumentNotFound, with: {} # ignore, noop

      def export(id)
        @export = DataFile::Export.find(id)

        mail(
          bcc: @export.emails,
          from: Workarea.config.email_from,
          subject: t(
            'workarea.admin.data_file_mailer.export.subject',
            name: @export.name.downcase
          )
        )
      end

      def import(id)
        @import = DataFile::Import.find(id)
        @user = User.find(@import.created_by_id)
        @release = Release.find(@import.release_id) if @import.within_release?

        mail(
          to: @user.email,
          from: Workarea.config.email_from,
          subject: t(
            'workarea.admin.data_file_mailer.import.subject',
            type: @import.name.downcase,
            file: @import.file_name
          )
        )
      end

      def import_failure(id)
        @import = DataFile::Import.find(id)
        @user = User.find(@import.created_by_id)

        mail(
          to: @user.email,
          from: Workarea.config.email_from,
          subject: t(
            "workarea.admin.data_file_mailer.import_failure.subject",
            type: @import.name.downcase,
            file: @import.file_name
          )
        )
      end

      def import_error(id)
        @import = DataFile::Import.find(id)
        @user = User.find(@import.created_by_id)

        mail(
          to: @user.email,
          from: Workarea.config.email_from,
          subject: t(
            'workarea.admin.data_file_mailer.import_error.subject',
            type: @import.name.downcase,
            file: @import.file_name
          )
        )
      end
    end
  end
end
