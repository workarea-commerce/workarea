module Workarea
  module Storefront
    module SchemaOrgHelper
      def web_site_schema
        {
          '@context': 'http://schema.org',
          '@type': 'WebSite',
          'url': root_url,
          'potentialAction': {
            '@type': 'SearchAction',
            "target": "#{search_url}?q={search_term_string}",
            'query-input': 'required name=search_term_string'
          }
        }
      end

      def web_page_schema(type = 'WebPage')
        {
          '@context': 'http://schema.org',
          '@type': type
        }
      end

      def breadcrumb_list_schema(breadcrumbs)
        {
          "@context": "http://schema.org",
          "@type": "BreadcrumbList",
          "itemListElement": breadcrumbs.each_with_index.map do |(name, url), index|
            {
              "@type": "ListItem",
              "position": index + 1,
              "item": {
                "@id": url,
                "name": name
              }
            }
          end
        }
      end

      def product_schema(product, related_products: nil)
        schema = {
          "@context": "http://schema.org",
          "@type": "Product",
          "description": product.description,
          "name": product.name,
          "image": product_image_url(product.primary_image, :large_thumb),
          "url": product_url(product),
          "productID": product.id
        }

        if product.pricing.sell_min_price.present?
          schema['offers'] = {
            "@type": "Offer",
            "availability": "http://schema.org/InStock",
            "price": product.pricing.sell_min_price.to_s,
            "priceCurrency": product.pricing.sell_min_price.currency.to_s,
            "url": product_url(product)
          }
        end

        if related_products.present?
          schema['isRelatedTo'] = related_products.map do |related_product|
            product_schema(related_product)
          end
        end

        schema
      end

      def order_email_schema(order)
        {
          '@context': 'http://schema.org',
          '@type': 'Order',
          'merchant': {
            '@type': 'Organization',
            'name': Workarea.config.site_name
          },
          'orderNumber': order.id,
          'orderStatus': 'http://schema.org/OrderProcessing',
          'acceptedOffer': order.items.map do |item|
            {
              '@type': 'Offer',
              'itemOffered': {
                '@type': 'Product',
                'name': item.product.name,
                'sku': item.sku,
                'url': product_url(item.product, sku: item.sku),
                'image': path_to_url(product_image_url(item.product.primary_image, :small_thumb)),
              },
              'price': item.total_price.to_s,
              'priceCurrency': item.total_price.currency.to_s,
              'eligibleQuantity': {
                '@type': 'QuantitativeValue',
                'value': item.quantity
              }
            }
          end,
          'url': order_url(order),
          'potentialAction': {
            '@type': 'ViewAction',
            'url': order_url(order)
          }
        }
      end

      def fulfillment_email_schema(order, package)
        {
          '@context': 'http://schema.org',
          '@type': 'ParcelDelivery',
          'deliveryAddress': {
            '@type': 'PostalAddress',
            'name': 'Ship To',
            'streetAddress': [
              order.shipping_address.street,
              order.shipping_address.street_2
            ].join(' / '),
            'addressLocality': order.shipping_address.city,
            'addressRegion': order.shipping_address.region,
            'addressCountry': order.shipping_address.country,
            'postalCode': order.shipping_address.postal_code
          },
          'carrier': {
            '@type': 'Organization',
            'name': package.carrier
          },
          'itemShipped': order.items.map do |item|
            {
              '@type': 'Product',
              'name': item.product.name,
              'sku': item.sku,
              'url': product_url(item.product, sku: item.sku),
              'image': path_to_url(product_image_url(item.product.primary_image, :small_thumb)),
            }
          end,
          'partOfOrder': {
            '@type': 'Order',
            'orderNumber': order.id,
            'merchant': {
              '@type': 'Organization',
              'name': Workarea.config.site_name
            },
            'orderStatus': 'http://schema.org/OrderInTransit'
          },
          'expectedArrivalUntil': Workarea.config.order_expected_arrival.call(order, package),
          'trackingNumber': package.tracking_number,
          'trackingUrl': package.tracking_link,
          'potentialAction': {
            '@type': 'TrackAction',
            'target': package.tracking_link
          }
        }
      end
    end
  end
end
