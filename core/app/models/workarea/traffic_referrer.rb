module Workarea
  class TrafficReferrer
    include ApplicationDocument

    field :source, type: String
    field :medium, type: String
    field :uri, type: String
  end
end
