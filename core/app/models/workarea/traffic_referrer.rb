# frozen_string_literal: true
module Workarea
  class TrafficReferrer
    include ApplicationDocument

    field :known, type: Mongoid::Boolean, default: false
    field :source, type: String
    field :medium, type: String
    field :uri, type: String
    field :domain, type: String
    field :term, type: String
  end
end
