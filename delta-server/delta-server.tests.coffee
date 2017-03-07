describe "DeltaServer", ->

  manager = null
  client_id = null
  beforeEach ->
    manager = new DeltaServer()
    client_id = manager.connect()[0]

  it "should submit server updates to the client", ->
    manager.server = new Delta().insert("hi")

    client = manager.fromClient(client_id, new Delta())

    assert.deepEqual(client, new Delta().insert("hi"))

  it "should merge client and server inserts", ->
    manager.server = new Delta().insert("a")

    client = manager.fromClient(client_id, new Delta().insert("b"))

    assert.deepEqual(client, new Delta().insert("ba"))

  it "should merge multiple client inserts", ->
    client = manager.fromClient(client_id, new Delta().insert("hey"))
    client = manager.fromClient(client_id, new Delta().retain(3).insert(" there"))

    assert.deepEqual(client, new Delta().insert("hey there"))

  it "should merge client after intermediate server update", ->
    manager.server = new Delta().insert("hi")

    manager.fromClient(client_id, new Delta())
    client = manager.fromClient(client_id, new Delta().retain(2).insert(" there"))
    manager.toServer = (update, cb) ->
      return cb(null, new Delta().insert("hey there"))
    manager.submitChanges(client_id)

    client = manager.fromClient(client_id, new Delta().retain(8).insert(", Joe!"))
    assert.deepEqual(client, new Delta().insert("hey there, Joe!"))

  it "should handle async sumbitChanges calls", ->
    manager.server = new Delta().insert("hi")

    manager.fromClient(client_id, new Delta())
    client = manager.fromClient(client_id, new Delta().retain(2).insert(" there"))
    callback = null
    manager.toServer = (update, cb) ->
      callback = cb
    manager.submitChanges(client_id)
    client = manager.fromClient(client_id, new Delta().retain(8).insert(", Joe!"))

    callback(null, new Delta().insert("hey there"))
    client = manager.fromClient(client_id, new Delta())
    assert.deepEqual(client, new Delta().insert("hey there, Joe!"))

  it "should handle multiple async sumbitChanges calls", ->
    manager.server = new Delta().insert("hi")

    manager.fromClient(client_id, new Delta())
    client = manager.fromClient(client_id, new Delta().retain(2).insert(" there"))
    callback = null
    manager.toServer = (update, cb) ->
      callback = cb
    manager.submitChanges(client_id)
    client = manager.fromClient(client_id, new Delta().retain("hi there".length).insert(", Joe!"))
    callback(null, new Delta().insert("hey there"))
    manager.submitChanges(client_id)
    client = manager.fromClient(client_id, new Delta().retain("hi there".length).delete(", Joe!".length).insert(", Sam!"))
    callback(null, new Delta().insert("hi there, Joe!"))
    client = manager.fromClient(client_id, new Delta())
    assert.deepEqual(client, new Delta().insert("hi there, Sam!"))

  it "tourture test", ->

    # every 2 seconds the client submits an operation
    # every 3 seconds the server submits an operation
    # sometimes the network is buggy :)
    manager.server = new Delta().insert("-")
    old_server = manager.server
    server = manager.server
    client = manager.fromClient(client_id, new Delta())
    callbacks = []
    manager.toServer = (op, cb) => callbacks.push([op, cb])

    content = () => client.ops[0].insert

    for i in [0..15]
      if i % 2 == 0
        # add a dot to end of content
        client = manager.fromClient(client_id, new Delta().retain(content().length).insert("o"))
        manager.submitChanges(client_id)
      if i % 3 == 0
        server = server.compose(new Delta().insert("x"))
      if i % 4 != 0 and callbacks.length != 0
        [op, callback] = callbacks.shift()
        update = old_server.diff(server).transform(op)
        server = server.compose(update)
        old_server = server
        callback(null, server)

    assert.deepEqual(client, new Delta().insert("xxxxx-oooooooo"))
