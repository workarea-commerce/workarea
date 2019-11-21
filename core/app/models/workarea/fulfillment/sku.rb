module Workarea
  class Fulfillment
    class Sku
      class InvalidPolicy < RuntimeError; end

      include ApplicationDocument
      extend Dragonfly::Model

      field :_id, type: String
      field :policy, type: String,  default: -> { self.class.policies.first }

      field :file_name, type: String
      field :file_uid, type: String

      dragonfly_accessor :file, app: :workarea
      validates :file, presence: true, if: -> { download? }

      def self.policies
        Workarea.config.fulfillment_policies.map(&:demodulize).map(&:underscore)
      end

      def self.process!(id, **args)
        find_or_initialize_by(id: id).process!(args)
      end

      def self.find_or_initialize_all(ids)
        existing = self.in(id: ids).to_a
        ids.map { |id| existing.detect { |sku| sku.id == id } || new(id: id) }
      end

      def name
        I18n.t('workarea.fulfillment_sku.name', id: id)
      end

      def process!(**args)
        policy_object.process(args)
      end

      def downloadable?
        download? && file.present?
      end

      def method_missing(sym, *args, &block)
        method = sym.to_s.chomp('?')
        return super unless self.class.policies.include?(method)

        method == policy
      end

      def respond_to_missing?(method_name, include_private = false)
        self.class.policies.include?(method_name.to_s.chomp('?')) || super
      end

      private

      def policy_object
        @policy_object ||= policy_class.new(self)
      end

      def policy_class
        "Workarea::Fulfillment::Policies::#{policy.classify}".constantize
      rescue NameError
        raise(
          InvalidPolicy,
          "Workarea::Fulfillment::Policies::#{policy.classify} must be a policy class"
        )
      end
    end
  end
end
