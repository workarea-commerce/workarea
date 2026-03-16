# frozen_string_literal: true

module Workarea
  class MediaController < ActionController::Base
    include Workarea::I18n::DefaultUrlOptions

    # Prototype media endpoint.
    #
    # GET /media2/:uid/:filename?v=optim
    def show
      uid = CGI.unescape(params[:uid].to_s)
      filename = CGI.unescape(params[:filename].to_s)
      variant = params[:v].presence

      storage = Workarea::Media::Storage.build

      if variant == 'optim'
        # Optim files are stored alongside originals.
        uid = uid.to_s.sub(/\.[^.]+\z/, '') + '.optim.jpg'
        filename = filename.to_s.sub(/\.[^.]+\z/, '') + '.jpg'
      end

      io = storage.open(uid)
      data = io.respond_to?(:read) ? io.read : io.to_s

      # Extremely naive content type inference for prototype
      content_type = Rack::Mime.mime_type(File.extname(filename), 'application/octet-stream')

      response.headers['Cache-Control'] = 'public, max-age=31536000'
      send_data(data, type: content_type, disposition: 'inline', filename: filename)
    rescue Errno::ENOENT, Aws::S3::Errors::NoSuchKey
      head :not_found
    end
  end
end
