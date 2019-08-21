module Workarea
  class AssetsSeeds
    def perform
      puts 'Adding assets...'

      load_assets("#{Core::Engine.root}/data/content_assets")
      load_assets("#{Rails.root}/data/content_assets")
    end

    def load_assets(path)
      if File.directory?(path)
        Dir.glob("#{path}/*.{jpeg,jpg,png,gif}").each do |path|
          filename = path.split('/').last.split('.').first

          Content::Asset.create!(
            name: filename.titleize,
            file: File.new(path),
            alt_text: filename.titleize
          )
        end
      end
    end
  end
end
