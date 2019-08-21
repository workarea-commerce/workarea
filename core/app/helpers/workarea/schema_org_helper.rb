module Workarea
  module SchemaOrgHelper
    def render_schema_org(schema)
      tag.script(schema.to_json.html_safe, type: 'application/ld+json')
    end

    def email_action_schema(target, name, description = nil)
      {
        '@context': 'http://schema.org',
        '@type': 'EmailMessage',
        'potentialAction': {
          '@type': 'ViewAction',
          'target': target,
          'url': target,
          'name': name
        },
        'description': description || name
      }
    end
  end
end
