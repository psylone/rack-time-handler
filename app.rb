require_relative 'time_format_handler'

class App
  # NOTE: Где используется этот ридер?
  attr_accessor :status

  def call(env)
    req = Rack::Request.new(env)
    # NOTE: нет смысла обрабатывать параметры если URL not_found (не /time).
    params(req)
    # NOTE: не вполне понятно что именно делает метод. На самом деле, он обрабатывает запрос поэтому лучше назвать его `make_response` или `process_request`.
    request(req)
  end

  private

  def request(req)
    case req.path_info
    when /time/
      # NOTE: было бы лучше здесь определить метод `process_time_request`, например, а уже внутри него возвращать Rack-совместимый ответ.
      # NOTE: `@status` если ты будешь использовать переменную экземпляра здесь, то при выполнении Rack-приложения в нескольких потоках (трэдах) результат окажется не предсказуем. Так происходит потому что в метод `run` передаётся объект класса `App`, то есть по факту каждый запрос будет обрабатывать **один и тот же объект**. Если, например первый поток выставит `@status` в значение 404, второй поток может затем установить `@status` в значение 200. Затем первый поток продолжит выполнение и выдаст неверный результат.
      [@status, headers, body(req)]
    else
      [404, headers, ["Not found!\n"]]
    end

  end

  def headers
    { 'Content-Type' => 'text/plain'}
  end

  # NOTE: не вполне понятна обазанность метода `params`. Что именно он делает? Возвращает параметры GET запроса, POST запроса, что-то ещё?
  # NOTE: направление мысли верное, но это должен быть `process_time_request` метод примерно с таким содержанием:
  #
  # ```ruby
  #   def process_time_request(request)
  #     result = TimeFormatHandler.new(request.params).process
  #
  #     if result.success?
  #       [200, headers, [result.time]]
  #     else
  #       [400, headers, [result.wrong_time_formatters]]
  #     end
  #   end
  # ```
  #
  # То есть идея в том, чтобы был четко выраженный метод который обрабатывает конкретный запрос. Далее внутри этого метода работает конкретная логика и в зависимости от того как успешно эта логика сработала мы возвращаем либо успешный Rack-ответ, либо с ошибкой. При этом вся логика реализована внутри класса `TimeFormatHandler`. Этот класс может работать независимо, всё что ему нужно - строка параметра `format`. Интерфейс `wrong_output` и `output` - это знание `TimeFormatHandler`, уровень Rack-обработчика ничего не должен об этом знать. Также как и `TimeFormatHandler` не должен ничего знать о том как будет использоваться его результат. Его обязанность получить строку с параметрами и вычислить результат. В качестве результата у нас будет либо строка времени, либо массив с сегментами формата которые не поддерживаются.
  #
  # У тебя сейчас получается что логика обработки конкретного запроса размазывается между методами `params` и `body`. Кроме того, может добавиться ещё один URL который нужно будет отдельно обрабатывать согласно совершенно другой логике.
  def params(req)
    # NOTE: на данный момент здесь будет ошибка если мы обращаемся по URL в котором нет параметра строки запроса `format`.
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
