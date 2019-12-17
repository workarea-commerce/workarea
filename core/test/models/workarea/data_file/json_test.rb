require 'test_helper'

module Workarea
  module DataFile
    class JsonTest < TestCase
      class Foo
        include ApplicationDocument
        field :name, type: String
        field :ignore, type: Integer

        embeds_many :bars, class_name: Foo.name
      end

      class Bar
        include ApplicationDocument

        field :name, type: String

        embedded_in :foo, class_name: Foo.name
      end

      def test_ignored_fields
        Workarea.config.data_file_ignored_fields = %w(ignore)

        model = Foo.create!(name: 'foo', ignore: 3)
        results = JSON.parse(Json.new.serialize(model))

        assert_equal(1, results.size)
        assert_equal(model.id.to_s, results.first['_id'])
        refute(results.first.key?('ignore'))
      end

      def test_assign_password_when_provided
        password = 'password1'
        model = User.new(email: 'test@example.com')
        json = [model.as_json.merge(password: password)].to_json
        data = create_import(
          model_type: User.name,
          file: create_tempfile(json, extension: 'json'),
          file_type: 'json'
        )

        assert_difference -> { User.count } do
          Json.new(data).import!
        end

        user = User.find_by_email('test@example.com')

        assert user.present?, 'user not imported'
        assert user.authenticate(password), 'password not imported'
      end

      def test_randomize_password_when_missing_and_new_record
        password = 'password1'
        model = User.new(email: 'test@example.com')
        json = [model.as_json].to_json
        data = create_import(
          model_type: User.name,
          file: create_tempfile(json, extension: 'json'),
          file_type: 'json'
        )

        assert_difference -> { User.count } do
          Json.new(data).import!
        end

        user = User.find_by_email('test@example.com')

        assert user.present?, 'user not imported'
        refute user.authenticate(password), "password authenticated when it shouldn't have"
      end

      def test_ignore_password_when_user_exists
        user = create_user(first_name: 'Foo')
        json = [user.as_json.merge(first_name: 'Bar')].to_json
        data = create_import(
          model_type: User.name,
          file: create_tempfile(json, extension: 'json'),
          file_type: 'json'
        )

        Json.new(data).import!

        assert_equal 'Bar', user.reload.first_name
      end

      def test_exclude_updated_at
        model = Foo.create!(name: '1', updated_at: 2.days.ago)
        json = [model.as_json.merge(name: '2')].to_json
        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(json, extension: 'json'),
          file_type: 'json'
        )

        assert_changes -> { model.reload.updated_at.to_date } do
          Json.new(import).import!
        end
      end

      def test_exclude_updated_at_when_embedded
        original_date = 2.days.ago
        parent = Foo.create!(updated_at: original_date)
        model = parent.bars.create!(name: '1', updated_at: original_date)
        json = [model.as_json.merge(name: '2')].to_json
        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(json, extension: 'json'),
          file_type: 'json'
        )

        assert_changes -> { model.reload.updated_at.to_date } do
          Json.new(import).import!
        end
      end
    end
  end
end
