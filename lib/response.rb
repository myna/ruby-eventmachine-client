require 'json'
require 'singleton'

module Response
  # String -> Response
  #
  # Parse a JSON string into a Response object
  def Response.parse(str) 
    json = JSON.parse str
    case json['typename']
    when 'mynaapierror'
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

  class ApiError < Response
    def self.from_json(json)
      error = ApiError.new(json['code'], json['message'])
    end

    attr_reader :code
    attr_reader :message

    def initialize(code, message)
      @code = code
      @message = message
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
