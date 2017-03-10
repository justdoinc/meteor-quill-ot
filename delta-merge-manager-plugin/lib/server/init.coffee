_.extend DeltaMergeManagerPlugin.prototype,
  _immediateInit: ->

    @callbacks = []
    @delta_merge_manager._checkSecurity = (document_id, changes, user_id) =>
      @_checkSecurity(document_id, changes, user_id)

    @delta_merge_manager.attachRenderCallback (document_id, html) =>
      @_onAfterSaveHook(document_id, html)

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
