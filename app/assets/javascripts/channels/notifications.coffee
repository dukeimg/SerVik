App.notifications = App.cable.subscriptions.create "NotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    switch data.title
      when 'players_online'
        localStorage.setItem('players_online', data.message)
        $("#players-online").html(data.message)