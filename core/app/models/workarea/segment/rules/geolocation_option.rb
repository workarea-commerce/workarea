module Workarea
  class Segment
    module Rules
      class GeolocationOption
        class << self
          delegate :[], to: :all

          def all
            @all ||= Country.all.reduce({}) do |memo, country|
              memo[country.alpha2] = from_country(country)

              country.subdivisions.each do |id, subdivision|
                if subdivision.name.present?
                  location = from_subdivision(country, subdivision)
                  memo[location.id] = location
                end
              end

              memo
            end
          end

          def from_country(country)
            return if country.blank?
            new(id: country.alpha2, name: country.name, model: country)
          end

          def from_subdivision(country, subdivision)
            return if country.blank? || subdivision.blank?

            id = "#{country.alpha2}-#{country.subdivisions.invert[subdivision]}"
            name = "#{subdivision.name}, #{country.alpha2}"
            new(id: id, name: name, model: subdivision)
          end

          def search(query)
            return [] if query.blank?
            regex = /^#{::Regexp.quote(query.to_s)}/i
            all.values.select { |r| r.name =~ regex }
          end
        end

        attr_reader :id, :name, :model

        def initialize(options)
          @id = options[:id]
          @name = options[:name]
          @model = options[:model]
        end
      end
    end
  end
end
