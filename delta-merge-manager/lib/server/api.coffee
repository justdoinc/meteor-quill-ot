


_.extend DeltaMergeManager.prototype,

  submitChangesWithSecurity: (document_id, connection_id, message, user_id) ->

    result = @_checkSecurity document_id, message, user_id
    if result?.ops?
      message = result
    else if result != true
      throw new Error "security-check-failed"

    return @submitChanges(document_id, connection_id, message)

  closeConnection: (document_id, connection_id) ->
    connection = @getConnection document_id

    # Mark this connection as disconnected
    delete connection.connections[connection_id]

    if not _.any connection.connections
      @documents.remove { _id: document_id }
      delete @connections[document_id]

  submitChanges: (document_id, connection_id, delta) ->
    connection = @getConnection document_id
    connection.connect connection_id

    return connection.fromClient(connection_id, delta)

  # NOTE: It may be preferable to run the security check in app code and use
  # the publish and update api calls directly
  _checkSecurity: (document_id, message, user_id) -> throw @_error "security-not-configured"

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
