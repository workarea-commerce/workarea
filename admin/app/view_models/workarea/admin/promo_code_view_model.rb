# frozen_string_literal: true
module Workarea
  class Admin::PromoCodeViewModel < ApplicationViewModel
    def list_name
      code_list.name
    end
  end
end
