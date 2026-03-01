# Rails 7.1 deprecated `to_s(:format)` in favour of `to_fs(:format)`.
# This polyfill adds `to_fs` to Date, Time, DateTime, and Numeric for Rails < 7.1
# so the codebase works on both Rails 6 and Rails 7.1+.

[Date, Time, DateTime, Numeric].each do |klass|
  unless klass.method_defined?(:to_fs)
    klass.class_eval do
      alias_method :to_fs, :to_s
    end
  end
end
