module Documentation
  class S3
    attr_reader :client, :bucket

    def initialize(config)
      @bucket = config.delete(:bucket)
      @client = Aws::S3::Client.new(config)
    end

    def upload!(version, source_dir)
      # Upload new documentation to _tmp
      each_file(source_dir) do |file_path|
        put(File.join('_tmp', file_path.sub("#{source_dir}/", '')), file_path)
      end

      # Delete existing documentation for this version
      list(version).contents.each { |obj| delete(obj.key) }

      # Copy new documentation into this version
      list('_tmp').contents.each do |obj|
        copy(obj.key, obj.key.sub('_tmp', version))
      end

      if update_root?(version)
        # Delete root files
        list.contents.each do |obj|
          next if obj.key.split('/').first =~ /^\d\.\d|_tmp$/
          delete(obj.key)
        end

        # Move _tmp documentation to root
        list('_tmp').contents.each do |obj|
          move(obj.key, obj.key.sub('_tmp/', ''))
        end
      else
        # Delete _tmp
        list('_tmp').contents.each { |obj| delete(obj.key) }
      end
    end

    def update_root?(version)
      current_segments = get('.version').strip.split('.').map(&:to_i)
      new_segments = version.split('.').map(&:to_i)

      current_segments.first < new_segments.first || (
        current_segments.first <= new_segments.first &&
        current_segments.at(1) <= new_segments.at(1)
      )
    rescue Aws::S3::Errors::NoSuchKey
      true
    end

    def each_file(directory, &block)
      Dir.foreach(directory) do |file|
        next if ['.', '..'].include?(file)

        path = [directory, file].join('/')

        if File.directory?(path)
          each_file(path, &block)
        else
          yield(path)
        end
      end
    end

    private

    def list(prefix = nil)
      client.list_objects(bucket: bucket, prefix: prefix)
    end

    def get(key)
      response = client.get_object(bucket: bucket, key: key)
      response.body.read
    end

    def put(key, file_path)
      File.open(file_path, 'rb') do |file|
        client.put_object(
          bucket: bucket,
          key: key,
          body: file,
          acl: 'public-read',
          content_type: content_type(key)
        )
      end
    end

    def copy(current_key, new_key)
      client.copy_object(
        copy_source: "/#{bucket}/#{current_key}",
        bucket: bucket,
        key: new_key,
        acl: 'public-read',
        content_type: content_type(new_key)
      )
    end

    def move(current_key, new_key)
      copy(current_key, new_key)
      delete(current_key)
    end

    def delete(key)
      client.delete_object(bucket: bucket, key: key)
    end

    def content_type(key)
      extension = File.extname(key).sub('.', '')
      Mime[extension].to_s unless extension.empty?
    end
  end
end
