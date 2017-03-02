_.extend DeltaMergeManager.prototype,

  createClient: (document_id) ->

    # XXX destroy

    old_base = null
    connection = new Connection()
    connection.toServer = (args...) =>

      Meteor.call "#{@messages_collection_name}/update", document_id, args

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
