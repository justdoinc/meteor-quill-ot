DeltaServer = @DeltaServer = ->

  @connections = {}
  @server = new Delta()

  return @

_.extend DeltaServer.prototype,

  connect: (id) ->
    id = id ? Random.id()
    @connections[id] = @connections[id] ?
      base: @server
      client: @server

    return [id, @connections[id].client]

  disconnect: (id) ->

    delete @connections[id]

  current: (id) -> @connections[id].client

  fromClient: (id, diff) ->
    # Assume base: +a
    # Assume server: +ab
    # Assume client: +ac
    # Assume diff: ..+d

    # Correct output:
    # base: +ab
    # client: +acdb
    # return +acdb

    connection = @connections[id]

    connection.client = connection.client.compose(diff)

    if connection.paused
      return connection.client

    update = connection.base.diff(@server).transform(connection.base.diff(connection.client))
    connection.client = @server.compose(update)

    if not connection.paused
      connection.base = @server

    # XXX defer(toServer(@server.diff(@client)))

    return connection.client

  submitChanges: (id) ->
    # Assume base: +a
    # Assume server: +ab
    # Assume client: +ac

    connection = @connections[id]

    if connection.paused
      return

    update = connection.base.diff(@server).transform(connection.base.diff(connection.client))

    connection.paused = true
    old_client = connection.client
    @toServer update, (err, result) =>
      if err
        throw err

      @server = result
      connection.base = old_client
      connection.paused = false

  resyncServer: () ->

    @toServer new Delta(), (err, result) =>
      @server = result
