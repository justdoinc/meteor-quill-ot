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

  it "should handle torture test", ->
    other_manager = DeltaServer.MongoConnection(store, "doc")
    other_client_id = other_manager.connect()[0]
    other_client = other_manager.fromClient(other_client_id, new Delta())

    expected = "-"
    client = manager.fromClient(client_id, new Delta().insert("-"))

    # Flush changes to both clients
    client = manager.fromClient(client_id, new Delta())
    other_client = other_manager.fromClient(other_client_id, new Delta())
    client = manager.fromClient(client_id, new Delta())
    other_client = other_manager.fromClient(other_client_id, new Delta())

    # On the server introduce an arbitrary delay to simulate netowrk issues
    # we can't do this on the client because we don't have fibers/futures
    if Meteor.isServer
      _running = false
      _toServer = manager.toServer
      manager.toServer = (args...) ->
        if _running
          return _toServer.apply manager, args
        Meteor.setTimeout () =>
          _running = true
          _toServer.apply manager, args
          _running = false
          console.log 'done'
        , 1

      _otherRunning = false
      _otherToServer = other_manager.toServer
      other_manager.toServer = (args...) ->
        if _otherRunning
          return _otherToServer.apply other_manager, args
        Meteor.setTimeout () =>
          _otherRunning = true
          _otherToServer.apply other_manager, args
          _otherRunning = false
        , 2



    for i in [0...100]

      if i % 2 == 0
        # insert x into the beginning of the stream
        client = manager.fromClient(client_id, new Delta().insert('x'))
        expected = "x" + expected

      if i % 3 == 0
        length = other_client.ops[0]?.insert?.length ? 0
        other_client = other_manager.fromClient(other_client_id, new Delta().retain(length).insert('o'))
        expected = expected + "o"

    # Flush both client changes to ensure clients are up to date
    client = manager.fromClient(client_id, new Delta())
    other_client = other_manager.fromClient(other_client_id, new Delta())

    if Meteor.isServer
      # Turn off the delay
      other_manager.toServer = _otherToServer
      manager.toServer = _toServer

    # Be sure that all server operations have completed
    if Meteor.isServer
      sleep = Meteor.wrapAsync (cb) =>
        Meteor.setTimeout () =>
          cb()
        , 5
      sleep()

    # Flush both client changes to ensure clients are up to date
    client = manager.fromClient(client_id, new Delta())
    other_client = other_manager.fromClient(other_client_id, new Delta())
    client = manager.fromClient(client_id, new Delta())
    other_client = other_manager.fromClient(other_client_id, new Delta())
    client = manager.fromClient(client_id, new Delta())

    assert.deepEqual(new Delta(client).diff(new Delta().insert(expected)) + '', new Delta() + '')
    assert.deepEqual(new Delta(other_client).diff(new Delta().insert(expected)) + '', new Delta() + '')
