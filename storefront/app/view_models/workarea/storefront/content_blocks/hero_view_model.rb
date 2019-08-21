module Workarea
  module Storefront
    module ContentBlocks
      class HeroViewModel < ContentBlockViewModel
        def image
          find_asset(data[:asset])
        end

        def button_style_class
          classes = ['button']
          classes << 'button--large' if data[:style] == 'Large'
          classes << 'button--small' if data[:style] == 'Small'

          classes.join(' ')
        end

        def button_position_class
          "hero-content-block__button--#{data[:position].optionize.dasherize}"
        end
      end
    end
  end
end
