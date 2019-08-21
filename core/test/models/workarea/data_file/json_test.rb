require 'test_helper'

module Workarea
  module DataFile
    class JsonTest < TestCase
      class Foo
        include ApplicationDocument
        field :name, type: String
        field :ignore, type: Integer
      end

      def test_ignored_fields
        Workarea.with_config do |config|
          config.data_file_ignored_fields = %w(ignore)

          model = Foo.create!(name: 'foo', ignore: 3)
          results = JSON.parse(Json.new.serialize(model))

          assert_equal(1, results.size)
          assert_equal(model.id.to_s, results.first['_id'])
          refute(results.first.key?('ignore'))
        end
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
    end
  end
end
