_.extend DeltaMergeManager.prototype,

  getConnection: (document_id) ->

    @connections = @connections ? {}
    @connections[document_id] = @connections[document_id] ? DeltaServer.MongoConnection(@documents, document_id)

    return @connections[document_id]
