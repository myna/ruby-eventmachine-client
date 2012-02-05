require 'json'

module Response
  # String -> Response
  #
  # Parse a JSON string into a Response object
  def parse(str) 
    json = JSON.parse str
    case json['typename']
    when 'mynaapierror'
      ApiError.from_json(json)
    when 'ok'
      Ok
    when 'suggestion'
      Suggestion.from_json(json)
    when 'uuid'
      Uuid.from_json(json)
    when 'experiment'
      Experiment.from_json(json)
    when 'user'
      User.from_json(json)
    when 'uuids'
      # ...
    else
      # ...
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
  module Ok < Response
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
end
