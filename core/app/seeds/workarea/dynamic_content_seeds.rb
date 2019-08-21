module Workarea
  class DynamicContentSeeds
    CONTENT_CLASS_MAP = {
      'categories' => Catalog::Category,
      'products' => Catalog::Product,
      'pages' => Content::Page
    }

    def perform
      puts 'Adding dynamic content...'

      if File.directory?("#{Rails.root}/data/content")
        CONTENT_CLASS_MAP.each do |dir, klass|
          if File.directory?("#{Rails.root}/data/content/#{dir}")
            Dir["#{Rails.root}/data/content/#{dir}/*.json"].each do |file|
              slug, blocks = content_blocks_from_file(file)
              model = begin
                        klass.find_by(slug: slug)
                      rescue Mongoid::Errors::DocumentNotFound
                        klass.create!(name: slug.titleize)
                      end

              set_content(model, blocks)
            end
          end
        end

        Dir["#{Rails.root}/data/content/*.json"].each do |file|
          slug, blocks = content_blocks_from_file(file)
          set_content(slug.underscore, blocks)
        end
      end
    end

    def render_with_seed_images(file)
      template = IO.read(file)
      context = OpenStruct.new(seed_images).instance_eval { binding }
      ERB.new(template).result(context)
    end

    def content_blocks_from_file(path)
      slug = path.split('/').last.split('.').first.dasherize
      blocks = JSON.parse(render_with_seed_images(path))
      return slug, blocks
    end

    def set_content(contentable, blocks)
      content = Content.for(contentable)
      content.update_attributes!(blocks: blocks)
    end

    def seed_images
      @seed_images ||= Content::Asset.all.inject({}) do |hash, asset|
        hash.merge(strip_extension(asset.file_name) => asset.url)
      end
    end

    def strip_extension(file)
      File.basename(file, File.extname(file))
    end
  end
end
