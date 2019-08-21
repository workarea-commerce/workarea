module Workarea
  class SeedsGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def copy_seeds
      template 'seeds.rb.erb', "app/seeds/workarea/#{file_name}_seeds.rb"
    end

    def add_seeds_to_workarea_initializer
      inject_into_file 'config/initializers/workarea.rb', before: "\nend" do
        "\n\n\s\sconfig.seeds << 'Workarea::#{file_name.camelize}Seeds'"
      end
    end
  end
end
