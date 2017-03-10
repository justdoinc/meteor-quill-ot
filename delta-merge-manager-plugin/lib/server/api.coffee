_.extend DeltaMergeManagerPlugin.prototype,
  registerRealtimeEditableField: (id_regex, onBeforeSave, onAfterSave) ->

    @callbacks.push
      regex: id_regex
      onBeforeSave: onBeforeSave
      onAfterSave: onAfterSave

  _checkSecurity: (document_id, changes, user_id) ->
    callbacks = _.find @callbacks, (callback) => callback.regex.test(document_id)

    if callbacks?

      return callbacks.onBeforeSave(document_id, changes, user_id)

  _onAfterSaveHook: (document_id, html) ->
    callbacks = _.find @callbacks, (callback) => callback.regex.test(document_id)

    if callbacks?

      return callbacks.onAfterSave(document_id, html)



  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
