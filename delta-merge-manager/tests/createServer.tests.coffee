describe "createServer", ->
  manager = null
  connection = null

  beforeEach ->
    manager = new DeltaMergeManager
      documents: new Mongo.Collection null
      snapshots: new Mongo.Collection null
      messages_collection_name: null

    connection = manager.createServer "document"
    connection.toClient = () => return
    connection.requestClientResync = () => return
    connection.start()

  it "should return a connection", ->

    assert.instanceOf(connection, Connection)

  it "should accept changes", ->

    connection.fromClient({ base_id: null, delta: new Delta().insert('hi') })

    assert.deepEqual(connection.content(), new Delta().insert('hi'))

  it "should persist changes", ->

    connection.fromClient({ base_id: null, delta: new Delta().insert('hi') })

    # Re-create the server
    connection = manager.createServer "document"
    connection.toClient = () => return
    connection.requestClientResync = () => return
    connection.start()

    assert.deepEqual(connection.content(), new Delta().insert('hi'))

  it "should handle changes from other servers", ->

    other_connection = manager.createServer "document"
    other_connection.toClient = () => return
    other_connection.requestClientResync = () => return
    other_connection.start()

    other_connection.fromClient({ base_id: null, delta: new Delta().insert('hi') })

    assert.deepEqual(connection.content(), new Delta().insert('hi'))

  it "complex test", ->

    other_connection = manager.createServer "document"
    other_connection.toClient = () => return
    other_connection.requestClientResync = () => return
    other_connection.start()

    other_connection.fromClient({ base_id: null, delta: new Delta().insert('hi') })
    other_connection.fromClient({ base_id: other_connection.base._id, delta: new Delta().retain(2).insert(' sam') })

    connection.fromClient({ base_id: connection.base._id, delta: new Delta().insert('hello joe\n') })

    assert.deepEqual(other_connection.content(), new Delta().insert('hello joe\nhi sam'))
    assert.deepEqual(connection.content(), new Delta().insert('hello joe\nhi sam'))

  for i in [0..100]
    it "preformance test #{i}", ->

      for ii in [0..100]

        connection.fromClient({ base_id: connection.base?._id, delta: new Delta().insert("-") })

      assert.deepEqual(connection.content(), new Delta().insert([0..100].map(() => "-").join("")))
