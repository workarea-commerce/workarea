require 'test_helper'

module Sidekiq
  class CallbacksTest < Workarea::TestCase
    class Model
      include Mongoid::Document
      include Sidekiq::Callbacks
      field :name
    end

    class Subclass < Model
      field :type
    end

    module ModelModule
      extend ActiveSupport::Concern
      include Mongoid::Document
      include Sidekiq::Callbacks
    end

    class ModuleModel
      include ModelModule
    end

    class ValidationsModel
      include Mongoid::Document
      include Sidekiq::Callbacks
      field :name
      validates :name, presence: true
    end

    class CustomCallbackModel
      include Mongoid::Document
      include Sidekiq::Callbacks
      define_callbacks :foo

      def foo
        run_callbacks :foo do
          # noop
        end
      end
    end

    class InterruptedCallbackModel
      include Mongoid::Document
      include Sidekiq::Callbacks
      before_create :foo

      def foo
        throw :abort
      end
    end

    class RelatedCallbackModel
      include Mongoid::Document
      include Sidekiq::Callbacks
    end

    class MultipleCallbackModel
      include Mongoid::Document
      include Sidekiq::Callbacks
    end

    class Worker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker

      sidekiq_options(
        enqueue_on: {
          Model => :create,
          ModelModule => :create,
          CustomCallbackModel => :foo,
          InterruptedCallbackModel => :create,
          RelatedCallbackModel => :save,
          MultipleCallbackModel => [:save, :destroy]
        }
      )

      def perform(*)
      end
    end

    class SingleWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker
      sidekiq_options enqueue_on: { Model => :create }

      def perform(*)
      end
    end

    class CustomArgsWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker
      sidekiq_options enqueue_on: {
        Model => :save, with: -> { [id, changes] }
      }

      def perform(*)
      end
    end

    class FilteringWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker
      sidekiq_options enqueue_on: { Model => :save, ignore_if: -> { true } }

      def perform(*)
      end
    end

    class OnlyFilteringWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker
      sidekiq_options enqueue_on: { Model => :save, only_if: -> { false } }

      def perform(*)
      end
    end

    class OnlyAndIgnoreWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker
      sidekiq_options(
        enqueue_on: {
          Model => :save,
          only_if: -> { self.name.to_i.even? },
          ignore_if: -> { self.name.to_i.zero? }
        }
      )

      def perform(*)
      end
    end

    class TestTrackingWorkerOne; end
    class TestTrackingWorkerTwo; end

    setup :setup_sidekiq
    teardown :teardown_sidekiq

    def setup_sidekiq
      Sidekiq::Testing.fake!

      Sidekiq::Callbacks.async(Worker, SingleWorker, CustomArgsWorker)
      Sidekiq::Callbacks.enable(Worker, SingleWorker, CustomArgsWorker)

      Worker.drain
      SingleWorker.drain
      CustomArgsWorker.drain
    end

    def teardown_sidekiq
      Sidekiq::Testing.inline!
    end

    def test_standard_callback
      model = nil

      assert_difference 'Worker.jobs.size', 1 do
        model = Model.create!(name: 'foo')
      end

      args = Worker.jobs.first['args']
      assert_equal(args.first, model.id.to_s)
    end

    def test_subclass_callbacks
      model = nil

      assert_difference 'Worker.jobs.size', 1 do
        model = Subclass.create!(name: 'foo', type: 'bar')
      end

      args = Worker.jobs.first['args']
      assert_equal(args.first, model.id.to_s)
    end

    def test_module_callbacks
      model = nil

      assert_difference 'Worker.jobs.size', 1 do
        model = ModuleModel.create!
      end

      args = Worker.jobs.first['args']
      assert_equal(args.first, model.id.to_s)
    end

    def test_failed_callbacks
      ValidationsModel.create!
    rescue Mongoid::Errors::Validations
      assert(Worker.jobs.empty?)
    end

    def test_custom_callbacks
      model = nil

      assert_difference 'Worker.jobs.size', 1 do
        model = CustomCallbackModel.new
        model.foo
      end

      args = Worker.jobs.first['args']
      assert_equal(args.first, model.id.to_s)
    end

    def test_interrupted_callbacks
      InterruptedCallbackModel.create
      assert(Worker.jobs.empty?)
    end

    def test_related_callbacks
      model = nil

      assert_difference 'Worker.jobs.size', 1 do
        model = RelatedCallbackModel.create!
      end

      args = Worker.jobs.first['args']
      assert_equal(args.first, model.id.to_s)
    end

    def test_multiple_callbacks
      model = nil

      assert_difference 'Worker.jobs.size', 1 do
        model = MultipleCallbackModel.create!
      end

      args = Worker.jobs.last['args']
      assert_equal(args.first, model.id.to_s)

      assert_difference 'Worker.jobs.size', 1 do
        model.destroy
      end

      args = Worker.jobs.last['args']
      assert_equal(args.first, model.id.to_s)
    end

    def test_custom_arguments
      model = Model.create!(name: 'foo')
      model.update_attributes!(name: 'bar')

      args = CustomArgsWorker.jobs.last['args']
      assert_equal(args.first, model.id.to_s)
      assert_equal(args.second, { 'name' => ['foo', 'bar'] })
    end

    def test_enabling_and_disabling
      Sidekiq::Callbacks.disable do
        assert_no_difference 'Worker.jobs.size' do
          Model.create!(name: 'foo')
        end

        Sidekiq::Callbacks.enable do
          assert_difference 'Worker.jobs.size', 1 do
            Model.create!(name: 'bar')
          end

          Sidekiq::Callbacks.disable do
            assert_no_difference 'Worker.jobs.size' do
              Model.create!(name: 'baz')
            end
          end
        end
      end
    end

    def test_disabling_specific_workers
      Sidekiq::Callbacks.disable(Worker)

      assert_no_difference 'Worker.jobs.size' do
        Model.create!(name: 'foo')
      end

      Sidekiq::Callbacks.disable(SingleWorker) do
        refute(SingleWorker.enabled?)
        assert_no_difference 'SingleWorker.jobs.size' do
          Model.create!(name: 'bar')
        end
      end

      assert(SingleWorker.enabled?)
      refute(Worker.enabled?)
    end

    def test_enabling_specific_workers
      Sidekiq::Callbacks.disable(Worker)

      Sidekiq::Callbacks.enable(Worker) do
        assert(Worker.enabled?)
        assert_difference 'Worker.jobs.size', 1 do
          Model.create!(name: 'foo')
        end
      end

      refute(Worker.enabled?)

      Sidekiq::Callbacks.enable(Worker, SingleWorker) do
        assert(Worker.enabled?)
        assert(SingleWorker.enabled?)
      end

      refute(Worker.enabled?)
      assert(SingleWorker.enabled?)
    end

    def test_enabling_specific_workers_when_globally_disabled
      Sidekiq::Callbacks.disable

      Sidekiq::Callbacks.enable(Worker) do
        assert(Worker.enabled?)
        assert_difference 'Worker.jobs.size', 1 do
          Model.create!(name: 'foo')
        end
      end

      refute(Worker.enabled?)
    end

    def test_inlining
      Sidekiq::Callbacks.inline do
        assert_no_difference 'Worker.jobs.size' do
          Model.create!(name: 'foo')
        end

        Sidekiq::Callbacks.async do
          assert_difference 'Worker.jobs.size', 1 do
            Model.create!(name: 'bar')
          end

          Sidekiq::Callbacks.inline do
            assert_no_difference 'Worker.jobs.size' do
              Model.create!(name: 'baz')
            end
          end
        end
      end
    end

    def test_inlining_specific_workers
      Sidekiq::Callbacks.inline(Worker)

      assert_no_difference 'Worker.jobs.size' do
        Model.create!(name: 'foo')
      end

      Sidekiq::Callbacks.inline(SingleWorker) do
        assert(SingleWorker.inlined?)
        assert_no_difference 'SingleWorker.jobs.size' do
          Model.create!(name: 'bar')
        end
      end

      refute(SingleWorker.inlined?)
      assert(Worker.inlined?)
    end

    def test_asyncing_specific_workers
      Sidekiq::Callbacks.inline(Worker)

      Sidekiq::Callbacks.async(Worker) do
        refute(Worker.inlined?)
        assert_difference 'Worker.jobs.size', 1 do
          Model.create!(name: 'foo')
        end
      end

      assert(Worker.inlined?)

      Sidekiq::Callbacks.async(Worker, SingleWorker) do
        refute(Worker.inlined?)
        refute(SingleWorker.inlined?)
      end

      assert(Worker.inlined?)
      refute(SingleWorker.inlined?)
    end

    def test_async_specific_workers_when_globally_inline
      Sidekiq::Callbacks.inline

      Sidekiq::Callbacks.async(Worker) do
        refute(Worker.inlined?)
        assert_difference 'Worker.jobs.size', 1 do
          Model.create!(name: 'foo')
        end
      end

      assert(Worker.inlined?)
    end

    def test_filtering_callbacks
      Sidekiq::Callbacks.async(FilteringWorker)
      Sidekiq::Callbacks.enable(FilteringWorker)

      assert_no_difference 'FilteringWorker.jobs.size' do
        Model.create!(name: 'foo')
      end
    end

    def test_filtering_only_if_callbacks
      Sidekiq::Callbacks.async(OnlyFilteringWorker)
      Sidekiq::Callbacks.enable(OnlyFilteringWorker)

      assert_no_difference 'OnlyFilteringWorker.jobs.size' do
        Model.create!(name: 'foo')
      end
    end

    def test_only_if_and_only_if_filtering
      Sidekiq::Callbacks.async(OnlyAndIgnoreWorker)
      Sidekiq::Callbacks.enable(OnlyAndIgnoreWorker)

      assert_no_difference 'OnlyAndIgnoreWorker.jobs.size' do
        Model.create!(name: 't')
      end

      assert_changes 'OnlyAndIgnoreWorker.jobs.size', from: 0, to: 1 do
        Model.create!(name: '4')
      end
    end

    def test_state_when_error_raised
      Sidekiq::Callbacks.enable(Worker)

      assert_raises do
        Sidekiq::Callbacks.disable(Worker) { raise 'foo' }
      end

      assert(Worker.enabled?)
    end

    def test_tracking_workers
      current_workers = ::Rails.application.config.sidekiq_callbacks_workers
      ::Rails.application.config.sidekiq_callbacks_workers = []

      Sidekiq::Callbacks.add_worker(TestTrackingWorkerOne)
      assert_includes(Sidekiq::Callbacks.workers, TestTrackingWorkerOne)

      current_cache_classes = ::Rails.application.config.cache_classes
      ::Rails.application.config.cache_classes = false
      ::Rails.application.config.sidekiq_callbacks_workers = []

      Sidekiq::Callbacks.add_worker(TestTrackingWorkerTwo)
      assert_includes(Sidekiq::Callbacks.workers, TestTrackingWorkerTwo)

    ensure
      ::Rails.application.config.sidekiq_callbacks_workers = current_workers
      ::Rails.application.config.cache_classes = current_cache_classes
    end
  end
end
