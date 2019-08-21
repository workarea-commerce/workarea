module Workarea
  module NavigableTest
    def test_validations
      instance = navigable_class.new(name: 'test model')
      instance.valid?
      assert_equal('test-model', instance.slug)
    end

    def test_slug_generation
      instance = navigable_class.new(name: 'Test Slug')
      instance.valid?
      instance.save(validate: false)
      assert_equal('test-slug', instance.slug)

      instance = navigable_class.new(name: 'Test Slug')
      instance.valid?
      instance.save(validate: false)
      assert_equal('test-slug-1', instance.slug)

      instance = navigable_class.new(name: 'Test Slug')
      instance.valid?
      instance.save(validate: false)
      assert_equal('test-slug-2', instance.slug)
    end

    def test_slug_caching
      model = navigable_class.new(name: 'Test Slug', slug: 'same-slug')
      model.valid?
      model.save(validate: false)

      taxon = create_taxon(navigable: model)

      model = navigable_class.find(model.id)
      model.slug = 'different-slug'
      model.save(validate: false)

      taxon.reload
      assert_equal('different-slug', taxon.navigable_slug)
    end

    def test_save
      model = navigable_class.new(slug: 'test-slug')
      model.save
      assert(model.slug.nil?)
    end

    def test_destroy
      model = navigable_class.new(name: 'Test Slug', slug: 'same-slug')
      model.valid?
      model.save(validate: false)

      create_taxon(navigable: model)

      model.destroy
      assert_equal(1, Workarea::Navigation::Taxon.count)
    end

    def test_slug=
      instance = navigable_class.new(slug: 'test slug')
      assert_equal('test-slug', instance.slug)
    end

    def test_to_param
      instance = navigable_class.new(slug: 'test-param')
      assert_equal('test-param', instance.to_param)
    end
  end
end
