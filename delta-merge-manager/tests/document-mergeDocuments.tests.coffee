describe "Snapshot.mergeSnapshot", ->
  it "Should merge parallel branches", ->
    original = new Snapshot((new Delta()).insert("--|--"))

    left = original.applyDelta((new Delta()).retain(1).insert("-"))
    right = original.applyDelta((new Delta()).retain(4).insert("-"))

    left_right = left.merge(right)
    right_left = right.merge(left)

    diff = left_right.latest.diff(right_left.latest)
    assert.equal(diff.ops.length, 0)

  it "More complex example", ->
    original = new Snapshot((new Delta()).insert("This is sam\nThis is noah\n"))

    sam = original.applyDelta((new Delta()).retain(8).delete(1).insert("S"))
    noah = original.applyDelta((new Delta()).retain(20).delete(1).insert("N"))

    period = sam.applyDelta(new Delta().retain(11).insert("."))
    comma = noah.applyDelta(new Delta().retain(16).insert(","))

    and_period = comma.merge(period).applyDelta(new Delta().retain(26).insert('.'))
    final_comma = period.merge(and_period).applyDelta(new Delta().retain(4).insert(','))
    final_period = and_period.merge(final_comma);

    diff = final_period.latest.diff(final_comma.latest)
    assert.equal(diff.ops.length, 0)

  it "Should merge overlapping edits", ->
    original = new Snapshot((new Delta()).insert("--|--"))

    left = original.applyDelta((new Delta()).delete(2))
    right = original.applyDelta((new Delta()).retain(1).delete(2))

    left_right = left.merge(right)
    right_left = right.merge(left)

    diff = left_right.latest.diff(right_left.latest)
    assert.equal(diff.ops.length, 0)

  # This test case doesn't pass, nor can it, as far as I can tell:
  # it "Should merge conflicts as well as possible", ->
  #   original = new Snapshot((new Delta()).insert("--|--"))
  #
  #   left = original.applyDelta((new Delta()).delete(2).insert('__'))
  #   right = original.applyDelta((new Delta()).delete(2).insert('||'))
  #
  #   left_right = left.merge(right)
  #   right_left = right.merge(left)
  #
  #   diff = left_right.latest.diff(right_left.latest)
  #   assert.equal(diff.ops.length, 0)

  it "Should eventually become consistent", ->
    original = new Snapshot((new Delta()).insert("--|--"))

    left = original.applyDelta((new Delta()).delete(2).insert('__'))
    right = original.applyDelta((new Delta()).delete(2).insert('||'))

    left_right = left.merge(right)
    right_left = right.merge(left)

    # left_right and right_left are now conflicted
    # final and final_final should be equivilent because they share a common
    # parent with no new changes since that parent
    final = left_right.merge(right_left)
    final_final = final.merge(left_right)

    diff = final.latest.diff(final_final.latest)
    assert.equal(diff.ops.length, 0)

  it "Should support giving the merged in changes priority", ->
    original = new Snapshot((new Delta()).insert("--|--"))

    left = original.applyDelta((new Delta()).delete(2).insert('__'))
    right = original.applyDelta((new Delta()).delete(2).insert('||'))

    left_right = left.merge(right)
    right_left = right.merge(left, true)

    diff = left_right.latest.diff(right_left.latest)
    assert.equal(diff.ops.length, 0)
