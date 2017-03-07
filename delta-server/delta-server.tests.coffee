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
    manager.toServer = (update) ->
      return new Delta().insert("hey there")
    manager.submitChanges(client_id)

    client = manager.fromClient(client_id, new Delta().retain(8).insert(", Joe!"))

    assert.deepEqual(client, new Delta().insert("hey there, Joe!"))
