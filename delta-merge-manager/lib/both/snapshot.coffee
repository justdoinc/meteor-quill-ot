# A snapshot is { _id, base_id(s), delta }

SnapshotManager = () ->
  @_snapshots = {}

  return @

_.extend SnapshotManager.prototype,

  _commit: (snapshot) ->
    @_snapshots[snapshot._id] = snapshot

  commit: (snapshot) ->
    # commit is idempotent
    if snapshot._id? and existing = @get(snapshot._id)
      return existing

    # allow passing in just a delta
    if snapshot.ops? and not snapshot.delta
      snapshot =
        delta: snapshot

    # Get an _id
    _id = snapshot._id || Random.id()

    # clone the snapshot
    snapshot =
      _id: _id
      base_id: snapshot.base_id
      parent_ids: snapshot.parent_ids
      delta: snapshot.delta

    # Save the snapshot
    @_commit(snapshot)

    return snapshot

  _get: (snapshot_id) ->
    snapshot = @_snapshots[snapshot_id]

  get: (snapshot_id) ->
    # return the empty snapshot if no id or null id passed in
    if snapshot_id == null
      return { _id: null, delta: new Delta() }

    snapshot = @_get(snapshot_id)

    if snapshot?
      snapshot =
        _id: snapshot._id
        base_id: snapshot.base_id
        parent_ids: snapshot.parent_ids
        delta: new Delta(snapshot.delta)

    return snapshot

  content: (snapshot_or_id) ->
    if _.isString snapshot_or_id
      snapshot_or_id = @get(snapshot_or_id)

    return @squash snapshot_or_id

  # merge b into a and return the result
  merge: (a, b) ->
    a = @commit(a)
    b = @commit(b)

    parent_ids = [a._id, b._id]
    delta = @diff(a, b)

    return @commit({ base_id: a._id, parent_ids: parent_ids, delta: delta})

  diff: (a, b) ->
    base = @base(a, b)
    delta_a = @squash(a, base)
    delta_b = @squash(b, base)

    return delta_a.transform(delta_b, true)

  squash: (snapshot, base) ->
    delta = snapshot.delta

    base_id = base?._id or null
    snapshot = @get(snapshot.base_id)
    while snapshot? and snapshot._id != base_id
      delta = snapshot.delta.compose(delta)
      snapshot = @get(snapshot.base_id)

    return delta

  base: (a, b) ->
    a_parents = @parents(a)
    b_parents = @parents(b)

    shared_parent_id = null
    for parent_id, key in a_parents
      if b_parents[key] == parent_id
        shared_parent_id = parent_id

    if shared_parent_id?
      return @get(shared_parent_id)

    return null

  parents: (snapshot) ->
    parents = [snapshot._id]

    if snapshot.base_id
      return @parents(@get(snapshot.base_id)).concat(parents)

    return parents
