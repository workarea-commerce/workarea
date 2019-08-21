Rails.application.config.assets.precompile += %w(
  workarea/core/placeholder.png
  workarea/admin/favicon.ico
  workarea/storefront/*.png
  workarea/storefront/head.js
  workarea/storefront/email/banner.png
  workarea/storefront/style_guide_light_banner.png
  workarea/storefront/style_guide_product.jpg
  workarea/**/*.svg
  workarea/**/email.css
  workarea/admin/email_logo.png
)

InlineSvg.configure do |config|
  if config.asset_finder.blank? || config.asset_finder == InlineSvg::AssetFinder
    config.asset_finder = Workarea::SvgAssetFinder
  end
end
