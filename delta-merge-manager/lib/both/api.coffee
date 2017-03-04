_.extend DeltaMergeManager.prototype,

  createServer: (document_id) ->
    if not document_id?
      throw new Error("null-document-id")

    connection = new Connection()
    # connection.snapshots._commit = (snapshot) =>
    #
    #   # XXX we can make this more efficient by throttling snapshot persistance
    #   # to disk, e.g. 10ms wait and then squashing snapshots
    #
    #   snapshot.document_id = document_id
    #
    #   @snapshots.upsert
    #     _id: snapshot._id
    #   ,
    #     _.omit snapshot, "_id"
    #
    #   return SnapshotManager.prototype._commit.apply(connection.snapshots, arguments)

    connection.toServer = (base) =>
      if not base?
        return

      @documents.upsert
        _id: document_id
      ,
        $set:
          snapshot:
            _id: base._id
            base_id: base.base_id
            parent_ids: base.parent_ids
            content: connection.content(base)
      , () => return

    connection.requestServerResync = (base) =>

      # TODO

      return

    # connection.toClient is intentionally left blank
    # connection.requestClientResync is intentionally left blank

    connection.start = =>

      @documents.find({_id: document_id}).observeChanges
        added: (_id, doc) ->

          connection.fromServer _.omit doc.snapshot, "base_id", "parent_ids"
      #
      #   changed: (_id, changes) ->
      #
      #     if changes.snapshot?._id
      #
      #       connection.fromServer changes.snapshot
      #
      # @snapshots.find({document_id: document_id}).observeChanges
      #   added: (_id, doc) ->
      #
      #     doc._id = _id
      #
      #     connection.fromServer null, [doc]

    return connection

  getOrCreateServer: (document_id) ->
    console.log "Created Server", new Error().stack

    if not @snapshot_managers?
      @snapshot_managers = {}
    if not @servers?
      @servers = {}

    servers = @servers[document_id] = @servers[document_id] ? []

    server = @createServer document_id
    if @snapshot_managers[document_id]?
      server.snapshots = @snapshot_managers[document_id]
    else
      @snapshot_managers[document_id] = server.snapshots

    servers.push server

    server.toClient = () =>
      args = _.toArray arguments

      _.each server?.subscriptions, (sub) =>

        sub.apply this, args

    _toServer = server.toServer

    server.toServer = (base, snapshots) =>

      for other_server in servers
        if other_server != server
          other_server.base = base
          other_server.toClient base, snapshots

    server.requestClientResync = () =>

      # XXX

    server.subscriptions = []
    server.start()

    return server
