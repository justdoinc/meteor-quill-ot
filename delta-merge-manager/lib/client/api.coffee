_.extend DeltaMergeManager.prototype,

  createClient: (document_id) ->

    # XXX destroy

    old_base = null
    connection = new Connection()

    # XXX move this functionality to the connection prototype
    server_queue = []
    server_queue.flush = () =>
      base = null
      snapshots = []
      for message in server_queue

        base = message[0]
        snapshots = snapshots.concat(message[1] ? [])

        # XXX squash snapshots as possible

      Meteor.call "#{@messages_collection_name}/update", document_id, [base, snapshots]

    # XXX optimize flush time
    server_queue.flush = _.throttle server_queue.flush, 100

    connection.toServer = (args...) =>

      server_queue.push args
      server_queue.flush()

    connection.requestServerResync = (base) =>

      Meteor.call "#{@messages_collection_name}/requestResync", document_id, base, (error, result) =>

        if error
          console.warn error
        else
          connection.fromServer.apply connection, result

    connection.start = () =>

      Meteor.subscribe "#{@messages_collection_name}/updates", document_id

      @messages_collection.find({ document_id: document_id }).observeChanges
        added: (_id, doc) =>

          connection.fromServer.apply connection, doc.message

    return connection

  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
