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

  module AuthorizedHost
    SCHEME = "https"
    HOST   = 'api.mynaweb.com'
    PORT   = 443
  end

  module UnauthorizedHost
    SCHEME = "http"
    HOST   = 'api.mynaweb.com'
    PORT   = 80
  end

  class Api
    def initialize(api)
      @api = api
    end

    def make_request(uri)
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

    def build_uri(path)
      "#{@api::SCHEME}://#{@api::HOST}:#{@api::PORT}#{path}"
    end

    def create
      build_uri("/v1/experiment/new")
    end

    def suggest(uuid)
      build_uri("/v1/experiment/#{uuid}/suggest")
    end

    def reward(uuid)
      build_uri("/v1/experiment/#{uuid}/reward")
    end

    def delete(uuid)
      build_uri("/v1/experiment/#{uuid}/delete")
    end

    def info(uuid)
      build_uri("/v1/experiment/#{uuid}/info")
    end

    def create_variant(uuid)
      build_uri("/v1/experiment/#{uuid}/new-variant")
    end

    def delete_variant(uuid)
      build_uri("/v1/experiment/#{uuid}/delete-variant")
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

  # The simple API for unauthorized access
  class Experiment
    def initialize(uuid, host = UnauthorizedHost)
      @uuid = uuid
      @host = host
      @api  = Api.new(host)
    end

    attr_reader :uuid

    def suggest()
      @api.make_request(@api.suggest(@uuid)) do |client|
        client.get(:head => {'Accept' => 'application/json'})
      end
    end

    def reward(token, amount = 1.0)
      @api.make_request(@api.reward(@uuid)) do |client|
        client.post(:head => {'Accept' => 'application/json'},
                    :body => {:token => token, :amount => amount}.to_json)
      end
    end
  end

  # The more complex API for authorized access
  class ExperimentFactory
    def initialize(email, password, host = AuthorizedHost)
      @email    = email
      @password = password
      @host     = host
      @api      = Api.new(host)
    end

    def create(name)
      @api.make_request(@api.create()) do |client|
        client.post(:head => {
                      'Accept' => 'application/json',
                      'Authorization' => [@email, @password]
                    },
                    :body => {:experiment => name}.to_json)

      end
    end

    def experiment(uuid)
      AuthorizedExperiment.new(uuid, @email, @password, @host)
    end
  end

  class AuthorizedExperiment < Experiment
    def initialize(uuid, email, password, host)
      super(uuid, host)
      @email    = email
      @password = password
    end

    def delete
      @api.make_request(@api.delete(@uuid)) do |client|
        client.get(:head => {
                     'Accept' => 'application/json',
                     'Authorization' => [@email, @password]
                   })
      end
    end

    def info
      @api.make_request(@api.info(@uuid)) do |client|
        client.get(:head => {
                     'Accept' => 'application/json',
                     'Authorization' => [@email, @password]
                   })
      end
    end

    def create_variant(name)
      @api.make_request(@api.new_variant()) do |client|
        client.post(:head => {
                      'Accept' => 'application/json',
                      'Authorization' => [@email, @password]
                    },
                    :body => {:variant => name}.to_json)

      end
    end

    def delete_variant(name)
      @api.make_request(@api.delete_variant()) do |client|
        client.post(:head => {
                      'Accept' => 'application/json',
                      'Authorization' => [@email, @password]
                    },
                    :body => {:variant => name}.to_json)
      end
    end
  end

end
