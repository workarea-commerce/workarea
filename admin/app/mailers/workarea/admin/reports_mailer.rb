module Workarea
  module Admin
    class ReportsMailer < Admin::ApplicationMailer
      def export(id)
        @export = Workarea::Reports::Export.find(id)

        mail(
          bcc: @export.emails,
          from: Workarea.config.email_from,
          subject: t(
            'workarea.admin.reports_mailer.export.subject',
            name: @export.name.downcase
          )
        )
      end
    end
  end
end
