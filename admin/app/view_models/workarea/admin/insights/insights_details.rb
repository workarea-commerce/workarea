module Workarea
  module Admin
    module Insights
      module InsightsDetails
        extend ActiveSupport::Concern
        include CalculatePercentChange

        included do
          class_attribute :insights_scoping
        end

        class_methods do
          def insights_scope(callable)
            self.insights_scoping = callable
          end

          def add_summaries(*fields)
            fields.each do |field|
              define_method field do
                current_period.sum(&field)
              end

              define_method "previous_#{field}" do
                previous_period.sum(&field)
              end

              define_method "#{field}_percent_change" do
                calculate_percent_change(send("previous_#{field}"), send(field))
              end
            end
          end

          def add_graph_data(*fields)
            fields.each do |field|
              define_method "#{field}_graph_data" do
                Hash[current_period.map { |d| [d.reporting_on.to_date, d.send(field)] }]
              end
            end
          end

          def add_sparkline(*fields)
            fields.each do |field|
              define_method "#{field}_sparkline" do
                current_period
                  .last(Workarea.config.admin_sparkline_size)
                  .map { |d| d.send(field) }
              end
            end
          end
        end

        def starts_at
          default = Workarea.config.reports_default_starts_at.call
          @starts_at ||= Time.zone.parse(options[:starts_at].to_s) || default rescue default
        end

        def ends_at
          @ends_at ||= Time.zone.parse(options[:ends_at].to_s) || Time.current rescue Time.current
        end

        def previous_starts_at
          @previous_starts_at ||= starts_at - (ends_at - starts_at).seconds - 1.day
        end

        def previous_ends_at
          @previous_ends_at ||= (starts_at - 1.day).end_of_day
        end

        def current_period
          @current_period ||= instance_exec(&insights_scoping)
            .by_date_range(starts_at: starts_at, ends_at: ends_at)
            .to_a
        end

        def previous_period
          @previous_period ||= instance_exec(&insights_scoping)
            .by_date_range(starts_at: previous_starts_at, ends_at: previous_ends_at)
            .to_a
        end
      end
    end
  end
end
