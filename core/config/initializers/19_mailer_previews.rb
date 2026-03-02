app = Rails.application

app.config.to_prepare do
  if app.config.action_mailer.show_previews
    paths = %w(
      test/mailers/previews/**/*_preview*.rb
      lib/workarea/mailer_previews/**/*_preview*.rb
    )

    Workarea::Plugin.installed.each do |plugin|
      paths.each do |path|
        Dir.glob("#{plugin.root}/#{path}") { |file| load file }
      end
    end

    # Rails 7.1 renamed preview_path (string) to preview_paths (array).
    # Support both forms so the app boots on Rails 6.1 and Rails 7.x.
    preview_paths = if app.config.action_mailer.respond_to?(:preview_paths)
      Array(app.config.action_mailer.preview_paths)
    else
      Array(app.config.action_mailer.preview_path)
    end

    preview_paths.compact.each do |preview_path|
      Dir["#{preview_path}/**/*_preview.rb"].sort.each { |file| load file }
    end
  end
end
