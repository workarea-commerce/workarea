# frozen_string_literal: true
module Workarea
  class Storefront::StyleGuidesController < Storefront::ApplicationController
    layout 'workarea/storefront/empty'
    include StyleGuides
  end
end
