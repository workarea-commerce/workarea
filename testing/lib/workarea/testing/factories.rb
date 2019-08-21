module Workarea
  module Factories
    #
    # Factory method module registration
    #
    #

    mattr_accessor :plugins, :included_in
    self.plugins ||= []
    self.included_in ||= []

    def self.add(mod)
      self.plugins << mod
      included_in.each { |c| plugins.each { |p| c.include p } }
    end

    def self.included(mod)
      included_in << mod
      plugins.each { |p| mod.send(:include, p) }
    end

    def self.require_factories
      core_factories = Workarea::Testing::Engine
        .root
        .join('lib', 'workarea', 'testing', 'factories', '**', '*.rb')

      Dir[core_factories].each do |factory_file|
        require factory_file
      end

      Workarea::Plugin.installed.each do |plugin|
        Dir[plugin.root.join('test', 'factories', '**', '*.rb')].each do |factory_file|
          require factory_file
        end
      end
    end

    def factory_defaults_config
      Workarea.config.testing_factory_defaults
    end

    def factory_defaults(factory)
      default = factory_defaults_config.send(factory)
      default.respond_to?(:call) ? self.instance_eval(&default) : default
    end

    #
    # Misc factory methods
    #
    #

    mattr_accessor :email_signup_count, :user_count, :shipping_service_count, :tax_categories_count
    self.email_signup_count = 0
    self.user_count = 0
    self.shipping_service_count = 0
    self.tax_categories_count = 0

    def create_release(overrides = {})
      attributes = factory_defaults(:release).merge(overrides)
      Release.create!(attributes)
    end

    def create_email_signup(overrides = {})
      attributes = factory_defaults(:email_signup).merge(overrides)
      Email::Signup.create!(attributes).tap do
        Factories.email_signup_count += 1
      end
    end

    def create_shipping(overrides = {})
      attributes = factory_defaults(:shipping).merge(overrides)
      Shipping.create!(attributes)
    end

    def create_shipping_service(overrides = {})
      attributes = factory_defaults(:shipping_service).merge(overrides)

      Shipping::Service.new(attributes.except(:rates)).tap do |service|
        if attributes[:rates].present?
          attributes[:rates].each do |attrs|
            service.rates.build(attrs)
          end
        end

        service.save!
        Factories.shipping_service_count += 1
      end
    end

    def create_tax_category(overrides = {})
      attributes = factory_defaults(:tax_category).merge(overrides)

      Tax::Category.new(attributes.except(:rates)).tap do |category|
        if attributes[:rates].present?
          attributes[:rates].each do |attrs|
            category.rates.build(attrs)
          end
        end

        category.save!
        category.rates.each(&:save!)

        Factories.tax_categories_count += 1
      end
    end

    def create_inventory(overrides = {})
      attributes = factory_defaults(:inventory).merge(overrides)
      Inventory::Sku.new(attributes).tap do |sku|
        sku.id = attributes[:id] if attributes[:id].present?
        sku.save!
      end
    end

    def create_help_article(overrides = {})
      attributes = factory_defaults(:help_article).merge(overrides)
      Help::Article.create!(attributes)
    end

    def create_shipping_sku(overrides = {})
      attributes = factory_defaults(:shipping_sku).merge(overrides)
      Shipping::Sku.create!(attributes)
    end

    def create_audit_log_entry(overrides = {})
      attributes = factory_defaults(:audit_log_entry).merge(overrides)
      Mongoid::AuditLog::Entry.create!(attributes)
    end

    def create_admin_visit(overrides = {})
      attributes = factory_defaults(:admin_visit).merge(overrides)
      Workarea::User::AdminVisit.create!(attributes)
    end

    def create_admin_bookmark(overrides = {})
      attributes = factory_defaults(:admin_bookmark).merge(overrides)
      Workarea::User::AdminBookmark.create!(attributes)
    end

    def create_tempfile(content, name: 'foo', extension: 'txt', encoding: nil)
      file = Tempfile.new([name, ".#{extension}"], encoding: encoding)
      file.write(content)
      file.tap(&:close)
    end
  end
end
