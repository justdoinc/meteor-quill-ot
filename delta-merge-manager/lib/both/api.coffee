_.extend DeltaMergeManager.prototype,

  createConnection: (document_id) ->

    connection = DeltaServer.MongoConnection @documents, document_id

    if @onConectionCallbacks

      _.each @onConectionCallbacks, (cb) => cb(connection)

    return connection

  onConnection: (cb) ->

    @onConectionCallbacks = @onConectionCallbacks ? []
    @onConectionCallbacks.push cb

  getConnection: (document_id) ->

    @connections = @connections ? {}
    @connections[document_id] = @connections[document_id] ? @createConnection(document_id)

    return @connections[document_id]
