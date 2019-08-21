module Workarea
  module Search
    module ReleaseDisplayRules
      def active_for_release_clause
        if Release.current.blank?
          { term: { 'active.now' => true } }
        else
          {
            bool: {
              should: [
                { term: { "active.#{Release.current.id}" => true } },
                {
                  bool: {
                    must: [
                      { term: { 'active.now' => true } },
                      {
                        bool: {
                          must_not: {
                            exists: { field: "active.#{Release.current.id}" }
                          }
                        }
                      }
                    ]
                  }
                }
              ]
            }
          }
        end
      end

      def include_current_release_clause
        if Release.current.blank?
          {
            bool: {
              minimum_should_match: 1,
              should: [
                { term: { release_id: 'live' } },
                { bool: { must_not: { exists: { field: 'release_id' } } } } # for upgrade compatiblity
              ]
            }
          }
        else
          {
            bool: {
              minimum_should_match: 1,
              should: [
                { term: { release_id: Release.current.id } },
                {
                  bool: {
                    must_not: [{ term: { changeset_release_ids: Release.current.id } }],
                    must: [
                      {
                        bool: {
                          minimum_should_match: 1,
                          should: [
                            { term: { release_id: 'live' } },
                            { bool: { must_not: { exists: { field: 'release_id' } } } } # for upgrade compatiblity
                          ]
                        }
                      }
                    ]
                  }
                }
              ]
            }
          }
        end
      end
    end
  end
end
