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

    it "parallel branches should merge correctly", ->
      base = manager.commit({ delta: new Delta().insert("|") })

      a = manager.merge(base, { base_id: base._id, delta: new Delta().insert("a") })
      b = manager.merge(a, { base_id: a._id, delta: new Delta().retain(1).insert("b") })

      c = manager.merge(base, { base_id: base._id, delta: new Delta().retain(1).insert("c")})
      d = manager.merge(c, { base_id: c._id, delta: new Delta().retain(2).insert("d")})


      final = manager.merge(b, d)

      assert.deepEqual(manager.content(final), new Delta().insert("ab|cd"))

    it "parallel branches should merge correctly in odd orders", ->
      base = manager.commit({ delta: new Delta().insert("|") })

      a = manager.merge(base, { base_id: base._id, delta: new Delta().insert("a") })
      b = manager.merge(a, { base_id: a._id, delta: new Delta().retain(1).insert("b") })

      c = manager.merge(base, { base_id: base._id, delta: new Delta().retain(1).insert("c")})
      d = manager.merge(c, { base_id: c._id, delta: new Delta().retain(2).insert("d")})

      final = manager.merge(manager.merge(d, a), b)

      assert.deepEqual(manager.content(final), new Delta().insert("ab|cd"))

    it "should not update a delta when merging in the base", ->
      base = manager.commit({ delta: new Delta().insert("|") })

      a = manager.merge(base, { base_id: base._id, delta: new Delta().insert("a") })
      b = manager.merge(a, { base_id: a._id, delta: new Delta().retain(1).insert("b") })

      c = manager.merge(b, a)
      d = manager.merge(c, a)

      assert.deepEqual(manager.content(b), manager.content(c))

    it "should not update a delta when merging in a parent", ->
      base = manager.commit({ delta: new Delta().insert("|") })

      a = manager.merge(base, { base_id: base._id, delta: new Delta().insert("a") })
      b = manager.merge(a, { base_id: a._id, delta: new Delta().retain(1).insert("b") })

      c = manager.merge(b, { base_id: a._id, delta: new Delta().retain(2).insert("c") })
      d = manager.merge(c, a)

      assert.deepEqual(manager.content(c), manager.content(d))

    it "repeat merging of snapshots from parallel branches should not create duplicate content", ->
      base = manager.commit({ delta: new Delta().insert("|") })

      # Fake client
      a = manager.merge(base, { base_id: base._id, delta: new Delta().insert("a") })
      b = manager.merge(a, { base_id: a._id, delta: new Delta().retain(1).insert("b") })

      # Fake server
      c = manager.merge(base, { base_id: base._id, delta: new Delta().retain(1).insert("c")})
      d = manager.merge(c, { base_id: c._id, delta: new Delta().retain(2).insert("d")})

      # Merge server into client
      e = manager.merge(c, b)
      f = manager.merge(d, e)

      # Merge original client snaps into server
      g = manager.merge(d, a)
      h = manager.merge(g, b)

      # Merge subsequent client snaps into server
      i = manager.merge(h, e)
      j = manager.merge(i, f)


      # check all snaps are full merges (descend from all of a, b, c, d)
      # and check that they match (the first full merge)
      _.each [h, i, j], (snap) =>

        assert.deepEqual(manager.content(f), manager.content(snap))

    it "throws a readable error when attempting to merge snapshots with missing intermediate snapshots", ->
      base = manager.commit({ delta: new Delta().insert("|") })

      # Broken merge
      try

        manager.merge(base, { delta: new Delta().insert("a"), base_id: "xyz" })

        assert.fail()

      catch error

        assert.match error.message, /missing snapshots/i
        assert.equal error.code, "missing-snapshots"

  describe "content()", ->

    it "should prefer .content over .delta", ->

      c = manager.commit { delta: new Delta().insert("y"), content: new Delta().insert("x") }

      assert.deepEqual manager.content(c), new Delta().insert("x")
