describe "DeltaMergeManager", ->
  manager = null

  beforeEach () ->
    manager = new DeltaMergeManager
      documents: new Mongo.Collection(null)
      snapshots: new Mongo.Collection(null)

  it "should insert documents that don't exist yet", ->
    original = new Snapshot(new Delta().insert("hi"))
    doc_id = manager.updateOrInsertDocument("x", original)

    doc = manager.getDocument(doc_id)

    diff = doc.snapshot.latest.diff(original.latest)
    assert.equal(diff.ops.length, 0)

  it "should persist documents", ->
    original = new Snapshot(new Delta().insert("hi"))
    doc_id = manager.createDocument(original)

    doc = manager.getDocument(doc_id)

    diff = doc.snapshot.latest.diff(original.latest)
    assert.equal(diff.ops.length, 0)

  it "should persist document changes", ->
    original = new Snapshot(new Delta().insert("hi"))
    doc_id = manager.createDocument(original)

    doc = manager.updateDocument(doc_id, original.applyDelta(new Delta().retain(2).insert(" joe")))

    assert.equal(doc.snapshot.latest.ops[0].insert, "hi joe")
