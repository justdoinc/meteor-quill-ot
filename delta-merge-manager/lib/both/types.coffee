Snapshot = (delta, base) ->
  @id = Snapshot.next_id++

  if base?
    @base = base
  else
    @base = null

  @latest = delta
  @parent_paths = Snapshot.findParentPaths(@)

  return @

_.extend Snapshot.prototype,

  applyDelta: (delta) ->

    return new Snapshot(@latest.compose(delta), @)

  merge: (document, apply_first) ->
    if apply_first?
      return Snapshot.mergeSnapshots(@, document)
    else
      return Snapshot.mergeSnapshots(document, @)

  toJSON: () ->

    json =
      id: @id
      latest: @latest
      parents: _.map(@parent_paths, (path) => _.pluck(path, 'id'))

    return json

  fromJSON: (doc) ->

    snapshot = new Snapshot(new Delta(doc.latest))
    snapshot.parent_paths = _.map(doc.parents, (path) => _.map(path, (id) => { id: id }))

    return snapshot

_.extend Snapshot,
  next_id: 0
  mergeSnapshots: (a, b) ->

    parent = @findCommonParent a, b

    # TODO allow looking up parent by id

    if not parent?

      throw new Error "no-common-parent"

    # If the high_priority snapshot is also the parent, just do a fast-forward
    # merge
    if parent.id == a.id
      return b

    # 1. Flatten each delta
    diff_a = parent.latest.diff(a.latest)
    diff_b = parent.latest.diff(b.latest)

    # 2. Transform diff_b against diff_a
    merge_ops = diff_a.transform(diff_b)

    return new Snapshot(a.latest.compose(merge_ops), [a, b])

  findCommonParent: (a, b) ->

    paths = Snapshot.findShortestPathsToCommonParent(a, b)

    parent = paths?[0]?[0]

    return parent

  findShortestPathsToCommonParent: (a, b) ->

    # 1. Compute the parent paths of each Snapshot
    parent_paths_a = a.parent_paths
    parent_paths_b = b.parent_paths

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
              if path_a[index].id == path_b[index].id
                # Found common parent
                return [path_a.slice(index), path_b.slice(index)]

      index--

    return null

  findParentPaths: (document) ->
    path = [document]

    if _.isArray(document.base)

      # [[[base1_1, base1]], [[base2_1_1, base2_1, base2], [base2_2_1, base2_2, base2]]]
      paths = _.map(document.base, (base) => Snapshot.findParentPaths(base))

      # [[base1_1, base1]], [[base2_1_1, base2_1, base2], [base2_2_1, base2_2, base2]]
      paths = _.flatten(paths, true)

    else if document.base?

      paths = Snapshot.findParentPaths(document.base)

    else

      paths = [[]]

    return _.map(paths, (base_path) => base_path.concat(path))
