module Workarea
  class GenerateSitemaps
    include Sidekiq::Worker
    include Storefront::Engine.routes.url_helpers

    def perform(*)
      begin
        create_sitemap
        store_sitemap

        SitemapGenerator::Sitemap.ping_search_engines if Rails.env.production?
      ensure
        FileUtils.rm_rf(tmp_dir)
      end
    end

    private

    def tmp_dir
      @tmp_dir ||= Dir.mktmpdir
    end

    def create_sitemap
      per_batch = 100
      generator = self

      SitemapGenerator::Sitemap.default_host = "https://#{Workarea.config.host}"
      SitemapGenerator::Sitemap.public_path = tmp_dir
      SitemapGenerator::Sitemap.create do
        #
        # Products
        #
        #
        Catalog::Product.all.each_by(per_batch) do |product|
          next unless product.active?
          add generator.product_path(product), changefreq: 'daily'
        end

        #
        # Navigation Links
        #
        #
        Navigation::Taxon.all.each_by(per_batch) do |taxon|
          next unless taxon.show_in_sitemap?

          entry = Sitemap::Link.new(taxon: taxon, generator: generator)

          add entry.path, changefreq: 'weekly', host: entry.host
        end
      end
    end

    def store_sitemap
      Dir[File.join(tmp_dir, '*.xml.gz')].each do |path|
        file_name = path.split('/').last
        matches = /\d/.match(file_name) || []
        index = matches[0]

        sitemap = Workarea::Sitemap.find_or_initialize_by_index(index)
        sitemap.file = File.new(path)
        sitemap.save!
      end
    end

    # Provide URL options for route helper calls on this worker instance.
    # Rails 7 requires a +:host+ key when absolute-URL helpers (+_url+ suffix)
    # are called outside of a controller/mailer context.  Workers have no
    # request context, so we source the host from +Workarea.config.host+.
    # The locale key ensures locale-scoped path helpers suppress the locale
    # segment for the default locale.
    def default_url_options
      { host: Workarea.config.host, locale: locale }
    end

    def locale
      @locale ||= ::I18n.locale != ::I18n.default_locale ? ::I18n.locale : nil
    end
  end
end
