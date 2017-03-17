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

  finalize: (id, base, client) ->
    connection = @connections[id]

    # client's server should now be connection.client
    # let's update client's base
    client_base = base
    client_server = connection.client
    client_change = client_base.diff(client_server).transform(client_base.diff(client))

    updated_client = client_server.compose(client_change)

    return @fromClient(id, connection.client.diff(updated_client))

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
    connection.old_client = connection.client
    @toServer update, (err, result) =>
      if err
        throw err

      @server = result
      connection.base = connection.old_client
      connection.paused = false

  resyncServer: () ->

    @toServer new Delta(), (err, result) =>
      @server = result
