module Workarea
  module Tasks
    module Help
      extend self

      def reload
        Workarea::Help::Article.delete_all
        Workarea::Help::Asset.delete_all
        Workarea::HelpSeeds.new.perform
      end

      def dump
        Workarea::Help::Article.all.each_by(50) do |article|
          article_root = Rails.root.join(
            'data',
            'help',
            article.category.systemize,
            article.name.systemize
          )

          asset_path = article_root.join('assets')

          FileUtils.mkdir_p(article_root)

          if article.thumbnail.present?
            article.thumbnail.to_file(article_root.join(article.thumbnail.name))
          end

          Workarea::Help::Asset.all.each_by(50) do |asset|
            if article.summary.include?(asset.url) || article.body.include?(asset.url)
              FileUtils.mkdir_p(asset_path)
              asset.to_file(asset_path.join(asset.name))
              reference = "<%= #{asset.name.split('.').first} %>"

              article.summary.gsub!(asset.url, reference)
              article.body.gsub!(asset.url, reference)
            end
          end

          if article.summary.present?
            File.open(article_root.join('summary.md'), 'w') do |file|
              file.write(article.summary)
            end
          end

          if article.body.present?
            File.open(article_root.join('body.md'), 'w') do |file|
              file.write(article.body)
            end
          end
        end
      end
    end
  end
end
