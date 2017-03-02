


_.extend DeltaMergeManager.prototype,

  publishWithSecurity: (document_id, publication) ->

    @_checkSecurity("publish", document_id, publication.userId)

    return @publish(document_id, publication)

  publish: (document_id, publication) ->
    if not @messages_collection_name
      throw new Error "no-messages-collection"

    server = @getOrCreateServer document_id

    publish = (args...) =>

      publication.added @messages_collection_name, Random.id(),
        document_id: document_id
        message: args

    server.subscriptions.push(publish)

    # Send initial resync
    server.resyncClient null, publish

    return publication.ready()

  updateWithSecurity: (document_id, message, user_id) ->

    @_checkSecurity "update", document_id, user_id

    return @update(document_id, message)

  update: (document_id, message) ->

    server = @getOrCreateServer document_id

    return server.fromClient.apply(server, message)

  submitSnapshotWithSecurity: (document_id, message, user_id) ->

    @_checkSecurity "update", document_id, user_id

    return @submitSnapshot(document_id, message)

  submitSnapshot: (document_id, snapshot) ->

    server = @getOrCreateServer document_id

    return server.snapshots.commit(snapshot)

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
