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
    if snapshot.ops? and not snapshot.delta? and not snapshot.content?
      snapshot =
        content: snapshot

    # Get an _id
    _id = snapshot._id || Random.id()

    # clone the snapshot
    snapshot =
      _id: _id
      base_id: snapshot.base_id
      parent_ids: snapshot.parent_ids
      content: snapshot.content and new Delta(snapshot.content)
      delta: snapshot.delta and new Delta(snapshot.delta)

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
        delta: snapshot.delta and new Delta(snapshot.delta)
        content: snapshot.content and new Delta(snapshot.content)

    return snapshot

  content: (snapshot_or_id) ->
    if _.isString snapshot_or_id
      snapshot_or_id = @get(snapshot_or_id)

    return @squash snapshot_or_id

  # merge b into a and return the result
  merge: (a, b) ->
    a = @commit(a)
    b = @commit(b)

    if b.base_id == a._id
      return b

    if a.base_id == b._id
      return a

    if a._id == b._id
      return a

    parent_ids = [a._id, b._id]
    delta = @diff(a, b)

    return @commit({ base_id: a._id, parent_ids: parent_ids, delta: delta})

  diff: (a, b) ->
    base = @parent(a, b)

    delta_a = @squash(a, base)
    delta_b = @squash(b, base)

    return delta_a.transform(delta_b, true)

  squash: (snapshot, base) ->
    if base?
      return @squash(base).diff(@squash(snapshot))

    delta = null

    while snapshot?
      if snapshot.content?
        delta = if delta? then snapshot.content.compose(delta) else snapshot.content
        return delta

      if snapshot.delta?
        delta = if delta? then snapshot.delta.compose(delta) else snapshot.delta

      snapshot = @get(snapshot.base_id)

    return delta

  parent: (a, b) ->

    # 1. Compute the parent paths of each Snapshot
    parent_paths_a = @parents(a)
    parent_paths_b = @parents(b)

    # 2. Iterate through all paths to find the first common parent
    # we iterate backwards for efficiency
    indexes_a = _.map(parent_paths_a, (path) => path.length - 1);
    indexes_b = _.map(parent_paths_a, (path) => path.length - 1);

    # 2.1 Find the largest index in each set of paths
    index_a = -1
    for index in indexes_a
      if index > index_a
        index_a = index

    index_b = -1
    for index in indexes_b
      if index > index_b
        index_b = index

    # 2.2 Find the largest index which is found in both lists
    index = index_a
    if index_a > index_b
      index = index_b

    while index >= 0

      # Note, this algorithm assumes that all paths have a common root which is
      # the first item in each array.

      for path_a in parent_paths_a
        if path_a.length > index
          for path_b in parent_paths_b
            if path_b.length > index
              if path_a[index] == path_b[index]
                # Found common parent
                return @get(path_a[index])

      index--

    return null

  parents: (snapshot) ->
    path = [snapshot._id]

    if snapshot.parent_ids?

      # [[[base1_1, base1]], [[base2_1_1, base2_1, base2], [base2_2_1, base2_2, base2]]]
      paths = _.map snapshot.parent_ids, (base) =>
        @parents(@get(base))

      # [[base1_1, base1]], [[base2_1_1, base2_1, base2], [base2_2_1, base2_2, base2]]
      paths = _.flatten(paths, true)

    else if snapshot.base_id?

      paths = @parents(@get(snapshot.base_id))

    else

      paths = [[null]]

    return _.map(paths, (base_path) => base_path.concat(path))
