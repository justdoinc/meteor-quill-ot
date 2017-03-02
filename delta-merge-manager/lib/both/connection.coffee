Connection = () ->

  @snapshots = new SnapshotManager()

  @server_queue = []
  @client_queue = []

  return @

_.extend Connection.prototype,

  fromServer: (base, snapshots, is_retry) ->

    queue = @beginCaptureSnapshots()

    try
      if snapshots?
        _.each snapshots, (snapshot) =>
          @snapshots.commit snapshot

      if base?
        if @base

          # Try to merge the snapshot, this may not always succeed since
          # sometimes there may be missing intermediate snapshots
          try
            @base = @snapshots.merge(base, @base)

          catch error

            # If the error is missing-snapshots we're missing snapshots that
            # should have been sent from the server, we'll push the base
            # to a queue and request a requestServerResync
            if error.code == "missing-snapshots"
              @server_queue.push base
              @requestServerResync @base
            else
              throw error

        else
          @base = @snapshots.commit(base)

    finally

      @stopCaptureSnapshots(queue)

    # All snapshots need to be sent to the client
    to_client_snapshots = queue

    # The base is always sent to the client, if it was updated at all
    to_client_base = if base? then @base else null

    if to_client_base? or to_client_snapshots.length > 0

      @toClient(to_client_base, to_client_snapshots)

    # Only snapshots created in the merge need to be sent to the server
    # this could include the current @base
    to_server_snapshots = @unsentSnapshots queue, (snapshots ? []).concat([base])

    # We send the updated base to the server if this was not a fast-forward
    # merge
    to_server_base = if base? and base._id != @base._id then @base else null

    if to_server_base? or to_server_snapshots.length > 0

      @toServer(to_server_base, to_server_snapshots)

    unless is_retry

      @retryServerMessages()

  fromClient: (base, snapshots, is_retry) ->

    queue = @beginCaptureSnapshots()

    try
      if snapshots?
        _.each snapshots, (snapshot) =>
          @snapshots.commit snapshot

      if base?
        if @base

          # Try to merge the snapshot, this may not always succeed since
          # sometimes there may be missing intermediate snapshots
          try
            @base = @snapshots.merge(@base, base)

          catch error

            # If the error is missing-snapshots we're missing snapshots that
            # should have been sent from the server, we'll push the base
            # to a queue and request a requestServerResync
            if error.code == "missing-snapshots"
              @client_queue.push base
              @requestClientResync @base
            else
              throw error
        else
          # This could theortically also happen when intermediate snapshots are
          # missing, but no error should be thrown until we call .content() or
          # .merge()

          @base = @snapshots.commit(base)

    finally

      @stopCaptureSnapshots(queue)

    # All snapshots need to be sent to the client
    to_server_snapshots = queue

    # The base is always sent to the client, if it was updated at all
    to_server_base = if base? then @base else null

    if to_server_base? or to_server_snapshots.length > 0

      @toServer(to_server_base, to_server_snapshots)

    # Only snapshots created in the merge need to be sent to the server
    # this could include the current @base
    to_client_snapshots = @unsentSnapshots queue, (snapshots ? []).concat([base])

    # We send the updated base to the server if this was not a fast-forward
    # merge
    to_client_base = if base? and base._id != @base._id then @base else null

    if to_client_base? or to_client_snapshots.length > 0

      @toClient(to_client_base, to_client_snapshots)

    unless is_retry

      @retryClientMessages()

  retryServerMessages: () ->

    max = @server_queue.length
    i = 0

    # Avoid infinite loop, because fromServer may push the item back on the
    # queue and we don't want it to exist twice
    while i < max
      i += 1

      @fromServer(@server_queue.shift(), null, true)

  retryClientMessages: () ->

    max = @client_queue.length
    i = 0

    # Avoid infinite loop, because fromServer may push the item back on the
    # queue and we don't want it to exist twice
    while i < max
      i += 1

      @fromClient(@client_queue.shift(), null, true)

  resyncClient: (base, toClient) ->
    toClient = toClient ? => @toClient.apply @, arguments

    toClient
      _id: @base._id
      base_id: @base.base_id
      parent_ids: @base.parent_ids
      content: @snapshots.content(@base)
    ,
      @findMissingSnapshots base

  resyncServer: (base, toServer) ->
    toServer = toServer ? => @toServer.apply @, arguments

    toServer
      _id: @base._id
      base_id: @base.base_id
      parent_ids: @base.parent_ids
      content: @snapshots.content(@base)
    ,
      @findMissingSnapshots base

  toClient: () -> console.warn("Did you forget to attach the toClient callback?")

  toServer: () -> console.warn("Did you forget to attach the toServer callback?")

  requestServerResync: () -> console.warn("Did you forget to attach the requestServerResync callback?")

  requestClientResync: () -> console.warn("Did you forget to attach the requestClientResync callback?")

  beginCaptureSnapshots: () ->
    queue = []

    queue._commit = @snapshots._commit

    @snapshots._commit = (snapshot) =>
      queue.push(snapshot)
      queue._commit.apply @snapshots, arguments

    return queue

  stopCaptureSnapshots: (queue) ->

    @snapshots._commit = queue._commit

  findMissingSnapshots: (base) ->

    own_snapshots = @snapshots.parents(@base)

    other_snapshots = []

    # Use a try catch because we may not have all the parent snapshots for
    # the remote base

    # TODO: add ability of 'parents' to return partial results for better
    #       efficiency.
    if base?
      try
          other_snapshots = @snapshots.parents(base)
      catch error
        unless error.code == "missing-snapshots"
          throw error

        # NOTE: We silently ingore error if code == "missing-snapshots"

        # Alternately we could request a resync, but we probably already did and
        # that could create a circular reference.

    # snapshot lists need to be flat and unique
    own_snapshots = _.flatten own_snapshots
    own_snapshots = _.uniq own_snapshots

    other_snapshots = _.flatten other_snapshots
    other_snapshots = _.uniq other_snapshots

    return @unsentSnapshots own_snapshots, other_snapshots

  unsentSnapshots: (snapshots, sent_snapshots) ->

    unsent_snapshots = []
    sent_snapshots = _.map sent_snapshots, (snap) =>
      if _.isString snap
        return snap
      return snap?._id

    for snapshot in snapshots

      if _.isString snapshot
        snapshot = @snapshots.get(snapshot)

      if snapshot? and not _.any(sent_snapshots, (s) => s == snapshot._id)
        unsent_snapshots.push snapshot

    return unsent_snapshots

  # Convenience Methods
  content: (snapshot) ->

    snapshot = snapshot ? @base

    return @snapshots.content snapshot
