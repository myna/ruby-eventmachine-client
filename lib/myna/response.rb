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

require 'json'
require 'singleton'

module Response
  # String -> Response
  #
  # Parse a JSON string into a Response object
  def Response.parse(str)
    json = JSON.parse str
    case json['typename']
    when 'problem'
      ApiError.from_json(json)
    when 'ok'
      Ok.instance
    when 'suggestion'
      Suggestion.from_json(json)
    when 'uuid'
      Uuid.from_json(json)
    when 'experiment'
      Experiment.from_json(json)
    else
      raise ArgumentError, "Typename "+json['typename']+" is not a recognized response.", caller
    end
  end


  class Response
  end

  class MynaError < Response
  end

  class NetworkError < MynaError
  end

  class ApiError < MynaError
    def self.from_json(json)
      error = ApiError.new(json['subtype'], json['messages'])
    end

    attr_reader :subtype
    attr_reader :messages

    def initialize(subtype, messages)
      @subtype  = subtype
      @messages = messages
    end
  end

  # Singleton
  class Ok < Response
    include Singleton
  end

  class Suggestion < Response
    def self.from_json(json)
      suggestion = Suggestion.new(json['token'], json['choice'])
    end

    attr_reader :token
    attr_reader :choice

    def initialize(token, choice)
      @token = token
      @choice = choice
    end
  end

  class Uuid < Response
    def self.from_json(json)
      uuid = Uuid.new(json['uuid'])
    end

    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end
  end

  class Experiment < Response
    def self.from_json(json)
      variants = json['variants'].map { |variant| Variant.from_json(variant) }
      experiment = Experiment.new(json['name'], json['uuid'], json['accountId'], variants)
    end

    attr_reader :name
    attr_reader :uuid
    attr_reader :accountId
    attr_reader :variants

    def initialize(name, uuid, accountId, variants)
      @name = name
      @uuid = uuid
      @accountId = accountId
      @variants = variants
    end
  end

  class Variant < Response
    def self.from_json(json)
      variant = Variant.new(json['name'], json['views'], json['totalReward'], json['confidenceBound'])
    end

    attr_reader :name
    attr_reader :views
    attr_reader :totalReward
    attr_reader :confidenceBound

    def initialize(name, views, totalReward, confidenceBound)
      @name = name
      @views = views
      @totalReward = totalReward
      @confidenceBound = confidenceBound
    end
  end
end
