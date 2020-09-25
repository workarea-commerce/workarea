module Workarea
  class TaxonomySitemap
    include Search::Pagination

    attr_reader :params
    delegate :first_page?, :last_page?, :next_page, :prev_page, :total_pages, :current_page,
      to: :taxons

    def initialize(params = {})
      @params = params
    end

    def second_page?
      page == 2
    end

    def taxons
      @taxons ||=
        Navigation::Taxon
          .page(page)
          .per(per_page)
          .any_of({ :url.ne => nil }, { :navigable_id.ne => nil })
          .reorder(:parent_ids.asc)
    end

    def results
      @results ||= taxons.select(&:show_in_sitemap?)
    end

    def cache_key
      ['taxonomy_sitemap', I18n.locale, page, per_page].join('/')
    end
  end
end
