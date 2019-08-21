module Workarea
  module Search
    class TermFilter < Filter
      def query_clause
        return {} unless current_value.present?
        { term: { system_name => current_value} }
      end
    end
  end
end
