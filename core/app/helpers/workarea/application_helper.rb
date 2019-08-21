module Workarea
  module ApplicationHelper
    def product_image_url(image, job)
      host = Rails.application.config.action_controller.asset_host
      source = image_url(product_image_path(image, job))
      return source if host.blank? || source =~ /^(http|\/\/)/

      # These shenanigans are here to work around a Rails problem where the
      # configured asset host isn't being used if it's a proc. We use a proc in
      # the multi_site plugin.
      #
      # The gist of it was copied from the Rails `compute_asset_host` helper.
      #

      host_value = if host.respond_to?(:call)
        request = respond_to?(:request) ? request : nil
        arity = host.respond_to?(:arity) ? host.arity : host.method(:call).arity
        args = [source]

        args << request if request && (arity > 1 || arity < 0)
        host.call(*args)
      elsif host.include?('%d')
        host % (Zlib.crc32(source) % 4)
      else
        host
      end

      host_value.present? ? File.join(host_value, source) : source
    end

    def product_image_path(image, job)
      if image.placeholder?
        mounted_core.product_image_placeholder_path(
          job,
          c: image.updated_at.to_i
        )
      elsif image.option.present?
        mounted_core.dynamic_product_image_path(
          slug: image.product.slug,
          option: image.option,
          image_id: image.id,
          job: job,
          c: image.updated_at.to_i
        )
      else
        mounted_core.dynamic_product_image_path(
          slug: image.product.slug,
          image_id: image.id,
          option: nil,
          job: job,
          c: image.updated_at.to_i
        )
      end
    end

    def datetime_picker_tag(name, value = nil, options = {})
      if value.present? && (value.is_a?(DateTime) || value.is_a?(Time))
        value = value.to_s(:iso8601)
      end

      text_field_tag(name, value, options)
    end

    private

    def mounted_core
      send(Workarea::Core::Engine.mount_point)
    end
  end
end
