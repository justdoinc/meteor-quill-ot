DeltaServer = @DeltaServer = ->

  @connections = {}
  @server = new Delta()

  return @

_.extend DeltaServer.prototype,

  connect: () ->
    id = Random.id()
    @connections[id] =
      base: @server
      client: @server

    return [id, @connections[id].client]

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
    update = connection.base.diff(@server).transform(connection.base.diff(connection.client))
    connection.client = @server.compose(update)
    connection.base = @server

    # XXX defer(toServer(@server.diff(@client)))

    return connection.client

  submitChanges: (id) ->
    # Assume base: +a
    # Assume server: +ab
    # Assume client: +ac

    connection = @connections[id]

    update = connection.base.diff(@server).transform(connection.base.diff(connection.client))

    @server = @toServer(update)
    connection.base = connection.client
