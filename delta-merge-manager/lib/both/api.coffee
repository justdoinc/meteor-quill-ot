_.extend DeltaMergeManager.prototype,

  createServer: (document_id, up) ->
    if not document_id?
      throw new Error("null-document-id")

    snapshot_id = Random.id()
    @documents.upsert document_id,
      $setOnInsert:
        snapshot:
          _id: snapshot_id
          delta: new Delta()

    if @documents.findOne
      _id: document_id
      "snapshot._id": snapshot_id

    @snapshots.upsert
      _id: snapshot_id
    ,
      $setOnInsert:
        delta: new Delta()

    document = null

    @documents.find(document_id).observeChanges
      added: (id, doc) =>
        document = doc
        document._id = id
      changed: (id, doc) =>
        if doc.snapshot?._id?
          # TODO: what to do if snapshot hasn't been committed yet?
          snapshot = connection.snapshots.get(doc.snapshot._id)
          connection.fromServer(snapshot)
      removed: (id) =>
        # TODO: destroy

    connection = new Connection(
      document.snapshot
    ,
      (base, otherSnapshots) =>
        up(base, otherSnapshots)
    ,
      (base, otherSnapshots) =>
        # 1. commit each snapshot
        _.each [base].concat(otherSnapshots or []), (snapshot) =>
          snapshot.document_id = document._id
          @snapshots.upsert snapshot._id,
           $setOnInsert: _.omit(snapshot, '_id')

        # 2. update the document
        document_snapshot =
          _id: base._id
          delta: connection.content(base)

        @documents.update document_id,
          $set:
            snapshot: document_snapshot
    )

    @snapshots.find({ document_id: document_id }).observeChanges
      added: (id, doc) =>
        doc._id = id
        connection.snapshots.commit(doc)

    return connection
