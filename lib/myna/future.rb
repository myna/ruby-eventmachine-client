# Copyright 2011 by Untyped Ltd. All Rights Reserved\
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# No portion of this Software shall be used in any application which does not
# use the ReportGrid platform to provide some subset of its functionality.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require 'thread'


module Future
  class Future
    def initialize()
      @lock = Mutex.new
      @signal = ConditionVariable.new
      @value = nil
      @delivered = false
      @listeners = []
    end

    def deliver(value)
      @lock.synchronize {
        if @delivered
          raise ArgumentError, "This future has already been delivered a value"
        else
          @value = value
          @delivered = true
          @signal.broadcast
        end
      }
      @listeners.each do |block|
        block.call(value)
      end
    end

    def get
      @lock.synchronize {
        if !@delivered
          @signal.wait(@lock)
          @signal.broadcast
        end

        @value
      }
    end

    def on_complete(&block)
      return_value = false
      @lock.synchronize {
        if @delivered
          return_value = true
        else
          @listeners.push(block)
        end
      }

      # We can't call the block inside the synchronise block as the
      # block may itself block on another lock. In this case it won't
      # exit the synchronise block and we can get deadlock
      if return_value
        block.call(@value)
      end
    end

    def map(&block)
      future = Future.new
      self.on_complete do |value|
        future.deliver(block.call(value))
      end
      future
    end
  end
end
