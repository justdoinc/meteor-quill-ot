_.extend DeltaMergeManager.prototype,

  publishWithSecurity: (document_id, publication) ->

    @_checkSecurity("publish", document_id, publication.userId)

    return @publish(document_id, publication)

  publish: (document_id, publication) ->
    # NOTE: This function does NOT check security, it should be called from
    # publishWithSecurity if you want security checks done.

    # NOTE: this collection is explicitly not supposed to be identical to the
    # @documents collection, but, the documents in this collection should look
    # exactly like the documents returned by @getDocument
    @documents.find({ _id: document_id }).observeChanges
      added: =>
        doc = @documents.findOne(document_id)
        snapshot = @snapshots.findOne(doc.snapshot_id)
        publication.added "__delta_merge_manager_documents__", document_id, { document: doc, snapshot: snapshot }
      changed: =>
        console.log('changed')
        doc = @documents.findOne(document_id)
        snapshot = @snapshots.findOne(doc.snapshot_id)
        publication.changed "__delta_merge_manager_documents__", document_id, { document: doc, snapshot: snapshot }
      removed: =>
        publication.remove "__delta_merge_manager_documents__", document_id

    # TODO: publication of cursors

    return publication.ready()

  updateWithSecurity: (document_id, updated_snapshot, user_id) ->

    @_checkSecurity "update", document_id, user_id

    # TODO: record the user on each snapshot

    return @updateOrInsertDocument document_id, updated_snapshot

  # NOTE: It may be preferable to run the security check in app code and use
  # the publish and update api calls directly
  _checkSecurity: (action_name, document_id, user_id) ->

    if not @_allow_actions?
      throw @_error "security-not-configured"

    if not @_allow_actions[action_name]?
      throw @_error "not-permitted", "The action is not allowed."

    if not @_allow_actions[action_name](user_id, document_id)
      throw @_error "not-permitted", "The user is not allowed to perform the action on the document."

  security: (actions) ->
    # TODO: Validate actions against some kind of schema
    if @_allow_actions?
      throw new Error "security-already-configured"

    @_allow_actions = actions

  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
