module Workarea
  class PagedArray < Array
    attr_reader :items, :page, :per_page, :total

    def self.from(items, page, per_page, total)
      new(items, page, per_page, total)
    end

    def initialize(items = [], page = 1, per_page = 25, total = 0)
      @items = items
      @page = page.to_i
      @per_page = per_page.to_i
      @total = total.to_i
      super(items)
    end

    def first_page?
      page == 1
    end

    def last_page?
      current_page == total_pages
    end

    def total_pages
      (total / per_page.to_f).ceil
    end

    def current_page
      @page
    end

    def total_count
      total
    end
  end
end
