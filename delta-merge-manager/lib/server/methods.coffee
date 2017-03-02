_.extend DeltaMergeManager.prototype,
  _setupMethods: ->
    manager = @

    if manager.messages_collection_name?
      Meteor.methods
        "#{manager.messages_collection_name}/submit": (document_id, message) =>

          return manager.updateWithSecurity document_id, message, @userId

    return
