describe "SnapshotManager", ->
  manager = null

  beforeEach ->
    manager = new SnapshotManager()

  describe "single delta commit", ->

    expected = null
    snapshot = null

    beforeEach ->
      expected = new Delta().insert("hi")
      snapshot = manager.commit
        delta: expected

    it "should return a snapshot", ->

      assert.deepEqual(snapshot.delta, expected)

    it "get(_id) should return { delta ... }", ->
      actual = manager.get snapshot._id

      assert.deepEqual(actual.delta, expected)

    it "content(_id) should return delta", ->
      actual = manager.content snapshot._id

      assert.deepEqual(actual, expected)

    it "content(snapshot) should return delta", ->
      actual = manager.content snapshot

      assert.deepEqual(actual, expected)

  describe "multi delta commit", ->

    first_delta = null
    second_delta = null
    first_snapshot = null
    second_snapshot = null
    expected = null

    beforeEach ->
      first_delta = new Delta().insert("hi")
      second_delta = new Delta().retain(2).insert(" there")
      expected = new Delta().insert("hi").insert(" there")

      first_snapshot = manager.commit
        delta: first_delta
      second_snapshot = manager.commit
        base_id: first_snapshot._id
        delta: second_delta

    it "should return a snapshot", ->

      assert.deepEqual(first_snapshot.delta, first_delta)
      assert.deepEqual(second_snapshot.delta, second_delta)

    it "get(_id) should return { delta ... }", ->
      first_actual = manager.get first_snapshot._id
      second_actual = manager.get second_snapshot._id

      assert.deepEqual(first_actual.delta, first_delta)
      assert.deepEqual(second_actual.delta, second_delta)

    it "content(_id) should return delta", ->
      first_actual = manager.content first_snapshot._id
      second_actual = manager.content second_snapshot._id

      assert.deepEqual(first_actual, first_delta)
      assert.deepEqual(second_actual, expected)

    it "content(snapshot) should return delta", ->
      first_actual = manager.content first_snapshot
      second_actual = manager.content second_snapshot

      assert.deepEqual(first_actual, first_delta)
      assert.deepEqual(second_actual, expected)

  describe "merge()", ->

    it "root-less merge should concatenate changes", ->
      a = new Delta().insert('5')
      b = new Delta().insert('6')

      c = manager.merge({ delta: a }, { delta: b })

      assert.deepEqual(manager.content(c), new Delta().insert('56'))

    it "merge with root should correctly retain positions", ->
      root = new Delta().insert("|")
      a = new Delta().insert('a') # a|
      b = new Delta().retain(1).insert('b') # |b

      base_id = manager.commit({ delta: root })._id

      c = manager.merge({ delta: a, base_id: base_id }, { delta: b, base_id: base_id })

      assert.deepEqual(manager.content(c), new Delta().insert("a|b"))

    it "complex merge correctly maintains in-paragraph changes", ->
      root = new Delta().insert("1.\n2.\n3.")
      a = new Delta().retain(2).insert('a')
      b = new Delta().retain(5).insert('b')
      c = new Delta().retain(8).insert('c')

      base_id = manager.commit(root)._id

      d = manager.merge({ delta: a, base_id: base_id }, { delta: b, base_id: base_id })
      e = manager.merge(d, { delta: c, base_id: base_id })

      assert.deepEqual(manager.content(e), new Delta().insert("1.a\n2.b\n3.c"))

      f = manager.merge({ delta: a, base_id: base_id}, { delta: c, base_id: base_id })
      g = manager.merge(f, { delta: b, base_id: base_id })

      assert.deepEqual(manager.content(g), new Delta().insert("1.a\n2.b\n3.c"))
