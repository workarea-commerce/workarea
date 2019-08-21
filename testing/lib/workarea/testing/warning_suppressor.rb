module Capybara::Poltergeist
  class Client
    private

    # This is an extension of the 'abomination' written by
    # the authors of poltergeist. They say its for JRuby, but
    # the suppressor does not work without redirecting stderr
    # in addition to stdout.
    #
    def redirect_stdout
      prev = STDOUT.dup
      prev.autoclose = false
      $stdout = @write_io
      STDOUT.reopen(@write_io)

      prev = STDERR.dup
      prev.autoclose = false
      $stderr = @write_io
      STDERR.reopen(@write_io)
      yield
    ensure
      STDOUT.reopen(prev)
      $stdout = STDOUT
      STDERR.reopen(prev)
      $stderr = STDERR
    end
  end
end

module Workarea

  # Basic Logger class that filters out warnings that match a list of
  # specified messages from phantomjs
  #
  class WarningSuppressor
    IGNORES = [
      /QFont::setPixelSize: Pixel size <= 0/,
      /CoreText performance note:/,
      /Heya! This page is using wysihtml/
    ]

    class << self
      def write(message)
        if suppress?(message)
          0
        else
          puts(message)
          1
        end
      end

      private

      def suppress?(message)
        IGNORES.any? { |re| message =~ re }
      end
    end
  end
end
