namespace :webpacker do
  namespace :install do
    desc 'Install Workarea JS into Webpacker, along with Stimulus and ERB support'
    task workarea: %i[stimulus erb] do
      install_template_path = File.expand_path("../../lib/webpacker/install/template.rb", __dir__).freeze

      exec "#{RbConfig.ruby} #{bin_path}/rails app:template LOCATION=#{install_template_path}"
    end
  end
end

namespace :workarea do
  namespace :install do
    desc 'Install JS dependencies from all Workarea plugins.'
    task packages: :environment do
      dependencies = Workarea::Plugin.each_with_object('') do |plugin, deps|
        path = plugin.root.join(gem, 'package.json')

        next unless path.exist?

        text = path.read
        json = JSON.parse(text)

        json['dependencies'].each do |name, version|
          deps << "#{name}@#{version}"
        end
      end

      sh "yarn add #{dependencies}"
    end
  end
end
