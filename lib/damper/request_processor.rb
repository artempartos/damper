module Damper
  class RequestProcessor

    def initialize(options)
      @namespace = options.delete(:namespace)
      @host = options.delete(:host) || Damper::DEFAULT_HOST
      @port = options.delete(:port) || Damper::DEFAULT_PORT
      @forward_to = options.delete(:forward_to)
    end

    def start
      client = Damper::Backend.redis
      describe_start
      Reel::Server.run(@host, @port) do |connection|
        connection.each_request do |request|
          client.publish @namespace, prepare_data(request)
          request.respond :ok, "message recieved"
        end
      end
    end

    def prepare_data(request)
      {
          method: request.method.downcase,
          request_uri: request.path,
          headers: request.headers,
          body: request.body.to_s,
          forward_to: @forward_to
      }.to_json
    end

    def describe_start
      puts "Starting reel web server..."
      puts "Listening on #{@host}:#{@port}"
    end

  end
end
