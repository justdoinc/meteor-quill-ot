describe "Document.findShortestPathsToCommonParent", ->

  it "Should return [[parent, doc], [parent]] for child and parent", ->
    root = new Document(new Delta())
    child = new Document(new Delta(), root);

    assert.equal(JSON.stringify(Document.findShortestPathsToCommonParent(child, root)), JSON.stringify([[root, child], [root]]))

  it "Should return the nearest parent", ->
    root = new Document(new Delta())
    parent = new Document(new Delta(), root);
    child = new Document(new Delta(), parent);

    assert.equal(JSON.stringify(Document.findShortestPathsToCommonParent(child, parent)), JSON.stringify([[parent, child], [parent]]))

  it "Should return null for unrelated documents", ->
    doc = new Document(new Delta().insert("doc"))
    other = new Document(new Delta().insert("other"))

    assert.equal(JSON.stringify(Document.findShortestPathsToCommonParent(doc, other)), JSON.stringify(null))

  it "Should return [[root, parent, doc], [root, other, doc]] for branched children", ->
    root = new Document(new Delta().insert("root"))
    parent = new Document(new Delta().insert("parent"), root)
    other = new Document(new Delta().insert("other"), root)
    child = new Document(new Delta().insert("child"), parent);
    other_child = new Document(new Delta().insert("child"), other);

    assert.equal(JSON.stringify(Document.findShortestPathsToCommonParent(child, other_child)), JSON.stringify([[root, parent, child], [root, other, other_child]]))
