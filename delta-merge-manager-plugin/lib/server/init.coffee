_.extend DeltaMergeManagerPlugin.prototype,
  _immediateInit: ->

    @callbacks = []
    @delta_merge_manager._checkSecurity = (document_id, changes, user_id) =>
      @_checkSecurity(document_id, changes, user_id)

    @delta_merge_manager.attachRenderCallback (document_id, html) =>
      @_onAfterSaveHook(document_id, html)

    # @registerRealtimeEditableField /tasks\/[a-zA-Z0-9]+\/description/,
    #   # onBeforeSave
    #   (document_id, changes, user_id) =>
    #     id = document_id.match(/tasks\/([a-zA-Z0-9]+)\/description/)[1]
    #     task = APP.collections.Tasks.findOne { _id: id }
    #
    #     if not task or not _.contains(task.users, user_id)
    #       if not task
    #         @logger.warn "Task not found #{id}"
    #       else
    #         @logger.warn "User authorization error, user #{user_id} not in list of authoized users #{task.users}"
    #       throw @_error "not-authorized"
    #
    #     return APP.delta_merge_manager_plugin.delta_merge_manager.setAuthor(changes, user_id)
    #   # onAfterSave
    #   (document_id, html) =>
    #     id = document_id.match(/tasks\/([a-zA-Z0-9]+)\/description/)[1]
    #     APP.collections.Tasks.update
    #       _id: id
    #     ,
    #       $set:
    #         description_managed_by_quill: true
    #         description: html


    return

  _deferredInit: ->
    # Defined in methods.coffee
    @_setupMethods()

    # Defined in publications.coffee
    @_setupPublications()

    # Defined in allow-deny.coffee
    @_setupAllowDenyRules()

    # Defined in collections-hooks.coffee
    @_setupCollectionsHooks()

    # Defined in collections-indexes.coffee
    @_ensureIndexesExists()

    return
