describe "Document.applyDelta", ->

  it "Should apply a plain delta", ->
    original = new Document(new Delta())

    original = original.applyDelta((new Delta()).insert("hi"))

    diff = (new Delta()).insert("hi").diff(original.current)
    assert.equal(diff.ops.length, 0)
