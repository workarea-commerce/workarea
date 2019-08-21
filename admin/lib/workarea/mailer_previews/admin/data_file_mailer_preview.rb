module Workarea
  module Admin
    class DataFileMailerPreview < ActionMailer::Preview
      def export
        DataFileMailer.export(DataFile::Export.sample&.id)
      end

      def import
        DataFileMailer.import(DataFile::Import.successful.sample&.id)
      end

      def import_failure
        DataFileMailer.import_failure(DataFile::Import.failure.sample&.id)
      end

      def import_error
        DataFileMailer.import_error(DataFile::Import.error.sample&.id)
      end
    end
  end
end
