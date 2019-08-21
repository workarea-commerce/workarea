module Workarea
  class DirectUpload
    class Asset
      include Processor

      def perform
        Content::Asset.create!(
          file: direct_upload.file,
          file_name: direct_upload.filename
        )
      end
    end
  end
end
