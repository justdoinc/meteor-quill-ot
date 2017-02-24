describe "Snapshot.findShortestPathsToCommonParent", ->

  it "Should return [[parent, doc], [parent]] for child and parent", ->
    root = new Snapshot(new Delta())
    child = new Snapshot(new Delta(), root);

    assert.equal(JSON.stringify(Snapshot.findShortestPathsToCommonParent(child, root)), JSON.stringify([[root, child], [root]]))

  it "Should return the nearest parent", ->
    root = new Snapshot(new Delta())
    parent = new Snapshot(new Delta(), root);
    child = new Snapshot(new Delta(), parent);

    assert.equal(JSON.stringify(Snapshot.findShortestPathsToCommonParent(child, parent)), JSON.stringify([[parent, child], [parent]]))

  it "Should return null for unrelated documents", ->
    doc = new Snapshot(new Delta().insert("doc"))
    other = new Snapshot(new Delta().insert("other"))

    assert.equal(JSON.stringify(Snapshot.findShortestPathsToCommonParent(doc, other)), JSON.stringify(null))

  it "Should return [[root, parent, doc], [root, other, doc]] for branched children", ->
    root = new Snapshot(new Delta().insert("root"))
    parent = new Snapshot(new Delta().insert("parent"), root)
    other = new Snapshot(new Delta().insert("other"), root)
    child = new Snapshot(new Delta().insert("child"), parent);
    other_child = new Snapshot(new Delta().insert("child"), other);

    assert.equal(JSON.stringify(Snapshot.findShortestPathsToCommonParent(child, other_child)), JSON.stringify([[root, parent, child], [root, other, other_child]]))
