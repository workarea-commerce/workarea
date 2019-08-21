module Workarea
  class BulkAction
    class Deletion < BulkAction
      field :model_type, type: String

      def act_on!(model)
        model.destroy
      end
    end
  end
end
