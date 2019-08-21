module Workarea
  class DeferredGarbageCollection
    DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 3.0).to_f

    @@last_gc_run = Time.current

    def self.start
      GC.disable if DEFERRED_GC_THRESHOLD > 0
    end

    def self.reconsider
      if DEFERRED_GC_THRESHOLD > 0 &&
           Time.current - @@last_gc_run >= DEFERRED_GC_THRESHOLD
        GC.enable
        GC.start
        GC.disable
        @@last_gc_run = Time.current
      end
    end
  end
end
