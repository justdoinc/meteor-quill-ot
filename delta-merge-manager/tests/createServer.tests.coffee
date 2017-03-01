describe "createServer", ->
  manager = null

  beforeEach ->
    manager = new DeltaMergeManager
      documents: new Mongo.Collection null
      snapshots: new Mongo.Collection null

  it "should return a connection", ->

    connection = manager.createServer "document", () -> return

    assert.instanceOf(connection, Connection)

  it "should publish an initial snapshot (empty delta for non-existant documents)", ->
    initial_doc = null
    connection = manager.createServer "document", (base) -> initial_doc = base

    assert.deepEqual(initial_doc.delta, new Delta())

  it "should accept changes", ->
    doc = null
    connection = manager.createServer "document", (base) -> doc = base

    connection.fromClient({ base_id: doc._id, delta: new Delta().insert('hi') })

    assert.deepEqual(connection.content(), new Delta().insert('hi'))

  it "should persist changes", ->
    doc = null
    connection = manager.createServer "document", (base) -> doc = base

    connection.fromClient({ base_id: doc._id, delta: new Delta().insert('hi') })

    connection = manager.createServer "document", (base) -> doc = base

    assert.deepEqual(connection.content(), new Delta().insert('hi'))

  it "should handle changes from other servers", ->
    doc = null
    connection = manager.createServer "document", (base) -> doc = base

    other_connection = manager.createServer "document", () -> return
    other_connection.fromClient({ base_id: doc._id, delta: new Delta().insert('hi') })

    assert.deepEqual(doc.delta, new Delta().insert('hi'))

  it "complex test", ->
    doc = null
    connection = manager.createServer "document", (base) -> doc = base

    other_connection = manager.createServer "document", () -> return
    other_connection.fromClient({ base_id: doc._id, delta: new Delta().insert('hi') })
    other_connection.fromClient({ base_id: other_connection.base._id, delta: new Delta().retain(2).insert(' sam') })

    connection.fromClient({ base_id: doc._id, delta: new Delta().insert('hello joe\n') })

    assert.deepEqual(connection.content(), new Delta().insert('hello joe\nhi sam'))
