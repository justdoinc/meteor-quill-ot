Connection = (base, up, down) ->
  @toClient = up
  @toServer = down
  @snapshots = new SnapshotManager()

  @base = @snapshots.commit(base)

  @toClient(@base)

  return @

_.extend Connection.prototype,

  fromServer: (snapshot, otherSnapshots) ->

    if otherSnapshots?
      otherSnapshots = _.map otherSnapshots, (snap) => @snapshots.commit(snap)
    else
      otherSnapshots = []

    if not snapshot?
      return

    snapshot = @snapshots.commit snapshot

    # XXX if base is not parent of snapshot push new base to server

    @old_base = @base
    @base = @snapshots.merge snapshot, @base

    update =
      _id: @base._id
      base_id: @base.base_id
      parent_ids: @base.parent_ids
      # XXX dynamically decide whether to send .content or .delta,
      # .delta is more network efficient, but .content results in fewer
      # potential issues
      content: @content()

    @toClient update, [snapshot].concat(otherSnapshots)

  fromClient: (snapshot, otherSnapshots) ->
    console.log(JSON.stringify(arguments))

    if otherSnapshots?
      otherSnapshots = _.map otherSnapshots, (snap) => @snapshots.commit(snap)
    else
      otherSnapshots = []

    snapshot = @snapshots.commit snapshot

    @base = @snapshots.merge @base, snapshot

    update =
      _id: @base._id
      base_id: @base.base_id
      parent_ids: @base.parent_ids
      content: @content()

    @toServer update, [snapshot].concat(otherSnapshots)

  content: (snapshot) ->
    if snapshot?
      return @snapshots.content snapshot

    return @snapshots.content @base

  delta: (snapshot) ->
    if not snapshot?
      snapshot = @base

    return @snapshots.squash snapshot, @old_base
