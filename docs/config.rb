require_relative './workarea_renderer'

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, tables: true, no_intra_emphasis: true, renderer: WorkareaRenderer

set :relative_links, true

activate :search do |search|
  search.resources = Dir['source/**/*.html*'].map do |path|
    path.split('/').drop(1).join('/').gsub(/\.erb|\.md/, '')
  end

  search.fields = {
    title: { boost: 100, store: true, required: true },
    content: { boost: 50 },
    excerpt: { index: false, store: true },
    url:     { index: false, store: true }
  }
end

activate :navtree do |options|
  options.automatic_tree_updates = false
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
page '/articles/*', layout: 'article'
page '/release-notes/*', layout: 'bare'
page '/upgrade-guides/*', layout: 'bare'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  def body_classes(classes = '')
    ['body', current_page.data.body_class, classes].join(' ')
  end

  def recent_articles(size = 5)
    sitemap.resources
      .select { |resource| resource.path.start_with?('articles', 'hosting') }
      .select { |resource| resource.data.created_at.present? }
      .sort_by { |resource| Date.parse(resource.data.created_at) }
      .reverse
      .take(size)
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :relative_assets

  # Keep this here, as per:
  # https://github.com/middleman/middleman-autoprefixer/issues/33
  activate :autoprefixer do |prefix|
    prefix.browsers = "last 2 versions"
  end
end
