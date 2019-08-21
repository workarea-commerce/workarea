namespace :workarea do
  desc 'Drop and recreate help articles (Warning: all current help will be deleted!)'
  task reload_help: :environment do
    puts 'Deleting help articles...'
    Workarea::Help::Article.delete_all
    Workarea::Help::Asset.delete_all

    Workarea::HelpSeeds.new.perform
    Rake::Task['workarea:search_index:help'].invoke
  end

  desc 'Upgrade help (creates only new articles that do not exist in the database)'
  task upgrade_help: :environment do
    Workarea::HelpSeeds.new.perform
    Rake::Task['workarea:search_index:help'].invoke
  end

  task dump_help: :environment do
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
