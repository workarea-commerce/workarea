# frozen_string_literal: true

require 'cgi'
require 'fastimage'

module Workarea
  module Media
    class Attachment
      attr_reader :model, :name

      def self.assign(model, name, value)
        new(model, name).assign(value)
      end

      def initialize(model, name)
        @model = model
        @name = name.to_sym
        @storage = Workarea::Media::Storage.build
      end

      # Dragonfly-like API surface
      def url(variant: nil, args: [])
        uid = model.public_send("#{name}_uid")
        filename = model.public_send("#{name}_name")
        return if uid.blank? || filename.blank?

        params = {}
        params[:v] = variant.to_s if variant.present?
        params[:a] = args.join(',') if args.present?

        query = params.any? ? "?#{params.to_query}" : ''
        "/media2/#{CGI.escape(uid)}/#{CGI.escape(filename)}#{query}"
      end

      def present?
        model.public_send("#{name}_uid").present?
      end

      def optim
        Workarea::Media::Variant.new(self, :optim)
      end

      def process(processor_name, *args)
        Workarea::Media::Variant.new(self, processor_name, *args)
      end

      def assign(value)
        io, original_filename = normalize_to_io(value)

        uid = @storage.generate_uid(original_filename)
        @storage.put(uid, io)

        model.public_send("#{name}_uid=", uid)
        model.public_send("#{name}_name=", original_filename)

        populate_image_metadata(io)

        uid
      ensure
        io.close if io.respond_to?(:close) && !(value.is_a?(String) || value.is_a?(Pathname))
      end

      def open_original
        @storage.open(model.public_send("#{name}_uid"))
      end

      def ensure_variant!(processor_name, *_args)
        return unless processor_name.to_sym == :optim

        # Optim variant is stored as a sibling key: <uid>.optim.jpg
        uid = model.public_send("#{name}_uid")
        return if uid.blank?

        variant_uid = optim_uid
        return if @storage.exist?(variant_uid)

        original = open_original
        tmp = Tempfile.new(['workarea-optim', '.jpg'])
        tmp.binmode

        OptimProcessor.new.call(original, tmp)
        tmp.rewind
        @storage.put(variant_uid, tmp)
      ensure
        tmp.close! if tmp
      end

      def optim_uid
        uid = model.public_send("#{name}_uid")
        base = uid.to_s.sub(/\.[^.]+\z/, '')
        "#{base}.optim.jpg"
      end

      class OptimProcessor
        def call(input_io, output_io)
          data = input_io.read

          # If input is already jpeg, preserve; otherwise convert using vips if available.
          converted = maybe_convert_to_jpeg(data)

          # Run through image_optim if available.
          optimized = maybe_image_optim(converted)

          output_io.write(optimized)
        end

        private

        def maybe_convert_to_jpeg(data)
          type = FastImage.type(StringIO.new(data)) rescue nil
          return data if type == :jpeg

          begin
            require 'vips'
            image = Vips::Image.new_from_buffer(data, '')
            image.jpegsave_buffer(interlace: true, strip: true, Q: 85)
          rescue LoadError, Vips::Error
            data
          end
        end

        def maybe_image_optim(data)
          require 'image_optim'
          ImageOptim.new.optimize_image_data(data) || data
        rescue LoadError
          data
        end
      end

      private

      def normalize_to_io(value)
        if value.respond_to?(:path) && value.respond_to?(:original_filename)
          [File.open(value.path, 'rb'), value.original_filename]
        elsif value.respond_to?(:path)
          [File.open(value.path, 'rb'), File.basename(value.path.to_s)]
        elsif value.is_a?(String) || value.is_a?(Pathname)
          [File.open(value.to_s, 'rb'), File.basename(value.to_s)]
        elsif value.respond_to?(:read)
          [value, "upload"]
        else
          raise ArgumentError, "Unsupported attachment assignment: #{value.class}"
        end
      end

      def populate_image_metadata(io)
        return unless model.respond_to?("#{name}_width=")

        io.rewind if io.respond_to?(:rewind)
        bytes = io.read
        io.rewind if io.respond_to?(:rewind)

        type = FastImage.type(StringIO.new(bytes)) rescue nil

        if type.present?
          size = FastImage.size(StringIO.new(bytes)) rescue nil
          if size
            model.public_send("#{name}_width=", size[0])
            model.public_send("#{name}_height=", size[1])
            model.public_send("#{name}_aspect_ratio=", (size[0].to_f / size[1].to_f)) if model.respond_to?("#{name}_aspect_ratio=")
            model.public_send("#{name}_portrait=", size[1] > size[0]) if model.respond_to?("#{name}_portrait=")
            model.public_send("#{name}_landscape=", size[0] > size[1]) if model.respond_to?("#{name}_landscape=")
          end

          model.public_send("#{name}_format=", type.to_s) if model.respond_to?("#{name}_format=")
          model.public_send("#{name}_image=", true) if model.respond_to?("#{name}_image=")
        else
          model.public_send("#{name}_image=", false) if model.respond_to?("#{name}_image=")
        end
      end
    end
  end
end
