module Workarea
  # Find SVG assets for +InlineSvg+ in any asset path. Represents a
  # single asset file.
  class SvgAssetFinder < InlineSvg::StaticAssetFinder
    # Fully-qualified path to the asset. This is what's read out in
    # +InlineSvg+ to actually read the SVG file from disk. It attempts
    # to find a static asset through the Sprockets manifest, but falls
    # back to iterating through all gem folders for the correct path.
    #
    # @return [Pathname] Path to the asset on disk, or +nil+ if it
    # cannot be found.
    def pathname
      path = asset_pathname
      return path if path.present?
      return unless engine_root.present?

      engine_root.join(@filename)
    end

    private

    # Copied from https://github.com/jamesmartin/inline_svg/blob/v1.2.1/lib/inline_svg/static_asset_finder.rb#L15
    def asset_pathname
      if ::Rails.application.config.assets.compile
        ::Rails.application.assets[@filename].try(:pathname)
      else
        manifest = ::Rails.application.assets_manifest
        asset_path = manifest.assets[@filename]
        unless asset_path.nil?
          ::Rails.root.join(manifest.directory, asset_path)
        end
      end
    end

    def engine_root
      engine_paths.find { |path| path.join(@filename).exist? }
    end

    def engine_paths
      ::Rails.configuration.assets.paths.map { |path| Pathname.new(path) }
    end
  end
end
