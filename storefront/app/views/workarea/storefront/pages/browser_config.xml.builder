xml.instruct!
xml.browserconfig do
  xml.msapplication do
    xml.tile do
      xml.square150x150logo(src: favicons_path('150x150'))
      xml.TileColor(Workarea.config.web_manifest.tile_color)
    end
  end
end
