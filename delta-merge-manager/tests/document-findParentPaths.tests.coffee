describe "Document.findParentPaths", ->

  it "Should return [[doc]] for root documents", ->
    root = new Document(new Delta())

    assert.equal(JSON.stringify(Document.findParentPaths(root)), JSON.stringify([[root]]))

  it "Should return [[doc, parent]] for first child", ->
    root = new Document(new Delta())
    child = new Document(new Delta(), root);

    assert.equal(JSON.stringify(Document.findParentPaths(child)), JSON.stringify([[root, child]]))

  it "Should return [[doc, parent], [doc, otherParent]] for multi-parent document", ->
    root = new Document(new Delta().insert("root"))
    other = new Document(new Delta().insert("other"))
    child = new Document(new Delta().insert("child"), [root, other]);

    assert.equal(JSON.stringify(Document.findParentPaths(child)), JSON.stringify([[root, child], [other, child]]))

  it "Should return [[doc, parent, root], [doc, otherParent, root]] for diamond shaped history", ->
    root = new Document(new Delta().insert("root"))
    parent = new Document(new Delta().insert("parent"), root)
    other = new Document(new Delta().insert("other"), root)
    child = new Document(new Delta().insert("child"), [parent, other]);

    assert.equal(JSON.stringify(Document.findParentPaths(child)), JSON.stringify([[root, parent, child], [root, other, child]]))
