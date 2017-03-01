subscription_documents = null

_.extend DeltaMergeManager.prototype,
  _immediateInit: ->
    if not subscription_documents?
      subscription_documents = new Mongo.Collection("__delta_merge_manager_documents__")

    @subscription_documents = subscription_documents

    return

  _deferredInit: ->
    return
