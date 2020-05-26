require 'test_helper'

module Workarea
  class ProcessImportTest < TestCase
    include TestCase::Mail

    def test_perform
      user = create_user(email: 'test@workarea.com')
      import = create_import(
        model_type: Workarea::Catalog::Product,
        file: create_tempfile([create_product].to_json, extension: 'json'),
        created_by_id: user.id
      )

      ProcessImport.new.perform(import.id)
      import.reload

      assert_equal(1, Catalog::Product.count)
      assert(import.started_at.present?)
      assert(import.completed_at.present?)
      refute(import.file_errors.present?)

      email = ActionMailer::Base.deliveries.last
      assert_includes(email.to, user.email)
      assert_includes(email.subject, import.name.downcase)
    end

    def test_perform_when_import_fails
      user = create_user(email: 'test@workarea.com')
      sample = create_product
      sample.name = ''
      file = create_tempfile([sample].to_json, extension: 'json')

      import = create_import(
        model_type: Workarea::Catalog::Product,
        file: file,
        created_by_id: user.id
      )

      ProcessImport.new.perform(import.id)
      import.reload

      assert_equal(1, Catalog::Product.count)
      assert(import.started_at.present?)
      assert(import.completed_at.present?)
      assert(import.file_errors.present?)

      email = ActionMailer::Base.deliveries.last
      assert_includes(email.to, user.email)
      assert_includes(email.subject, import.name.downcase)
      assert_includes(
        email.parts.second.body,
        t('workarea.admin.data_file_mailer.import_failure.errors')
      )
    end

    def test_perform_with_missing_import
      assert_raises Mongoid::Errors::DocumentNotFound do
        ProcessImport.new.perform('foo')
      end
    end
  end
end
