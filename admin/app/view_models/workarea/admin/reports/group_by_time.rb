module Workarea
  module Admin
    module Reports
      module GroupByTime
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new({ period: get_period_for(result['_id']) }.merge(result))
          end
        end

        def get_period_for(id)
          if id.key?('day_of_week')
            Date::DAYNAMES[id['day_of_week'] - 1]
          elsif id.key?('quarter')
            "#{id['year']} Q#{id['quarter']}"
          elsif id.key?('week')
            Date.strptime("#{id['year']}-#{id['week']}", '%G-%V').strftime('%Y-%-m-%-d')
          else
            id.values.join('-')
          end
        end

        def group_by_options
          model.group_bys.map { |o| [o.titleize, o] }
        end

        def uneven_day_distribution?
          number_of_days = (model.ends_at.to_date - model.starts_at.to_date).to_i
          (number_of_days % 7) != 0
        end

        def day_of_week?
          options[:group_by].to_s == 'day_of_week'
        end
      end
    end
  end
end
