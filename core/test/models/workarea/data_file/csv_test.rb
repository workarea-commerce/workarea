require 'test_helper'

module Workarea
  module DataFile
    class CsvTest < TestCase
      class Foo
        include ApplicationDocument
        field :name, type: String
        field :local, type: Boolean, localize: true
        field :hash_test, type: Hash
        field :payment, type: ActiveMerchant::Billing::Response
        field :validated_field, type: String

        embeds_many :bars
        embeds_many :bazzets
        embeds_one :baz

        cattr_accessor :validation_failure
        validate :validated_field_is_valid

        def validated_field_is_valid
          errors.add(:base, 'error!') if validation_failure
        end
      end

      class Bar
        include ApplicationDocument
        field :name, type: String
        field :array, type: Array
        field :ignore, type: Integer
        field :hash_test, type: Hash
        embedded_in :foo
      end

      class Baz
        include ApplicationDocument
        field :name, type: String
        field :hash_test, type: Hash
        embedded_in :foo
      end

      class Bazzet
        include ApplicationDocument
        extend Dragonfly::Model
        field :image_uid, type: String
        dragonfly_accessor :image, app: :workarea
        embedded_in :foo
      end

      class Qoo < Bar
        field :qoo, type: String
      end

      class Qux < Bar
        field :type, type: String
      end

      def test_merging_rows_for_embedded
        model = Foo.create!(
          bars: [{ name: '1' }, { name: '2' }],
          baz: { name: '3' }
        )

        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)

        assert_equal(2, results.size)
        results.each { |r| assert_equal(model.id.to_s, r['_id']) }
        assert_equal('1', results.first['bars_name'])
        assert_equal('2', results.second['bars_name'])
        assert_equal('3', results.first['baz_name'])
      end

      def test_handles_blank_embedded
        model = Foo.create!(name: '1')
        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)

        assert_equal(1, results.size)
        assert_equal(model.id.to_s, results.first['_id'])
        assert_equal('1', results.first['name'])
      end

      def test_handles_localized_fields
        set_locales(available: [:en, :es], default: :en, current: :es)

        model = Foo.create!(local_translations: { en: true, es: false })
        model.local = true

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        results = CSV.read(import.file.path, headers: :first_row).map(&:to_h)

        assert_equal(1, results.size)
        assert_equal(model.id.to_s, results.first['_id'])
        assert_equal('true', results.first['local'])

        csv = Csv.new(import).import!
        assert(model.reload.local)
      end

      def test_arrays
        model = Foo.create!(bars: [{ array: %w(1 2) }])
        model.bars.first.array = %w(3 4)

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        results = CSV.read(import.file.path, headers: :first_row).map(&:to_h)

        assert_equal(1, results.size)
        assert_equal(model.id.to_s, results.first['_id'])
        assert_equal('3,4', results.first['bars_array'])

        Csv.new(import).import!
        assert_equal(%w(3 4), model.reload.bars.first.array)
      end

      def test_hashes
        model = Foo.create!(baz: { hash_test: { 'foo' => %w(1 2) } })
        model.baz.hash_test = { 'foo' => %w(3 4), 'bar' => '5' }

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        results = CSV.read(import.file.path, headers: :first_row).map(&:to_h)

        assert_equal(1, results.size)
        assert_equal(model.id.to_s, results.first['_id'])
        assert_equal('3,4', results.first['baz_hash_test_foo'])
        assert_equal('5', results.first['baz_hash_test_bar'])

        Csv.new(import).import!
        assert_equal(%w(3 4), model.reload.baz.hash_test['foo'])
        assert_equal('5', model.reload.baz.hash_test['bar'])
      end

      def test_handles_variable_numbers_of_hashes
        one = Foo.create!(baz: { hash_test: { 'foo' => %w(1 2) } })
        two = Foo.create!(baz: { hash_test: { 'bar' => %w(3 4) } })

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize([one, two]), extension: 'csv'),
          file_type: 'csv'
        )

        results = CSV.read(import.file.path, headers: :first_row).map(&:to_h)

        assert_equal(2, results.size)
        assert_equal(one.id.to_s, results.first['_id'])
        assert_equal('1,2', results.first['baz_hash_test_foo'])
        assert(results.first['baz_hash_test_bar'].blank?)

        assert_equal(two.id.to_s, results.second['_id'])
        assert_equal('3,4', results.second['baz_hash_test_bar'])
        assert(results.second['baz_hash_test_foo'].blank?)

        Csv.new(import).import!
        assert_equal(%w(1 2), one.reload.baz.hash_test['foo'])
        assert_equal(%w(3 4), two.reload.baz.hash_test['bar'])
      end

      def test_complex_embedded_hashes
        model = Foo.create!(
          baz: { hash_test: { 'foo' => %w(1 2) } },
          bars: [
            { hash_test: { 'bar' => %w(1 2) } },
            { hash_test: { 'bar' => %w(3 4) } }
          ]
        )
        model.baz.hash_test = { 'foo' => %w(3 4), 'bar' => '5' }
        model.bars.first.hash_test = { 'foo' => %w(6 7) }
        model.bars.second.hash_test = { 'bar' => %w(8 9), 'baz' => %(10), 'Qoo' => 'qux' }

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        results = CSV.read(import.file.path, headers: :first_row).map(&:to_h)

        assert_equal(2, results.size)
        assert_equal(model.id.to_s, results.first['_id'])
        assert_equal('3,4', results.first['baz_hash_test_foo'])
        assert_equal('5', results.first['baz_hash_test_bar'])
        assert_equal('6,7', results.first['bars_hash_test_foo'])
        assert_nil(results.first['bars_hash_test_bar'])
        assert_nil(results.second['bars_hash_test_foo'])
        assert_equal('8,9', results.second['bars_hash_test_bar'])
        assert_equal('10', results.second['bars_hash_test_baz'])
        assert_equal('qux', results.second['bars_hash_test_Qoo'])

        Csv.new(import).import!
        model.reload

        assert_nil(model.hash_test)
        assert_equal(%w(3 4), model.baz.hash_test['foo'])
        assert_equal('5', model.baz.hash_test['bar'])
        assert_equal(2, model.bars.first.hash_test.size)
        assert_equal(%w(6 7), model.bars.first.hash_test['foo'])
        assert_equal(%w(1 2), model.bars.first.hash_test['bar'])
        assert_equal(3, model.bars.second.hash_test.size)
        assert_equal(%w(8 9), model.bars.second.hash_test['bar'])
        assert_equal('10', model.bars.second.hash_test['baz'])
        assert_equal('qux', model.bars.second.hash_test['Qoo'])
      end

      def test_ignored_fields
        Workarea.config.data_file_ignored_fields = %w(ignore)

        model = Foo.create!(
          bars: [{ name: '1', ignore: 1 }, { name: '2', ignore: 2 }]
        )

        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)

        assert_equal(2, results.size)
        results.each { |r| refute(r.key?('bars_ignore')) }
      end

      def test_active_merchant_responses
        model = Foo.create!(payment: ActiveMerchant::Billing::Response.new(true, 'foo'))

        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)

        assert_equal(1, results.size)
        assert_equal('true', results.first['payment_success'])
        assert_equal('foo', results.first['payment_message'])
        assert_nil(results.first['payment_options_cvv_result'])
      end

      def test_failed_new_record_rows_with_subsequent_rows
        Foo.validation_failure = true
        model = Foo.new(bars: [{ name: 'one' }, { name: 'two' }])

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        Csv.new(import).import!
        assert_equal(0, Foo.count)
        assert_equal(2, import.total)
        assert_equal(0, import.succeeded)
        assert(import.file_errors['2'].present?)
        refute(import.file_errors.key?('3'))

      ensure
        Foo.validation_failure = false
      end

      def test_blank_ids_on_embedded_documents
        model = Foo.new(
          bars: [{ id: '', name: '1' }, { id: '', name: '2' }],
          baz: { id: '', name: '3' }
        )

        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)
        assert(results.all? { |r| r['bars_id'].blank? && r['baz_id'].blank? })

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        Csv.new(import).import!
        assert_equal(1, Foo.count)

        model = Foo.first
        assert(model.bars.map(&:id).all?(&:present?))
        assert(model.baz.id.present?)
        assert_equal(2, model.bars.size)
      end

      def test_embedded_documents_get_timestamps
        model = Foo.new(
          bars: [{ name: '1' }, { name: '2' }],
          baz: { name: '3' }
        )

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        Csv.new(import).import!
        assert_equal(1, Foo.count)

        model.reload
        assert(model.bars.present?)
        assert(model.bars.map(&:created_at).all?(&:present?))
        assert(model.bars.map(&:updated_at).all?(&:present?))
        assert(model.baz.created_at.present?)
        assert(model.baz.updated_at.present?)
      end

      def test_blank_rows_are_ignored
        model = Foo.new
        Foo.fields.keys.each { |f| model.send("#{f}=", nil) }

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(Csv.new.serialize(model), extension: 'csv'),
          file_type: 'csv'
        )

        Csv.new(import).import!
        assert_equal(0, Foo.count)
      end

      def test_assign_dragonfly_attachment_attributes
        VCR.use_cassette :csv_image_upload do
          csv = "_id,bazzets_image_url\n,http://via.placeholder.com/350x150"
          import = create_import(
            model_type: Foo.name,
            file: create_tempfile(csv, extension: 'csv'),
            file_type: 'csv'
          )

          Csv.new(import).import!

          assert_equal(1, Foo.count)
          foo = Foo.first
          assert_equal(1, foo.bazzets.count)
          refute_nil(foo.bazzets.first.image_uid)
        end
      end

      def test_assign_password_when_provided
        csv = "_id,email,password\n,test@example.com,password1"
        import = create_import(
          model_type: User.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        assert_difference -> { User.count } do
          Csv.new(import).import!
          user = User.find_by_email('test@example.com')

          assert user.present?, 'user not imported'
          assert user.authenticate('password1'), 'password not imported'
        end
      end

      def test_randomize_password_when_missing_and_new_record
        csv = "_id,email,password\n,missing@example.com"
        import = create_import(
          model_type: User.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        assert_difference -> { User.count } do
          Csv.new(import).import!
          user = User.find_by_email('missing@example.com')

          assert user.present?, 'user not imported'
          refute user.authenticate('password1'),
            "password authenticated when it shouldn't have"
        end
      end

      def test_ignore_password_column_when_user_exists
        user = create_user(first_name: 'Foo')
        csv = "_id,email,password,first_name\n#{user.id},#{user.email},,Bar"
        import = create_import(
          model_type: User.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        Csv.new(import).import!

        assert_equal 'Bar', user.reload.first_name
      end

      def test_encoding_conversion
        Workarea.with_config do |config|
          config.csv_import_options[:encoding] = 'ISO-8859-1'
          csv = %(_id,name,slug,details_keywords\n653911,Bowl Light#{153.chr},Bowl_Light,"testing")

          import = create_import(
            model_type: Catalog::Product.name,
            file: create_tempfile(csv, extension: 'csv', encoding: 'ascii-8bit'),
            file_type: 'csv'
          )

          Csv.new(import).import!

          product = Catalog::Product.find_by(slug: 'bowl_light')
          assert_equal("Bowl Light\u0099", product.name)
        end
      end

      def test_bom_characters_in_unicode
        csv = %(\xEF\xBB\xBF_id,name,slug,details_keywords\n653911,Bowl Light,Bowl_Light,"testing")
        import = create_import(
          model_type: Catalog::Product.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        Csv.new(import).import!

        product = Catalog::Product.find_by(slug: 'bowl_light')

        assert_equal('653911', product.id)
      end

      def test_embedded_subclasses
        model = Foo.create!(bars: [{ name: '1' }, { _type: Qoo.name, qoo: '2' }])
        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)

        assert_equal(2, results.size)
        results.each { |r| assert_equal(model.id.to_s, r['_id']) }
        assert_equal('1', results.first['bars_name'])
        assert_equal(Qoo.name, results.second['bars__type'])
        assert_equal('2', results.second['bars_qoo'])

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        model.destroy
        Csv.new(import).import!

        model = Foo.first
        assert_equal(2, model.bars.size)
        assert_equal(Bar, model.bars.first.class)
        assert_equal('1', model.bars.first.name)
        assert_equal(Qoo, model.bars.second.class)
        assert_equal('2', model.bars.second.qoo)
      end

      def test_exclude_updated_at
        original_date = 2.days.ago
        model = Foo.create!(name: '1', updated_at: original_date)
        model.name = '2'
        csv = Csv.new.serialize(model)
        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        assert_changes -> { model.reload.updated_at.to_date } do
          Csv.new(import).import!
        end
      end

      def test_fields_called_type
        model = Foo.create!(bars: [{ _type: Qux.name, type: '1' }, { name: '2' }])

        csv = Csv.new.serialize(model)
        results = CSV.parse(csv, headers: :first_row).map(&:to_h)

        assert_equal(2, results.size)
        results.each { |r| assert_equal(model.id.to_s, r['_id']) }
        assert_equal('1', results.first['bars_type'])
        assert_equal(Qux.name, results.first['bars__type'])
        assert_nil(results.second['bars_type'])
        assert_equal('2', results.second['bars_name'])
        assert_equal(Bar.name, results.second['bars__type'])

        import = create_import(
          model_type: Foo.name,
          file: create_tempfile(csv, extension: 'csv'),
          file_type: 'csv'
        )

        csv = Csv.new(import).import!
        model.reload

        assert_equal(2, model.bars.size)
        assert_equal(Qux, model.bars.first.class)
        assert_equal('1', model.bars.first.type)
        assert_equal(Bar, model.bars.second.class)
        assert_equal('2', model.bars.second.name)
      end
    end
  end
end
