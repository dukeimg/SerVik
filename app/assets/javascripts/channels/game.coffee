App.createChannel = ->
  App.game = App.cable.subscriptions.create "GameChannel",
    connected: ->

    disconnected: ->


    received: (data) ->
      switch data.action
        when "subscribed"
          @printMessage("UUID: #{data.uuid}.")
        when "opponent_disconnected"
          @printMessage('Соединение разорвано')
        when 'waiting_for_code'
          showSetCode()
        when 'turn'
          @printMessage(data.msg)
        when 'game_start'
          initGame(data)


    printMessage: (message) ->
      $("#messages").append("<p>#{message}</p>")
