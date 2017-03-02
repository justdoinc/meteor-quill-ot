_.extend DeltaMergeManager.prototype,

  createServer: (document_id) ->
    if not document_id?
      throw new Error("null-document-id")

    connection = new Connection()
    connection.snapshots._commit = (snapshot) =>

      # XXX we can make this more efficient by throttling snapshot persistance
      # to disk, e.g. 10ms wait and then squashing snapshots

      @snapshots.upsert
        _id: snapshot._id
      ,
        _.omit snapshot, "_id"

      return SnapshotManager.prototype._commit.apply(connection.snapshots, arguments)

    connection.toServer = (base) =>

      @documents.upsert
        _id: document_id
      ,
        $set:
          snapshot:
            _id: base._id
            base_id: base.base_id
            parent_ids: base.parent_ids
            content: connection.content(base)

    connection.requestServerResync = (base) =>

      # TODO

      return

    # connection.toClient is intentionally left blank

    connection.start = =>

      @documents.find({_id: document_id}).observeChanges
        added: (_id, doc) ->

          connection.fromServer doc.snapshot

        changed: (_id, changes) ->

          if changes.snapshot?._id

            connection.fromServer changes.snapshot

      @snapshots.find({_id: document_id}).observeChanges
        added: (_id, doc) ->

          doc._id = _id

          connection.fromServer null, [doc]

    return connection

  getOrCreateServer: (document_id) ->
    if not @servers?

      @servers = {}

    if @servers[document_id]?

      return @servers[document_id]

    server = @createServer document_id, () =>
      args = _.toArray arguments

      _.each server?.subscriptions, (sub) =>

        sub.apply this, args

    server.subscriptions = []

    return (@servers[document_id] = server)
