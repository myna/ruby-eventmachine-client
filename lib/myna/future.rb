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

  def Future.run
    future = Future.new
    future.run(yield)
    future
  end

  class Future
    def initialize()
      @lock = Mutex.new
      @signal = ConditionVariable.new
      @value = nil
      @result = false # false, :success, or :failure
      @listeners = []
    end

    def set(value, result)
      @lock.synchronize {
        if @result
          raise ArgumentError, "This future has already been completed with a value"
        else
          @value = value
          @result = result
          @signal.broadcast
        end
      }

      if result == :success
        @listeners.each do |block|
          block.call(value)
        end
      end
    end

    def succeed(value)
      self.set(value, :success)
    end

    def fail(value)
      self.set(value, :failure)
    end

    def run
      begin
        self.succeed(yield)
      rescue => exn
        self.fail(exn)
      end
    end

    def get
      def handle_value
        case @result
        when :success
          @value
        when :failure
          raise @value
        else
          raise ArgumentError, "Attempted to handle_value when result #{@result} is not :success or :failure"
        end
      end

      @lock.synchronize {
        if @result
          handle_value
        else
          @signal.wait(@lock)
          @signal.broadcast
          handle_value
        end
      }
    end

    def on_complete(&block)
      return_value = false
      @lock.synchronize {
        if @result == :success
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
        future.run do
          block.call(value)
        end
      end
      future
    end
  end
end
