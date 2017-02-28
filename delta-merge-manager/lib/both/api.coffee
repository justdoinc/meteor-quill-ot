_.extend DeltaMergeManager.prototype,

  createDocument: (snapshot) ->
    @snapshots.insert(snapshot.toJSON())

    return @documents.insert({
      snapshot_id: snapshot._id
    });

  updateOrInsertDocument: (document_id, snapshot) ->
    document = @documents.findOne
      _id: document_id

    if not document?
      parent = new Snapshot(new Delta())
      @snapshots.insert parent.toJSON()
      @documents.insert
        _id: document_id
        snapshot_id: parent._id

    @updateDocument(document_id, snapshot)


  updateDocument: (document_id, snapshot) ->
    document = @documents.findOne
      _id: document_id

    current_id = document.snapshot_id

    current = Snapshot.fromJSON(@snapshots.findOne({ _id: current_id }))

    console.log("\n\n");
    console.log(_.map(snapshot.parent_paths, (p) -> _.map(p, (pp) -> pp._id)))
    console.log(_.map(current.parent_paths, (p) -> _.map(p, (pp) -> pp._id)))
    console.log("\n\n");

    updated = Snapshot.mergeSnapshots(current, snapshot, (id) => @snapshots.findOne({ _id: id }))

    snapshot_id = @snapshots.insert(updated.toJSON(updated))

    # TODO handle case where update failed because another update succeeded first
    @documents.update
      snapshot_id: current_id
    ,
      snapshot_id: updated._id

    return @getDocument(document_id)

  getDocument: (document_id) ->
    document = @documents.findOne({ _id: document_id })

    if not document?
      return null

    snapshot = @snapshots.findOne({ _id: document.snapshot_id })

    result =
      snapshot: Snapshot.fromJSON(snapshot)
      document: document

    return result
