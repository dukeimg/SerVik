App.game = App.cable.subscriptions.create "GameChannel",
  connected: ->
    @printMessage("Подкючен. Поиск оппонента")

  disconnected: ->
    @printMessage("Отключен")

  received: (data) ->
    switch data.action
      when "init"
        @printMessage("Опонент найден.")
      when "subscribed"
        @printMessage("UUID: #{data.uuid}.")
      when "opponent_disconnected"
        @printMessage(data.msg)
      when 'waiting_for_code'
        @printMessage('Жду код')


  printMessage: (message) ->
    $("#messages").append("<p>#{message}</p>")