require 'statsd'

module Gemstash
  class Statsd

    def initialize(app)
      @app = app

      hostname = Socket.gethostname.split(/(\.)/)[0]
      @statsd = ::Statsd.new('localhost', 8125).tap{|sd| sd.namespace = hostname}
    end

    def call(env)
      start = Time.now

      status, header, body = @app.call env

      # the path with the leading slash removed
      path = env['PATH_INFO'][1..-1]
      path = path.gsub('/', '-')
      path = path.gsub('.', '-')

      metric = ""
      metric << path
      metric << "."
      metric << env["REQUEST_METHOD"].downcase
      metric << "."
      metric << status.to_s

      @statsd.timing(metric, (Time.now - start))
      @statsd.increment(metric)

      [status, header, body]
    end
  end
end
