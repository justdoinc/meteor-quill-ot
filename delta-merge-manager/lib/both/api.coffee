_.extend DeltaMergeManager.prototype,

  createServer: (document_id, up) ->
    if not document_id?
      throw new Error("null-document-id")

    snapshot_id = Random.id()
    @documents.upsert document_id,
      $setOnInsert:
        snapshot:
          _id: null
          content: new Delta()

    document = null

    @documents.find(document_id).observeChanges
      added: (id, doc) =>
        document = doc
        document._id = id
      changed: (id, doc) =>
        if doc.snapshot?._id?
          connection.queue.push(doc.snapshot)

          connection.dequeue()
      removed: (id) =>
        # TODO: destroy

    connection = new Connection(
      document.snapshot
    ,
      (base, otherSnapshots) =>
        up(base, otherSnapshots)
    ,
      (base, otherSnapshots) =>
        # update the document
        document_snapshot =
          _id: base._id
          content: connection.content(base)

        @documents.update document_id,
          $set:
            snapshot: document_snapshot
    )
    connection.queue = []
    connection.dequeue = () =>
      temp_queue = connection.queue;
      connection.queue = []

      temp_queue = _.filter temp_queue, (snapshot) =>

        # TODO: what to do if snapshot hasn't been committed yet?
        snapshot = connection.snapshots.get(snapshot._id)

        if not snapshot?
          return true

        connection.fromServer(snapshot)
        return false

      connection.queue = temp_queue.concat(connection.queue)

    _commit = connection.snapshots._commit
    connection.snapshots._commit = (snapshot) =>
      _commit.call(connection.snapshots, snapshot)

      snapshot.document_id = document_id

      connection.fromServer(null, [snapshot])

      @snapshots.upsert snapshot._id,
        $setOnInsert: _.omit snapshot, "_id"

    @snapshots.find({ document_id: document_id }).observeChanges
      added: (id, doc) =>
        doc._id = id
        snapshot = connection.snapshots.commit(doc)
        connection.dequeue()

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
