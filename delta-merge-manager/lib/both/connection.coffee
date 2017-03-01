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

    snapshot = @snapshots.commit snapshot

    # XXX if base is not parent of snapshot push new base to server

    @base = @snapshots.merge snapshot, @base

    @toClient @base, [snapshot].concat(otherSnapshots)

  fromClient: (snapshot, otherSnapshots) ->

    if otherSnapshots?
      otherSnapshots = _.map otherSnapshots, (snap) => @snapshots.commit(snap)
    else
      otherSnapshots = []

    snapshot = @snapshots.commit snapshot

    @base = @snapshots.merge @base, snapshot

    @toServer @base, [snapshot].concat(otherSnapshots)

  content: () ->

    return @snapshots.content(@base)
