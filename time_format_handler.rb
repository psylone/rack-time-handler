class TimeFormatHandler

  def self.params_handler(params, output, wrong_output)
    params.each do |param|
      index = param.index("=")
      type = param[0...index]
      select_params(param, type, output, wrong_output)
    end
  end

  def self.select_params(param, type, output, wrong_output)
    case type
    when 'year'
      year = param[5..-1]
      output[0] = year
    when 'month'
      month = param[6..-1]
      output[1] = month
    when 'day'
      day = param[4..-1]
      output[2] = day
    when 'hour'
      hour = param[5..-1]
      output[3] = hour
    when 'minute'
      minute = param[7..-1]
      output[4] = minute
    when 'second'
      second = param[7..-1]
      output[5] = second
    else
      wrong_output << type
    end
  end

end
