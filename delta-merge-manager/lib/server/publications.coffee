_.extend DeltaMergeManager.prototype,
  _setupPublications: ->
    manager = @

    if manager.messages_collection_name?

      Meteor.publish "#{manager.messages_collection_name}/updates", (document_id) ->

        return manager.publishWithSecurity document_id, @
