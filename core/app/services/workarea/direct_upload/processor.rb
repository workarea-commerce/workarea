module Workarea
  class DirectUpload
    module Processor
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_reader :direct_upload
      end

      def initialize(direct_upload)
        @direct_upload = direct_upload
      end

      def perform
        raise NotImplementedError
      end
    end
  end
end
