module Workarea
  class Content
    module AssetLookup
      def find_asset_id_by_file_name(file_name)
        proc do
          (
            Workarea::Content::Asset.where(file_name: file_name).first ||
            Workarea::Content::Asset.image_placeholder
          ).try(:id)
        end
      end
    end
  end
end
