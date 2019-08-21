module Workarea
  class GenerateContentMetadata
    include Sidekiq::Worker

    def perform(*args)
      Catalog::Category.all.each_by(100) do |category|
        Metadata.update(Content.for(category))
      end

      Content::Page.all.each_by(100) do |page|
        Metadata.update(Content.for(page))
      end

      Metadata::HomePage.new(Content.for('home_page')).update
    end
  end
end
