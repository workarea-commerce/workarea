namespace :workarea do
  namespace :cache do
    desc 'Prime images cache'
    task prime_images: :environment do
      include Rails.application.routes.url_helpers
      include Workarea::Storefront::ProductsHelper
      include Workarea::Core::Engine.routes.url_helpers

      built_in_jobs = [:thumb, :gif, :jpg, :png, :strip, :convert, :optimized]

      jobs = Dragonfly.app(:workarea).processor_methods.reject do |job|
        built_in_jobs.include?(job)
      end

      Workarea::Catalog::Product.all.each_by(50) do |product|
        product.images.each do |image|
          jobs.each do |job|
            url = URI.join(
              "https://#{Workarea.config.host}",
              dynamic_product_image_url(
                image.product.slug,
                image.option,
                image.id,
                job,
                only_path: true
              )
            ).to_s

            begin
              `curl #{url}`
              puts "Downloaded image #{url}"
            rescue StandardError => e
              puts e.inspect
            end
          end
        end
      end
    end
  end
end
