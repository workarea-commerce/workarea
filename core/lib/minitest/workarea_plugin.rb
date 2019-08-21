module Minitest
  def self.plugin_workarea_init(options)
    if ENV['CI'].to_s =~ /true/
      path = ENV['JUNIT_PATH'] || 'test/reports'
      FileUtils.mkdir_p(path)

      options[:junit] = true
      options[:junit_filename] = "#{path}/report.xml"
    end
  end
end
