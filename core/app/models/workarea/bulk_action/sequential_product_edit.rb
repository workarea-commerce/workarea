module Workarea
  class BulkAction
    class SequentialProductEdit < BulkAction
      # Good god is this gnarly, but the amount of code to do this better would
      # be very large.
      def find_product(index)
        @current_index = 0
        @seeking_index = index.to_i
        catch(:matching_index) { perform! }
      end

      # It's ok to override here, since this BulkAction doesn't really have a
      # chunk of work to do for each product - it's up to the administrator.
      def act_on!(product)
        @current_index ||= 0
        throw :matching_index, product if @current_index == @seeking_index
        @current_index += 1
      end
    end
  end
end
