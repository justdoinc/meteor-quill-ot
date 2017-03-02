_.extend DeltaMergeManager.prototype,

  createClient: (document_id, up) ->

    # XXX destroy

    Meteor.subscribe "#{@messages_collection_name}/updates", document_id

    old_base = null
    connection = null
    api =
      fromClient: (delta) =>
        # Ignore changes before connection is established
        # client shouldn't submit any changes until the 'up' callback has
        # been called at least once.

        if connection?
          connection.fromClient { base_id: connection.base._id, delta: delta }

    Tracker.autorun =>

      @messages_collection.find({ document_id: document_id }).observeChanges
        added: (_id, doc) =>
          if not connection?

            connection = new Connection(
              doc.message[0]
            ,
              (base) => if connection? then up(connection.content())
            ,
              (args...) => Meteor.call "#{@messages_collection_name}/submit", document_id, args
            )

            up(connection.content())

          else

            connection.fromServer.apply(connection, doc.message)

    return api

  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
