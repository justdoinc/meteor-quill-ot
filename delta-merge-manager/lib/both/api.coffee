_.extend DeltaMergeManager.prototype,

  createDocument: (snapshot) ->
    @snapshots.insert(snapshot.toJSON())

    return @documents.insert({
      snapshot_id: snapshot._id
    });

  updateDocument: (document_id, snapshot) ->
    current_id = @documents.findOne({ _id: document_id })?.snapshot_id

    current = Snapshot.fromJSON(@snapshots.findOne({ _id: current_id }))

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

    result = Snapshot.fromJSON(snapshot)

    _.extend(result, document)

    return result
