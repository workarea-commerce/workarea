require 'test_helper'

module Workarea
  class User
    class AdminVisitTest < TestCase
      def test_most_visited
        create_admin_visit(name: 'Baz', path: '/baz', user_id: 1)
        create_admin_visit(name: 'Foo', path: '/foo', user_id: 2)
        create_admin_visit(name: 'Baz', path: '/baz', user_id: 1)
        create_admin_visit(name: 'Baz', path: '/baz', user_id: 1)
        create_admin_visit(name: 'Bar', path: '/bar', user_id: 1)
        create_admin_visit(name: 'Bar', path: '/bar', user_id: 1)
        create_admin_visit(name: 'Foo', path: '/foo', user_id: 1)

        results = AdminVisit.most_visited(1)
        assert_equal(3, results.length)
        assert_equal({ name: 'Baz', path: '/baz' }, results.first)
        assert_equal({ name: 'Bar', path: '/bar' }, results.second)
        assert_equal({ name: 'Foo', path: '/foo' }, results.third)
      end
    end
  end
end
