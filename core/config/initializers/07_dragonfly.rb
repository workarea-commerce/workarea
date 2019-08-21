Dragonfly.app(:workarea).configure do
  plugin :imagemagick

  verify_urls true
  secret Rails.application.secrets.dragonfly_secret.presence ||
          Rails.application.secret_key_base

  url_format '/media/:job/:name'
  processor :optim, Workarea::ImageOptimProcessor
end

Dragonfly.logger = Rails.logger

processors = Dragonfly.app(:workarea).processors.names

Dragonfly.app(:workarea).configure do
  #
  # Admin
  #
  #
  unless processors.include?(:avatar)
    processor :avatar do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '80x80')
      content.process!(:optim)
    end
  end

  unless processors.include?(:small)
    processor :small do |content|
      unless content.mime_type =~ /svg/
        content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
        content.process!(:thumb, '55x')
        content.process!(:optim)
      end
    end
  end

  unless processors.include?(:medium)
    processor :medium do |content|
      unless content.mime_type =~ /svg/
        content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
        content.process!(:thumb, '240x')
        content.process!(:optim)
      end
    end
  end

  #
  # Storefront
  #
  #
  analyser :inverse_aspect_ratio do |content|
    attrs = content.analyse(:image_properties)
    attrs['height'].to_f / attrs['width']
  end

  unless processors.include?(:small_thumb)
    processor :small_thumb do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '60x')
      content.process!(:optim)
    end
  end

  unless processors.include?(:medium_thumb)
    processor :medium_thumb do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '120x')
      content.process!(:optim)
    end
  end

  unless processors.include?(:large_thumb)
    processor :large_thumb do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '220x')
      content.process!(:optim)
    end
  end

  unless processors.include?(:detail)
    processor :detail do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '400x')
      content.process!(:optim)
    end
  end

  unless processors.include?(:zoom)
    processor :zoom do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '670x')
      content.process!(:optim)
    end
  end

  unless processors.include?(:super_zoom)
    processor :super_zoom do |content|
      content.process!(:encode, :jpg, Workarea.config.jpg_encode_options)
      content.process!(:thumb, '1600x')
      content.process!(:optim)
    end
  end

  unless processors.include?(:favicon)
    processor :favicon do |content, size|
      content.process!(:thumb, "#{size}#")
    end
  end

  unless processors.include?(:favicon_ico)
    processor :favicon_ico do |content|
      content.process!(:convert, '-define icon:auto-resize', 'format' => 'ico')
    end
  end
end
