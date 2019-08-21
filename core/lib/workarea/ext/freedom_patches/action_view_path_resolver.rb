module ActionView
  class PathResolver
    def find_template_paths(query)
      prefilter(query).reject do |filename|
        File.directory?(filename) ||
          !File.fnmatch(query, filename, File::FNM_EXTGLOB)
      end
    end

    def prefilter(query)
      path = query.split('{')[0]
      # sort by + sign to make sure that variant matches get priority
      Dir[path + '*'].uniq.sort_by { |i| i =~ /\+/ ? 0 : 1 }
    end
  end
end
