module Workarea
  module Help
    class Asset
      include ApplicationDocument
      extend Dragonfly::Model

      field :file_name, type: String
      field :file_uid, type: String

      dragonfly_accessor :file, app: :workarea
      validates :file, presence: true

      def respond_to_missing?(method_name, include_private = false)
        super || file.respond_to?(method_name)
      end

      def method_missing(sym, *args, &block)
        if file.respond_to?(sym)
          file.send(sym, *args, &block)
        else
          super
        end
      end
    end
  end
end
