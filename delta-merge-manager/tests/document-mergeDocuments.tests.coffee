describe "Document.mergeDocument", ->
  it "Should merge parallel branches", ->
    original = new Document((new Delta()).insert("--|--"))

    left = original.applyDelta((new Delta()).retain(1).insert("-"))
    right = original.applyDelta((new Delta()).retain(4).insert("-"))

    left_right = original.merge(left).merge(right)
    right_left = original.merge(right).merge(left)

    diff = left_right.latest.diff(right_left.latest)
    assert.equal(diff.ops.length, 0)
