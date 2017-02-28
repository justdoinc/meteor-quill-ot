_.extend DeltaMergeManager.prototype,
  _setupMethods: ->
    manager = @

    Meteor.methods
      "delta-merge-manager_update": (document_id, updated_snapshot) =>

        return manager.updateWithSecurity(document_id, Snapshot.fromJSON(updated_snapshot), @)

    return
