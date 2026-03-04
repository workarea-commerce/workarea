# frozen_string_literal: true

module Workarea
  class Admin::StyleGuidesController < Admin::ApplicationController
    layout 'workarea/admin/empty'
    include StyleGuides
  end
end
