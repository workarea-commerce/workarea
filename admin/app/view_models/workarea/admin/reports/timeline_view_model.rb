module Workarea
  module Admin
    module Reports
      class TimelineViewModel < ApplicationViewModel
        include GroupByTime

        class Event
          def self.build(releases, custom_events)
            result = Hash.new { |h, k| h[k] = [] }

            releases.each do |release|
              result[release.published_at.to_date] << new(
                Workarea::Admin::ReleaseViewModel.wrap(release),
                type: 'release',
                occurred_at: release.published_at
              )
            end

            custom_events.each do |event|
              result[event.occurred_at.to_date] << new(
                event,
                type: 'custom_event',
                occurred_at: event.occurred_at
              )
            end

            result.sort.to_h
          end

          delegate_missing_to :@model
          attr_reader :model, :type, :occurred_at

          def initialize(model, type:, occurred_at:)
            @model = model
            @type = type
            @occurred_at = occurred_at
          end
        end

        def summary
          {
            revenue: summarize(graph_data_for('revenue')),
            orders: summarize(graph_data_for('orders')),
            units_sold: summarize(graph_data_for('units_sold')),
            customers: summarize(graph_data_for('customers')),
            releases: summarize(graph_data_for('releases')),
            custom_events: summarize(graph_data_for('custom_events'))
          }
        end

        def graph_data
          {
            labels: grouped_data.keys.reverse,
            datasets: {
              # Note: Order is important. Chart.js layers chart data from the
              # top down.
              releases: transform(graph_data_for('releases')),
              custom_events: transform(graph_data_for('custom_events')),
              revenue: transform(graph_data_for('revenue')),
              orders: transform(graph_data_for('orders')),
              units_sold: transform(graph_data_for('units_sold')),
              customers: transform(graph_data_for('customers'))
            }
          }
        end

        def events
          @events ||= begin
            Event
              .build(releases, custom_events)
              .each_with_object({}) do |(date, events), group|
                group[date] = events.sort_by(&:occurred_at)
              end
          end
        end

        private

        def releases
          @releases ||= Release.published_between(
            starts_at: starts_at,
            ends_at: ends_at
          ).to_a
        end

        def custom_events
          @custom_events ||= Workarea::Reports::CustomEvent.occurred_between(
            starts_at: starts_at.to_date,
            ends_at: ends_at.to_date
          ).to_a
        end

        def date_range
          starts_at.to_date..ends_at.to_date
        end

        def grouped_data
          date_range.each_with_object({}) do |date, group|
            group[date] = results.select { |r| r.starts_at.to_date == date }
          end
        end

        def graph_data_for(type)
          return release_graph_data if type == 'releases'
          return custom_event_graph_data if type == 'custom_events'

          grouped_data.transform_values do |values|
            (values || []).map { |v| v[type] }
          end
        end

        def release_graph_data
          date_range.each_with_object({}) do |date, group|
            data = releases.select { |r| r.published_at.to_date == date }
            group[date] = [data.count]
          end
        end

        def custom_event_graph_data
          date_range.each_with_object({}) do |date, group|
            data = custom_events.select { |r| r.occurred_at.to_date == date }
            group[date] = [data.count]
          end
        end

        def transform(data)
          data.map { |k, v| Hash[x: k.to_time, y: v.first] }.reverse
        end

        def summarize(data)
          data
            .select { |_, v| ! v.empty? }
            .reduce(0) { |sum, (_k, v)| sum + v.first }
        end
      end
    end
  end
end
