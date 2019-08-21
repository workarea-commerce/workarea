module Workarea
  class SearchSettingsSeeds
    def perform
      puts 'Adding search settings...'
      add_filters
    end

    private

    def add_filters
      Search::Settings.current.update_attributes!(
        terms_facets: %w(Color Size),
        range_facets: {
          'price' => [
            { to: 9.99 },
            { from: 10, to: 19.99 },
            { from: 20, to: 29.99 },
            { from: 30, to: 39.99 },
            { from: 40, to: 49.99 },
            { from: 50, to: 59.99 },
            { from: 60, to: 69.99 },
            { from: 70, to: 79.99 },
            { from: 80, to: 89.99 },
            { from: 90, to: 99.99 },
            { from: 100 }
          ]
        }
      )
    end
  end
end
