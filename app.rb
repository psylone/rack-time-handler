require_relative 'time_format_handler'

class App
  attr_accessor :status

  def call(env)
    req = Rack::Request.new(env)
    params(req)
    request(req)
  end

  private

  def request(req)
    case req.path_info
    when /time/
      [@status, headers, body(req)]
    else
      [404, headers, ["Not found!\n"]]
    end

  end

  def headers
    { 'Content-Type' => 'text/plain'}
  end

  def params(req)
    params = req.params["format"].split(',')

    output = Array.new(6)
    wrong_output = []

    TimeFormatHandler.params_handler(params, output, wrong_output)

    if wrong_output.empty?
      @status = 200
      output.compact.join('-')
    else
      @status = 400
      "Unknown time format #{wrong_output}"
    end

  end

  def body(req)
    ["#{params(req)}\n"]
  end

end
