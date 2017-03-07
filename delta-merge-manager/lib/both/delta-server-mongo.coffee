@DeltaServer.MongoConnection = (store, id) =>

  server = new @DeltaServer()
  _fromClient = server.fromClient
  server.fromClient = (client_id, delta) ->
    result = _fromClient.apply(server, arguments)

    server.submitChanges(client_id)

    return result

  old_server = { change_key: null, content: new Delta() }
  server.toServer = (delta, callback) ->
    new_change_key = Random.id()

    update = old_server.content.compose(delta)
    result = store.update
      _id: id,
      change_key: old_server.change_key
    ,
      $set:
        change_key: new_change_key
        content: update

    if result == 0
      new_server = store.findOne(id)
      if new_server
        new_server.content = new Delta(new_server.content)
        new_delta = old_server.content.diff(new_server.content).transform(delta)

        old_server = new_server
        return @toServer(new_delta, callback)
      else
        throw new Error "Can't find document"

    else
      old_server.content = update
      callback(null, update)

  store.upsert
    _id: id
  ,
    $setOnInsert:
      change_key: null
      content: new Delta()

  server.resyncServer()

  return server
