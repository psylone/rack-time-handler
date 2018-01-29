class TimeFormatHandler

  def self.params_handler(params, output, wrong_output)
    params.each do |param|
      # NOTE: для чего это выражение? В `param` будет определённый сегмент форматтера, например, `year` или `month`.
      index = param.index("=")
      # NOTE: для примера из задания здесь ошибка `ArgumentError: bad value for range`.
      type = param[0...index]
      select_params(param, type, output, wrong_output)
    end
  end

  # NOTE: идея в том что передаётся только строка формата с сегментами форматирования, то есть без конкретных значений даты или времени. Имеется в виду что для текущего момента времени согласно данным форматтера вернётся нужная строка.
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
