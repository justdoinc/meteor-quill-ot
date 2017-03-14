_.extend DeltaMergeManager.prototype,

  createConnection: (document_id) ->

    connection = DeltaServer.MongoConnection @documents, document_id

    if @onConectionCallbacks

      _.each @onConectionCallbacks, (cb) => cb(connection)

    return connection

  setAuthor: (delta, author) ->
    delta = new Delta(delta)
    result = delta.map (op) ->
      if op.insert?
        op = _.clone(op)
        op.attributes = if op.attributes? then op.clone(op.attributes) else {}
        op.attributes.author = author

      return op

    return new Delta({ops: result})

  onConnection: (cb) ->

    @onConectionCallbacks = @onConectionCallbacks ? []
    @onConectionCallbacks.push cb

  getConnection: (document_id) ->

    @connections = @connections ? {}
    @connections[document_id] = @connections[document_id] ? @createConnection(document_id)

    return @connections[document_id]
