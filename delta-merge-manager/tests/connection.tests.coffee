describe "Connection", ->
  server = null
  client = null
  server_messages = null
  client_messages = null

  beforeEach ->
    server_messages = []
    client_messages = []
    server = new Connection(
      { delta: new Delta() }
    , ->
        server_messages.push(_.toArray(arguments))
    , ->
      null
    )
    client = new Connection(
      server_messages.pop()[0]
    , ->
        null
    , ->
      client_messages.push(_.toArray(arguments))
    )

  it "should emit a client message on startup", ->

    assert.deepEqual(client.content(), new Delta())

  it "should push server update to the client", ->

    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('1') })

    _.each server_messages, (args) ->

      client.fromServer.apply(client, args)

    assert.deepEqual(client.content(), server.content())

  it "should push client update to the server", ->

    client.fromClient({ base_id: server.base._id, delta: new Delta().insert('1') })

    _.each client_messages, (args) ->

      server.fromClient.apply(server, args)

    assert.deepEqual(client.content(), server.content())

  it "should sync client and server after multiple messages in each direction", ->

    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('1') })
    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('2') })
    client.fromClient({ base_id: client.base._id, delta: new Delta().insert('1') })
    client.fromClient({ base_id: client.base._id, delta: new Delta().insert('2') })

    _.each server_messages, (args) ->

      client.fromServer.apply(client, args)

    _.each client_messages, (args) ->

      server.fromClient.apply(server, args)

    assert.deepEqual(client.content(), server.content())

  # TODO:

  # it "should handle out of order messages", ->
  #
  #   server.fromServer({ base_id: server.base._id, delta: new Delta().insert('1') })
  #   server.fromServer({ base_id: server.base._id, delta: new Delta().insert('2') })
  #   client.fromClient({ base_id: client.base._id, delta: new Delta().insert('1') })
  #   client.fromClient({ base_id: client.base._id, delta: new Delta().insert('2') })
  #
  #   _.each server_messages, (args) ->
  #
  #     client.fromServer.apply(client, args)
  #
  #   _.each client_messages.reverse(), (args) ->
  #
  #     server.fromClient.apply(server, args)
  #
  #   assert.deepEqual(client.content(), server.content())


  # it "should handle missing messages", ->
  #
  #   server.fromServer({ base_id: server.base._id, delta: new Delta().insert('1') })
  #   server.fromServer({ base_id: server.base._id, delta: new Delta().insert('2') })
  #   client.fromClient({ base_id: client.base._id, delta: new Delta().insert('1') })
  #   client.fromClient({ base_id: client.base._id, delta: new Delta().insert('2') })
  #
  #   _.each server_messages, (args) ->
  #
  #     client.fromServer.apply(client, args)
  #
  #   server.fromClient.apply(server, client_messages[1])
  #
  #   assert.deepEqual(client.content(), server.content())
