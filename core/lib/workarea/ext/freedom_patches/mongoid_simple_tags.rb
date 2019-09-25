module Mongoid
  module Document
    # This was originally part of mongoid-simple-tags, but that gem is
    # no longer maintained so we've opted to vendor in the functionality
    # here.
    module Taggable
      def self.included(base)
        base.class_eval do |klass|
          klass.field :tags, type: Array, default: []
          klass.index({ tags: 1 }, { background: true })

          include InstanceMethods
          extend ClassMethods
        end
      end

      module InstanceMethods
        def tag_list=(tags)
          self.tags = tags.to_s.split(",").collect { |t| t.strip }.delete_if { |t| t.blank? }
        end

        def tag_list
          self.tags.join(", ") if tags
        end

        def tags
          super || []
        end

        def tags=(tags)
          super(tags&.uniq)
        end
      end


      module ClassMethods
        def scoped_tags(scope = {})
          warn "[DEPRECATION] `scoped_tags` is deprecated.  Please use `all_tags` instead."
          all_tags(scope)
        end

        def tagged_with(tags)
          tags = [tags] unless tags.is_a? Array
          criteria.in(tags: tags)
        end

        def tagged_without(tags)
          tags = [tags] unless tags.is_a? Array
          criteria.nin(tags: tags)
        end

        def tagged_with_all(tags)
          tags = [tags] unless tags.is_a? Array
          criteria.all(tags: tags)
        end

        def tag_list
          self.all_tags.collect { |tag| tag[:name] }
        end

        def all_tags(scope = {})
          map = %{
            function() {
              if(this.tags){
                this.tags.forEach(function(tag){
                  emit(tag, 1)
                });
              }
            }
          }

          reduce = %{
            function(key, values) {
              var tag_count = 0 ;
              values.forEach(function(value) {
                tag_count += value;
              });
              return tag_count;
            }
          }

          tags = self
          tags = tags.where(scope) if scope.present?

          results = tags.map_reduce(map, reduce).out(inline: 1)
          results.to_a.map! { |item| { name: item['_id'], count: item['value'].to_i } }
        end
      end
    end
  end
end
