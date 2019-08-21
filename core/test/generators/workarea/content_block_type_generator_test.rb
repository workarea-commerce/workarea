require 'test_helper'
require 'generators/workarea/content_block_type/content_block_type_generator'

module Workarea
  class ContentBlockTypeGeneratorTest < GeneratorTest
    tests Workarea::ContentBlockTypeGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination

      FileUtils.mkdir_p "#{destination_root}/config/initializers"
      File.open "#{destination_root}/config/initializers/workarea.rb", 'w' do |file|
        file.write "Workarea.configure do |config|\n\nend"
      end

      run_generator %w(CodeSnippet)
    end

    def test_create_storefront_view
      assert_file 'app/views/workarea/storefront/content_blocks/_code_snippet.html.haml'
    end

    def test_create_stylesheet
      assert_file 'app/assets/stylesheets/workarea/storefront/components/_code_snippet_block.scss'
      assert_file 'config/initializers/workarea.rb' do |stylesheet|
        assert_match("workarea/storefront/components/_code_snippet", stylesheet)
      end
    end

    def test_create_block_icon
      assert_file 'app/assets/images/workarea/admin/content_block_types/code_snippet.svg'
    end

    def test_create_view_model
      assert_file 'app/view_models/workarea/storefront/content_blocks/code_snippet_view_model.rb' do |view_model|
        assert_match("class CodeSnippetViewModel", view_model)
      end
    end

    def test_update_configuration
      assert_file 'config/initializers/workarea_content_block_types.rb' do |config|
        assert_match("Workarea.define_content_block_types", config)
        assert_match("block_type 'Code Snippet'", config)
      end
    end
  end
end
