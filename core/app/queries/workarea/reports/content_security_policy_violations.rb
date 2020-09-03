module Workarea
  module Reports
    class ContentSecurityPolicyViolations
      include Report

      self.reporting_class = Workarea::Content::SecurityViolation
      self.sort_fields = %w(blocked_uri document_uri original_policy violated_directive updated_at)

      def aggregation
        [filter_recent, project_used_fields]
      end

      def filter_recent
        {
          '$match' => {
            'updated_at' => { '$gt' => Time.current - 1.week }
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'blocked_uri' => 1,
            'document_uri' => 1,
            'original_policy' => 1,
            'violated_directive' => 1,
            'updated_at' => 1
          }
        }
      end
    end
  end
end
