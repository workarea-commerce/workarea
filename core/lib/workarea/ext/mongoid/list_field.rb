module Mongoid
  module ListField
    def list_field(name)
      self.class_eval <<-RUBY
        def #{name}_list
          #{name}.join(', ') if #{name}.present?
        end

        def #{name}_list=(val)
          if val.blank?
            self.#{name} = []
          else
            self.#{name} = val.split(',').map(&:strip).delete_if(&:blank?)
          end
        end
      RUBY
    end
  end
end

Mongoid::Document::ClassMethods.send(:include, Mongoid::ListField)
