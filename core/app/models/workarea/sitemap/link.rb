module Workarea
  class Sitemap
    # Model object for representing a single link in the sitemap. A
    # sitemap XML file is composed of +<url />+ elements, and this class
    # helps to define the data that ends up in there.
    class Link
      delegate_missing_to :@taxon

      # @param [Workarea::Navigation::Taxon] taxon - Model this link is based on
      # @param [Workarea::GenerateSitemaps] generator - Worker class this link was instantiated from.
      def initialize(taxon:, generator:)
        @taxon = taxon
        @generator = generator
      end

      # Return the parsed +host+ from the given URL, or the default host
      # (+Workarea.config.host+) if a +Navigable+ model is being linked
      # to.
      def host
        return default_host unless fully_qualified_url?
        "#{uri.scheme}://#{uri.host}"
      end

      # Return the route path for the +Navigable+ model that is linked
      # to in this taxon, or the +url+ that was hard-coded into the
      # taxon at creation.
      def path
        return uri.path if url?

        @generator.send(route, navigable_slug)
      end

      private

      def route
        @route ||= "#{resource_name}_path"
      end

      def uri
        @uri ||= URI.parse(url)
      end

      def default_host
        scheme = Rails.configuration.force_ssl ? 'https' : 'http'
        "#{scheme}://#{Workarea.config.host}"
      end

      def fully_qualified_url?
        url? && uri.host.present? && uri.scheme.present?
      end
    end
  end
end
