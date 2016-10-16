App.createChannel = ->
  App.game = App.cable.subscriptions.create "GameChannel",
    connected: ->

    disconnected: ->


    received: (data) ->
      switch data.action
#        when "subscribed"
#          # some code
#        when "opponent_disconnected"
#          # some code
        when 'waiting_for_code'
          showSetCode()
        when 'turn'
          console.log(data)
        when 'game_start'
          initGame(data)
        when 'turn'
          handleTurn(data)
