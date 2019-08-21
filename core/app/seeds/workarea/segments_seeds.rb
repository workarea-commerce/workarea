module Workarea
  class SegmentsSeeds
    def perform
      puts 'Adding segments...'
      Workarea::Segment::LifeCycle.create!
    end
  end
end
