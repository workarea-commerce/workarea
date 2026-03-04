# frozen_string_literal: true

module Workarea
  class Admin::ProductImagesViewModel < ApplicationViewModel
    def by_option
      @by_option ||= model.images.asc(:position).group_by do |image|
        image.option.to_s.titleize
      end
    end
  end
end
