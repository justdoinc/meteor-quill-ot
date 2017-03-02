describe "Connection", ->
  server = null
  client = null
  server_messages = null
  client_messages = null

  beforeEach ->
    server_messages = []
    client_messages = []
    server = new Connection()
    client = new Connection()

    server.toClient = (args...) => server_messages.push args
    client.toServer = (args...) => client_messages.push args

    server.requestServerResync = () => return
    client.requestClientResync = () => return

    server.toServer = () => return
    client.toClient = () => return

    server.fromServer({ content: new Delta() })
    client.fromServer.apply(client, server_messages.pop())

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

  it "should handle out of order messages", ->

    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('1') })
    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('2') })
    client.fromClient({ base_id: client.base._id, delta: new Delta().insert('1') })
    client.fromClient({ base_id: client.base._id, delta: new Delta().insert('2') })

    _.each server_messages, (args) ->

      client.fromServer.apply(client, args)

    _.each client_messages.reverse(), (args) ->

      server.fromClient.apply(server, args)

    assert.deepEqual(client.content(), server.content())

  it "should handle missing messages", ->

    server.requestClientResync = () => client.resyncServer.apply(client, arguments)

    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('1') })
    server.fromServer({ base_id: server.base._id, delta: new Delta().insert('2') })
    client.fromClient({ base_id: client.base._id, delta: new Delta().insert('1') })
    client.fromClient({ base_id: client.base._id, delta: new Delta().insert('2') })

    # Message 0 is the missing message
    # Message 1 is the message that got through
    server.fromClient.apply(server, client_messages[1])

    # Message 2 is the resync
    server.fromClient.apply(server, client_messages[2])

    _.each server_messages, (args) ->

      client.fromServer.apply(client, args)

    assert.deepEqual(client.content(), server.content())
