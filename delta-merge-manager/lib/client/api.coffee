_.extend DeltaMergeManager.prototype,

  createClient: (document_id) ->

    connection = new DeltaServer()

    connection.toServer = (delta, callback) =>
      Meteor.call "#{@messages_collection_name}/submitChanges", document_id, delta, (err, result) =>
        if not err?
          callback null, new Delta(result)

    connection.start = (cb) =>
      connection.connect("default")
      Meteor.setInterval =>
        cb(connection.fromClient("default", new Delta()))
        connection.resyncServer()
      , 100
      return (delta) =>
        cb(connection.fromClient("default", delta))
        connection.submitChanges("default")

    return connection

  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
