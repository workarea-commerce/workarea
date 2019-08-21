module Dragonfly
  module Model
    class Attachment
      module DisableDatastoreDestroy
        def destroy_content(*)
          # We don't want to destroy original content, in case assets need to
          # retrieved or the admin restores from the trash.
        end
      end

      prepend DisableDatastoreDestroy
    end
  end
end
