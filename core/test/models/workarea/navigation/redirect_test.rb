require 'test_helper'

module Workarea
  module Navigation
    class RedirectTest < TestCase
      def test_does_not_allow_duplicate_paths
        create_redirect(path: '/test')
        dup = Redirect.new(path: '/test')

        refute(dup.valid?)
        assert(dup.errors[:path].present?)
      end

      def test_finds_the_redirect_based_on_path
        path = '/test_path'
        redirect = create_redirect(path: path)

        assert_equal(redirect, Redirect.find_by_path(path))
      end

      def test_sanitizing_paths
        redirect = create_redirect(path: '/one/')

        %w(/one one/ /one/ one? one/?).each do |test|
          assert_equal(redirect, Redirect.find_by_path(test))
        end
      end

      def test_handle_invalid_path
        path = '/category/FoalBroodmare/Supplements-Mares & Foals/20552.html'
        encoded_path = URI.encode(path)
        redirect = Redirect.create(path: path, destination: '/')

        assert(redirect.valid?, redirect.errors.full_messages.to_sentence)
        assert_equal(encoded_path, redirect.path)

        new_redirect = Redirect.new(path: encoded_path, destination: '/')

        refute(new_redirect.valid?)
        assert(new_redirect.errors[:path].present?)

        assert_equal(redirect.reload.path, new_redirect.path)

        new_redirect = Redirect.new(path: path, destination: '/')

        refute(new_redirect.valid?)
        assert(new_redirect.errors[:path].present?)
      end
    end
  end
end
