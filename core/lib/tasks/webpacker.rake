
namespace :webpacker do
  namespace :install do
    desc 'Install Workarea JS into Webpacker, along with Stimulus and ERB support'
    task workarea: %i[stimulus erb] do
      install_template_path = File.expand_path("../../lib/webpacker/install/template.rb", __dir__).freeze

      exec "#{RbConfig.ruby} #{bin_path}/rails app:template LOCATION=#{install_template_path}"
    end
  end
end
