describe "DeltaServer.MongoConnection", ->

  store = null
  manager = null
  client_id = null
  beforeEach ->
    store = new Mongo.Collection(null)
    manager = DeltaServer.MongoConnection(store, "doc")
    client_id = manager.connect()[0]

  it "should initialize an empty document", ->
    manager.fromClient(client_id, new Delta())

    assert.equal store.find().count(), 1

  it "should accept and process client updates", ->
    client = manager.fromClient(client_id, new Delta())
    client = manager.fromClient(client_id, new Delta().insert("hi"))
    client = manager.fromClient(client_id, new Delta().retain("hi".length).insert(" there"))
    client = manager.fromClient(client_id, new Delta().retain("hi there".length).insert(", Joe!"))

    assert.deepEqual(client, new Delta().insert("hi there, Joe!"))

  it "should persist changes accross connections", ->
    client = manager.fromClient(client_id, new Delta())
    client = manager.fromClient(client_id, new Delta().insert("hi"))
    client = manager.fromClient(client_id, new Delta().retain("hi".length).insert(" there"))
    client = manager.fromClient(client_id, new Delta().retain("hi there".length).insert(", Joe!"))

    manager = DeltaServer.MongoConnection(store, "doc")
    client_id = manager.connect()[0]
    client = manager.fromClient(client_id, new Delta())

    assert.deepEqual(client, new Delta().insert("hi there, Joe!"))

  it "should handle multiple simultaneous connections", ->
    other_manager = DeltaServer.MongoConnection(store, "doc")
    other_client_id = other_manager.connect()[0]
    other_client = other_manager.fromClient(other_client_id, new Delta())

    c = => client.ops[0].length ? 0

    client = manager.fromClient(client_id, new Delta().insert("xx"))
    other_client = other_manager.fromClient(other_client_id, new Delta().insert("oo"))
    client = manager.fromClient(client_id, new Delta().retain(c()).insert("xx"))
    other_client = other_manager.fromClient(other_client_id, new Delta().insert("oo"))
    client = manager.fromClient(client_id, new Delta().retain(c()).insert("xx"))
    other_client = other_manager.fromClient(other_client_id, new Delta().insert("oo"))

    # A few extra round trips are required to cross the db boundary
    client = manager.fromClient(client_id, new Delta())
    client = manager.fromClient(client_id, new Delta())
    other_client = other_manager.fromClient(other_client_id, new Delta())

    assert.deepEqual(client, new Delta().insert("ooooooxxxxxx"))
    assert.deepEqual(other_client, new Delta().insert("ooooooxxxxxx"))
