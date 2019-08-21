module Workarea
  module Admin
    module Dashboards
      module InsightsGraphs
        extend ActiveSupport::Concern
        include CalculatePercentChange

        included do
          class_attribute :queries
        end

        class_methods do
          def add_insights_graphs(from:, on:, as: nil)
            name = as.presence || on

            self.queries ||= []
            self.queries << from

            define_method name do
              send("#{name}_graph_data").values.sum
            end

            define_method "#{name}_percent_change" do
              first = previous_period[from.name].results.map { |r| r[on.to_s] }.sum
              second = send(name)

              calculate_percent_change(first, second)
            end

            define_method "#{name}_graph_data" do
              find_graph_data(current_period[from.name].results, on)
            end
          end
        end

        def starts_at
          current_period.values.first.starts_at
        end

        def ends_at
          current_period.values.first.ends_at
        end

        def previous_starts_at
          starts_at - (ends_at - starts_at).seconds - 1.day
        end

        def previous_ends_at
          (starts_at - 1.day).end_of_day
        end

        private

        def find_graph_data(results, field)
          result = results.reduce({}) do |memo, result|
            date = Date.new(
              result['_id']['year'],
              result['_id']['month'],
              result['_id']['day']
            )

            memo.merge(date => result[field.to_s].to_i)
          end


          result.merge!(starts_at.to_date => 0) if result.keys.exclude?(starts_at.to_date)
          result.merge!(ends_at.to_date => 0) if result.keys.exclude?(ends_at.to_date)
          result
        end

        def current_period
          @current_period ||= queries.reduce({}) do |memo, klass|
            memo.merge(
              klass.name => klass.new(
                starts_at: options[:starts_at].presence || 7.days.ago.to_date,
                ends_at: options[:ends_at].presence || 1.day.ago.to_date,
                group_by: 'day'
              )
            )
          end
        end

        def previous_period
          @previous_period ||= queries.reduce({}) do |memo, klass|
            memo.merge(
              klass.name => klass.new(
                starts_at: previous_starts_at,
                ends_at: previous_ends_at,
                group_by: 'day'
              )
            )
          end
        end
      end
    end
  end
end
