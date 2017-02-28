_.extend DeltaMergeManager.prototype,
  _immediateInit: ->
    @subscription_documents = new Mongo.Collection("__delta_merge_manager_documents__")
    
    return

  _deferredInit: ->
    return
