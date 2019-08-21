module Workarea
  class HelpSeeds
    def perform
      puts 'Adding help articles...'

      help = Core::Engine.root.join('data', 'help')
      categories = help.children.select(&:directory?)

      categories.each do |category_path|
        category = category_path.basename.to_s.titleize

        category_path.children.each do |article_path|
          next unless article_path.directory?

          new_article = Help::Article.new(
            name: article_path.basename.to_s.titleize,
            category: category
          )

          unless Help::Article.where(id: new_article.id).exists?
            assets = find_assets_for_article(article_path)

            new_article.thumbnail = find_thumbnail_for(article_path)
            new_article.summary = find_markdown_for(article_path, 'summary.md', assets)
            new_article.body = find_markdown_for(article_path, 'body.md', assets)
            new_article.save!
          end
        end
      end
    end

    def find_assets_for_article(article_path)
      assets_path = article_path.join('assets')
      return {} unless assets_path.directory?

      assets_path.children.reduce({}) do |memo, asset_path|
        asset_reference = asset_path.basename.to_s.split('.').first
        asset = Help::Asset.create!(file: asset_path)

        memo[asset_reference] = asset.url
        memo
      end
    end

    def find_markdown_for(article_path, file, assets)
      summary_path = article_path.join(file)
      return nil unless File.exist?(summary_path)
      render_markdown_with_assets(summary_path, assets)
    end

    def find_thumbnail_for(article_path)
      %w(png jpg jpeg gif).each do |format|
        thumbnail_path = article_path.join("thumbnail.#{format}")
        return thumbnail_path if File.exist?(thumbnail_path)
      end
      nil
    end

    def render_markdown_with_assets(raw_path, assets)
      template = IO.read(raw_path)
      context = OpenStruct.new(assets).instance_eval { binding }
      ERB.new(template).result(context)
    end
  end
end
