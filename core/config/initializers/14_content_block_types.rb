Workarea.define_content_block_types do
  #
  # Columnar Blocks
  #
  #

  block_type 'Hero' do
    description 'Positionable button over a background image.'

    fieldset 'Image' do
      field 'Asset', :asset, required: true, file_types: 'image', default: find_asset_id_by_file_name('960x470_light.png'), alt_field: 'Alt Text'
      field 'Alt Text', :string, default: ''
    end

    fieldset 'Button' do
      field 'Text', :string, default: 'Button'
      field 'URL', :url, default: '#'
      field 'Style', :options, values: [
        'Regular',
        'Large',
        'Small'
      ], default: 'Regular'
      field 'Position', :options, values: [
        'Top, Left',
        'Top, Center',
        'Top, Right',
        'Middle, Left',
        'Middle, Center',
        'Middle, Right',
        'Bottom, Left',
        'Bottom, Center',
        'Bottom, Right'
      ], default: 'Middle, Center'
    end
  end

  block_type 'Image' do
    tags %w(image)
    description 'An image with an optional link.'

    field 'Image', :asset, required: true, file_types: 'image', default: find_asset_id_by_file_name('960x470_light.png'), alt_field: 'Alt'
    field 'Alt', :string, default: ''
    field 'Link', :url, default: '/'
    field 'Align', :options, values: %w(Left Center Right), default: 'Center'
  end

  block_type 'Text' do
    tags %w(text)
    description 'A rich-text editor.'
    field 'Text', :text, default: "<h2>Text</h2><p>#{Workarea.config.placeholder_text}</p>"
  end

  block_type 'Video' do
    tags %w(video)
    description 'An embedded video. Requires embed code from a third-party, like YouTube or Vimeo.'
    field 'Embed', :string, multi_line: true, default: '<iframe width="560" height="315" src="https://www.youtube.com/embed/A21I70ggSQw" frameborder="0" allowfullscreen></iframe>' # TODO rename
  end

  block_type 'Button' do
    tags %w(button)
    description 'Preformatted button to match site styling.'

    field 'Text', :string, default: 'Buy Something!'
    field 'Link', :url, default: '/', required: true
    field 'Align', :options, values: %w(Left Center Right), default: 'Center'
    field 'Size', :options, values: %w(Regular Large Small), default: 'Regular'
  end

  block_type 'Taxonomy' do
    tags %w(taxonomy)
    description 'Insert a branch of the site Taxonomy.'

    fieldset 'Taxonomy' do
      field 'Header', :string
      field 'Show Starting Taxon', :boolean, default: true
      field 'Start', :taxonomy, required: true, default: -> { Workarea::Navigation::Taxon.first.try(:id).try(:to_s) }
    end

    fieldset 'Image' do
      field 'Image', :asset, file_types: 'image', default: find_asset_id_by_file_name('100x100.png'), alt_field: 'Image Alt'
      field 'Image Alt', :string, default: ''
      field 'Image Link', :url, default: '/'
      field 'Image Position', :options, values: %w(Right Left), default: 'Left'
    end
  end

  block_type 'Two Column Taxonomy' do
    tags %w(taxonomy)
    description 'Insert 2 branches of the site Taxonomy with optional image.'
    view_model 'Workarea::Storefront::ContentBlocks::TaxonomyViewModel'

    series 2 do
      field 'Header', :string
      field 'Show Starting Taxon', :boolean, default: true
      field 'Start', :taxonomy, required: true, default: -> { Workarea::Navigation::Taxon.first.try(:id).try(:to_s) }
    end

    fieldset 'Image' do
      field 'Image', :asset, file_types: 'image', default: find_asset_id_by_file_name('100x100.png'), alt_field: 'Image Alt'
      field 'Image Alt', :string, default: ''
      field 'Image Link', :url, default: '/'
      field 'Image Position', :options, values: %w(Right Left), default: 'Left'
    end
  end

  block_type 'Three Column Taxonomy' do
    tags %w(taxonomy)
    description 'Insert 3 branches of the site Taxonomy with optional image.'
    view_model 'Workarea::Storefront::ContentBlocks::TaxonomyViewModel'

    series 3 do
      field 'Header', :string
      field 'Show Starting Taxon', :boolean, default: true
      field 'Start', :taxonomy, required: true, default: -> { Workarea::Navigation::Taxon.first.try(:id).try(:to_s) }
    end

    fieldset 'Image' do
      field 'Image', :asset, file_types: 'image', default: find_asset_id_by_file_name('100x100.png'), alt_field: 'Image Alt'
      field 'Image Alt', :string, default: ''
      field 'Image Link', :url, default: '/'
      field 'Image Position', :options, values: %w(Right Left), default: 'Left'
    end
  end

  block_type 'Quote' do
    tags %w(quote)
    description 'A block of text styled like a quote.'

    field 'Quote', :text, required: true, default: -> { Workarea.config.placeholder_text }
    field 'Author', :string, default: ''
  end

  #
  # Self-layout Blocks
  #
  #

  block_type 'Image Group' do
    tags %w(image)
    description 'A group of images.'

    series 6 do
      field 'Image', :asset, default: find_asset_id_by_file_name('960x470_dark.png'), alt_field: 'Alt'
      field 'Alt', :string, default: ''
      field 'Link', :url, default: '/'
    end
  end

  block_type 'Image and Text' do
    tags %w(image text)
    description 'Image and formatted text including headings, lists, bold, and italic.'

    fieldset 'Image' do
      field 'Image', :asset, required: true, file_types: 'image', default: find_asset_id_by_file_name('100x100.png'), alt_field: 'Image Alt'
      field 'Image Alt', :string, default: ''
      field 'Image Link', :url, default: '/'
      field 'Image Position', :options, values: %w(Right Left), default: 'Left'
    end

    fieldset 'Text' do
      field 'Text', :text, default: "<h2>Text</h2><p>#{Workarea.config.placeholder_text}</p>"
      field 'Text Alignment', :options, values: %w(Left Right Center Justify), default: 'Left'
    end
  end

  block_type 'Video and Text' do
    tags %w(video text)
    description 'Embedded video and formatted text including headings, lists, bold, and italic.'
    view_model 'Workarea::Storefront::ContentBlocks::VideoViewModel'

    fieldset 'Video' do
      field 'Embed', :string, multi_line: true, default: '<iframe width="560" height="315" src="https://www.youtube.com/embed/5d7aruKYkKs" frameborder="0" allowfullscreen></iframe>' # TODO rename
      field 'Video Position', :options, values: %w(Right Left), default: 'Left'
    end

    fieldset 'Text' do
      field 'Text', :text, default: "<h2>Text</h2><p>#{Workarea.config.placeholder_text}</p>"
      field 'Text Alignment', :options, values: %w(Left Right Center Justify), default: 'Left'
    end
  end

  block_type 'Category Summary' do
    description 'A category name and its first few products.'
    field 'Category', :category, default: -> { Workarea::Catalog::Category.sample.try(:id).try(:to_s) }
  end

  block_type 'Recommendations' do
    description 'Personalized recommendations for the current user.'
  end

  block_type 'Product List' do
    description 'A custom list of products.'

    field 'Title', :string, default: 'Featured'
    field 'Products', :products, default: (lambda do
       result = Array.new(3) { Workarea::Catalog::Product.sample.try(:id) }
       result.compact
    end)
  end

  block_type 'Product Insights' do
    description 'A list of products from the current insights.'

    field 'Title', :string, default: 'Top Products'
    field 'Type', :options, values: [
        'Cold Products',
        'Hot Products',
        'Most Discounted Products',
        'Non Sellers',
        'Products To Improve',
        'Promising Products',
        'Star Products',
        'Top Products',
        'Trending Products'
      ], default: 'Top Products'
  end

  block_type 'HTML' do
    description 'Raw HTML. Output exactly as input.'
    field 'HTML', :string, multi_line: true, default: '<h3 style="font-size: 40px;">Raw HTML Content</h3>'
  end

  block_type 'Divider' do
    description 'A horizontal divider, used to break up vertical space.'

    field 'Height', :options, values: %w(small medium large), default: 'medium'
    field 'Show line', :boolean, default: true
    field 'Thickness', :options, values: %w(1 2 3 4), default: '2'
    field 'Style', :options, values: %w(solid dotted dashed double), default: 'solid'
  end

  block_type 'Social Networks' do
    description 'Linked icons for social media pages.'

    field 'Facebook', :url, default: 'https://facebook.com/'
    field 'Twitter', :url, default: 'https://twitter.com/'
    field 'Google Plus', :url, default: 'https://plus.google.com/'
    field 'Pinterest', :url, default: 'https://pinterest.com/'
  end
end
