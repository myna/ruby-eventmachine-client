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

require 'eventmachine'
require 'em-http-request'
require 'json'
require 'thread'


module Myna
  
  # Run EventMachine, if it is not already running.
  def Myna.run()
    Thread.new do
      EventMachine::run {}
    end
  end

  def Myna.stop()
    EventMachine::stop
  end

  module API
    HOST = 'api.mynaweb.com'
    PORT = 80
  end

  class Path
    include Singleton

    def suggest(uuid) 
      '/v1/experiment/'+uuid+'/suggest'
    end
  end

  class Future
    def initialize()
      @lock = Mutex.new
      @signal = ConditionVariable.new
      @value = nil
      @delivered = false
    end

    def deliver(value) 
      @value = value
      @delivered = true
      @lock.synchronize {
        @signal.broadcast
      }
    end

    def get
      if(!@delivered) 
        @lock.synchronize {
          @signal.wait(@lock)
          @signal.broadcast
        }
      end
      @value
    end
  end

  class Experiment
    def initialize(uuid, host = API::HOST, port = API::PORT, path = Path.instance)
      @uuid = uuid
      @host = host
      @port = port
      @path = path
    end

    def suggest()
      path = "http://#{@host}:#{@port}#{@path.suggest(@uuid)}"
      puts "Contacting "+path
      client = EventMachine::HttpRequest.new(path)
      http = client.get(:head  => {'Accept' => 'application/json'})
      future = Future.new
      
      http.errback { future.deliver("badness") }
      http.callback { Response.parse(future.deliver(http.response)) }

      future
    end
  end

end
