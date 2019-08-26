module Workarea
  class ProductsSeeds
    SAMPLE_IMAGES_BASE_URL = "https://github.com/workarea-commerce/workarea/raw/master/core/data/product_images"
    SAMPLE_IMAGES = (0..39).map { |i| "#{i}.jpg" }

    def perform
      puts 'Adding products...'

      Sidekiq::Callbacks.disable do
        Catalog::ProductPlaceholderImage.cached

        Catalog::Category.all.each do |category|
          10.times do
            sizes = Workarea.config.search_facet_size_sort
            colors = Array.new(3) { Faker::Commerce.color.titleize }
            on_sale = rand(10) > 9

            product = Catalog::Product.new(
              name: Faker::Commerce.product_name,
              template: 'option_selects',
              created_at: (0..3).to_a.sample.days.ago
            )

            3.times do
              sku = Faker::Code.isbn
              sku_price = Faker::Commerce.price.to_m
              sale_price = sku_price - rand(5).to_m

              product.variants.build(
                sku: sku,
                details: { 'Size' => sizes.sample, 'Color' => colors.sample }
              )

              Inventory::Sku.create!(
                id: sku,
                policy: 'standard',
                available: rand(25)
              )

              Pricing::Sku.create!(
                id: sku,
                msrp: sku_price + 10.to_m,
                tax_code: '001',
                on_sale: on_sale,
                prices: [
                  { regular: sku_price, sale: sale_price < 0 ? 1.to_m : sale_price }
                ]
              )

              Fulfillment::Sku.create!(id: sku)
            end

            sizes = product.variants.map { |v| v.details['Size'] }
            colors = product.variants.map { |v| v.details['Color'] }

            product.filters = { 'Size' => sizes.uniq, 'Color' => colors.uniq }
            product.description = Faker::Hipster.paragraph
            product.save!

            if (sample_image = find_random_image).present?
              product.images.create!(image: sample_image)
            end
          end
        end
      end
    end

    def find_random_image
      # Ensure each image gets used at least once
      @indexes ||= (0..sample_images.count - 1).to_a
      next_index = @indexes.shuffle!.pop

      file = sample_images[next_index || rand(sample_images.size)]
      File.new(file)
    end

    def sample_images
      @sample_images ||= begin
        download_sample_images_cache unless sample_images_cached?
        Dir[sample_images_cache.join('*')]
      end
    end

    def sample_images_cache
      Workarea::Core::Engine.root.join('data', 'product_images').tap(&:mkpath)
    end

    def sample_images_cached?
      Dir[sample_images_cache.join('*')].many?
    end

    def download_sample_images_cache
      SAMPLE_IMAGES.each do |file|
        headers = { 'Accept' => 'application/vnd.github.v3.raw' }
        headers['Authorization'] = "token #{ENV['GITHUB_TOKEN']}" if ENV['GITHUB_TOKEN'].present?

        File.open(sample_images_cache.join(file), 'wb') do |result|
          url = "#{SAMPLE_IMAGES_BASE_URL}/#{file}"

          puts "Downloading #{url}..."
          open(url, headers) { |tmp| result.write(tmp.read) }
        end
      end
    end
  end
end
