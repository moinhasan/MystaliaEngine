$(window).load ->
  # Maps are made by "Tiled", see how to structure new maps on the wiki.
  # Unlike other classes, the map class is used for all maps and is not just a single instance.
  window.map = new Map()

  window.socket = io()
  socket.on 'connect', ->
    socket.emit 'auth', window.localStorage['auth']
    socket.on 'auth', (auth) ->
      if auth
        window.inventory = new Inventory()
        socket.emit 'changeMap', auth
      else
        location.href = "/"

    socket.on 'changeMap', (result) ->
      if result.map
        # Load a map first, followed by anything else map related.
        map.load result.map, ->
          window.player = new Character result.username, 'ragnar', { x: result.x * 32, y: result.y * 32 }, true
          window.playerInput = new Input player
          map.setEffect "dark"

    socket.on 'move', (result) ->
      name = result.username
      unless name is player.name
        if npcStore[name]
          npcStore[name].moveNPC result.username, result.x, result.y
        else
          socket.emit 'queryHero', name

    socket.on 'queryHero', (result) ->
      window.npcStore[result.username] = new Character result.username, 'ragnar', { x: result.x * 32, y: result.y * 32 }, false

    socket.on 'heroLeave', (name) ->
      if player
        unless name is player.name
          npc = window.npcStore[name]
          if npc
            $(npc.element).fadeOut -> $(@).remove()
            delete window.npcStore[name]
    socket.on 'heroJoin', (name) ->
      if player
        unless name is player.name
          socket.emit 'queryHero', name

    socket.on 'chat', (result) ->
      $('#chat-well').append "#{result.username}: #{result.msg}<br />"
      .scrollTop($('#chat-well br').length * 20)

    socket.on 'mapItems', (result) ->
      map.items = result
      map.placeItems()

    socket.on 'removeMapItem', (item) -> map.removeItem item

    socket.on 'addMapItem', (item) -> map.addItem item

    socket.on 'userItems', (items) -> inventory.populate items

    socket.on 'addUserItem', (item) -> inventory.addItem item

    socket.on 'shop', (data) -> new Shop(data.shop, data.items)

    socket.on 'shopTrade', -> socket.emit 'userItems'

    socket.on 'disconnect', ->
      setTimeout ->
        location.href = location.href
      , 1000




