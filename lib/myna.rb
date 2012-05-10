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

  # Run EventMachine, if it is not already running. Returns a future.
  # Block on the future to wait till EventMachine is up
  def Myna.run()
    future = Future.new

    if EventMachine::reactor_running?
      future.deliver(true)
    else
      Thread.new do
        EventMachine::run {}
      end

      EventMachine::next_tick do
        future.deliver(true)
      end
    end

    future
  end

  def Myna.stop()
    EventMachine::stop_event_loop
  end

  module API
    SCHEME = "https"
    HOST   = 'api.mynaweb.com'
    PORT   = 443
  end

  class Path
    include Singleton

    def suggest(uuid)
      "/v1/experiment/#{uuid}/suggest"
    end

    def reward(uuid)
      "/v1/experiment/#{uuid}/reward"
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
      @lock.synchronize {
        @value = value
        @delivered = true
        @signal.broadcast
      }
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
  end

  class Experiment
    def initialize(uuid, scheme = API::SCHEME, host = API::HOST, port = API::PORT, path = Path.instance)
      @uuid   = uuid
      @host   = host
      @port   = port
      @scheme = scheme
      @path   = path
    end

    def build_uri(path)
      "#{@scheme}://#{@host}:#{@port}#{path}"
    end

    def make_request(path)
      uri = build_uri(path)
      puts "Contacting "+uri
      future = Future.new

      EventMachine::run do
        client = EventMachine::HttpRequest.new(uri)

        http = yield(client)
        http.errback  { future.deliver("badness") }
        http.callback { future.deliver(Response.parse(http.response)) }
      end

      future
    end

    def suggest()
      make_request(@path.suggest(@uuid)) do |client|
        client.get(:head => {'Accept' => 'application/json'})
      end
    end

    def reward(token, amount = 1.0)
      make_request(@path.reward(@uuid)) do |client|
        client.post(:head => {'Accept' => 'application/json'},
                    :body => {:token => token, :amount => amount}.to_json)
      end
    end
  end

end
