module Workarea
  class Lint
    attr_reader :warnings, :errors

    def self.run
      lint_classes.each do |klass|
        puts "\e[#{Workarea::COLOR_CODES[:yellow]}m== Linting #{klass.name.demodulize.titleize}...\e[0m"
        lint = klass.new
        lint.run

        message = "#{lint.warnings} warnings, #{lint.errors} errors"
        color = if lint.warnings.zero? && lint.errors.zero?
                  :green
                elsif lint.errors.zero?
                  :yellow
                else
                  :red
                end

        puts "\e[#{Workarea::COLOR_CODES[color]}m#{message}\e[0m"
        puts ''
      end
    end

    def self.lint_classes
      lints_paths.map { |path| load_lint_classes(path) }.flatten.compact
    end
    singleton_class.send(:alias_method, :load_lints, :lint_classes)

    def self.lints_paths
      lints_path = 'lib/workarea/lint/*.rb'
      ["#{Core::Engine.root}/#{lints_path}"] +
        Plugin.installed.map { |p| "#{p.root}/#{lints_path}" } +
        ["#{Rails.root}/#{lints_path}"]
    end

    def self.load_lint_classes(path)
      klasses = []

      Dir[path].each do |file|
        require file

        class_name = file.split('/').last.gsub('.rb', '').camelize

        begin
          klasses << "Workarea::Lint::#{class_name}".constantize
        rescue NameError
          puts <<-eos.strip_heredoc
            Could not load #{class_name} from #{file},
            make sure file name matches class name.
          eos
        end
      end

      klasses
    end

    def initialize
      @warnings = 0
      @errors = 0
    end

    def run
      raise NotImplementedError, "#{self.class.name} must implement #run"
    end

    def warn(message)
      @warnings += 1
      puts message unless Rails.env.test?
    end

    def error(message)
      @errors += 1
      puts message unless Rails.env.test?
    end

    def catalog_skus
      @catalog_skus ||= Catalog::Product.all.distinct('variants.sku')
    end

    def pricing_skus
      @pricing_skus ||= Pricing::Sku.all.distinct(:id)
    end

    def inventory_skus
      @inventory_skus ||= Inventory::Sku.all.distinct(:id)
    end
  end
end
