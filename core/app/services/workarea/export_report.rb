module Workarea
  class ExportReport
    attr_reader :report, :csv

    def initialize(report, csv)
      @report = report
      @csv = csv
    end

    def save!
      report
        .reporting_class
        .collection
        .aggregate(report.aggregation + [{ '$out' => collection.name }])
        .first # make the aggregation run
    end

    def perform!
      save!
      has_headers = false

      for_each do |result|
        hash = result.to_h.except(*ignored_fields)

        unless has_headers
          csv << hash.keys
          has_headers = true
        end

        csv << hash.values
      end

    ensure
      destroy!
    end

    def destroy!
      collection.drop
    end

    def view_model
      @view_model ||= "Workarea::Admin::Reports::#{report.class.to_s.demodulize}ViewModel".constantize
    end

    def collection
      @collection ||= Mongo::Collection.new(
        report.reporting_class.collection.database,
        "#{report.class.name.demodulize.underscore}_#{Time.current.to_s(:export)}"
      )
    end

    def ignored_fields
      @ignored_fields ||= begin
        results = []

        for_each do |result|
          result.to_h.each do |key, value|
            results << key if value.is_a?(ApplicationDocument)
          end
        end

        results
      end
    end

    private

    def for_each
      i = 0

      while (results = get_results(skip: i)) && results.length > 0
        view_model.new(OpenStruct.new(results: results)).results.each do |result|
          yield(result)
          i += 1
        end
      end
    end

    def get_results(skip:)
      collection.find(
        {},
        skip: skip,
        sort: report.sort_value,
        limit: Workarea.config.reports_max_results
      ).to_a
    end
  end
end
