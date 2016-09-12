App.game = App.cable.subscriptions.create "GameChannel",
  connected: ->
    @printMessage("Подкючен. Поиск оппонента")

  disconnected: ->
    @printMessage("Отключен")

  received: (data) ->
    switch data.action
      when "subscribed"
        @printMessage("UUID: #{data.uuid}.")
      when "opponent_disconnected"
        @printMessage('Соединение разорвано')
      when 'waiting_for_code'
        @printMessage('Опонент найден. Жду код')


  printMessage: (message) ->
    $("#messages").append("<p>#{message}</p>")