_.extend DeltaMergeManager.prototype,
  _setupMethods: ->
    manager = @

    if manager.messages_collection_name?
      Meteor.methods
        "#{manager.messages_collection_name}/submitChanges": (document_id, delta) ->

          return manager.submitChangesWithSecurity document_id, @connection.id, delta, @userId

        "#{manager.messages_collection_name}/closeConnection": (document_id, base, client) ->

          return manager.closeConnection document_id, base, client, @connection.id

    return
