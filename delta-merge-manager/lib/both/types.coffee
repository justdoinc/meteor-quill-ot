Document = (delta, base) ->
  @id = Document.next_id++

  if base?
    @base = base
  else
    @base = null

  @latest = delta

  return @

_.extend Document.prototype,

  applyDelta: (delta) ->

    return new Document(@latest.compose(delta), @)

  merge: (document) ->

    paths = Document.findShortestPathsToCommonParent(@, document)

    if paths == null
      throw new Error "No common parent."

    [path_a, path_b] = paths

    # If the common parent is us, do a fast forward merge
    if path_a[0] == @
      return document

    # 1. Flatten each delta
    diff_a = path_a[0].latest.diff(@latest)
    diff_b = path_b[0].latest.diff(document.latest)

    # 2. Transform diff_b against diff_a
    merge_ops = diff_a.transform(diff_b)

    return new Document(@latest.compose(merge_ops), [@, document])

_.extend Document,
  next_id: 0
  findShortestPathsToCommonParent: (a, b) ->

    # 1. Compute the parent paths of each Document
    parent_paths_a = @findParentPaths(a)
    parent_paths_b = @findParentPaths(b)

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
      paths = _.map(document.base, (base) => Document.findParentPaths(base))

      # [[base1_1, base1]], [[base2_1_1, base2_1, base2], [base2_2_1, base2_2, base2]]
      paths = _.flatten(paths, true)

    else if document.base?

      paths = Document.findParentPaths(document.base)

    else

      paths = [[]]

    return _.map(paths, (base_path) => base_path.concat(path))
