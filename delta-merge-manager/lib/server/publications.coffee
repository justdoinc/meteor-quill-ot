_.extend DeltaMergeManager.prototype,
  _setupPublications: ->
    manager = @

    Meteor.publish "__delta_merge_manager_documents__", (document_id) ->

      return manager.publishWithSecurity document_id, @
