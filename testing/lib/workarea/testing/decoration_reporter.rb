module Workarea
  module DecorationReporter
    def format_rerun_snippet(result)
      location, line = result.source_location
      return super unless location.ends_with?(Rails::Decorators.extension.to_s)

      relative_path = location.split('/test/').last

      possible_original_tests = workarea_roots
        .map { |r| r.join('test', relative_path).to_s }
        .map { |p| p.gsub(/\.#{Rails::Decorators.extension}$/, '.rb') }

      original_test = possible_original_tests.detect { |f| File.exist?(f) }

      if original_test.blank?
        raise <<~MSG
          Problem:
            Can't find original test #{original_test} for decorator #{location}
          Summary:
            Test decorators need to have the same path as the original test.
          Resolution:
            Check that your test decoration has the right path and file name.
        MSG
      end

      "From decorator: #{location}:#{line}\n#{self.executable} #{original_test}"
    end

    def workarea_roots
      [Workarea::Core::Engine.root] +
        Workarea::Plugin.installed.map(&:root) +
        [Rails.root]
    end
  end
end

Rails::TestUnitReporter.prepend(Workarea::DecorationReporter)
