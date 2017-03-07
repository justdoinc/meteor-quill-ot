


_.extend DeltaMergeManager.prototype,

  submitChangesWithSecurity: (document_id, connection_id, message, user_id) ->

    @_checkSecurity "submitChanges", document_id, connection_id, user_id

    return @submitChanges(document_id, connection_id, message)

  submitChanges: (document_id, connection_id, delta) ->
    # console.log(arguments)

    connection = @getConnection document_id
    connection.connect(connection_id)

    return connection.fromClient(connection_id, delta)

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
