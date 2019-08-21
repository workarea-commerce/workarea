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

    if preview_path = app.config.action_mailer.preview_path
      Dir["#{preview_path}/**/*_preview.rb"].sort.each { |file| load file }
    end
  end
end
