subscription_documents = null

_.extend DeltaMergeManager.prototype,
  _immediateInit: ->
    @client_connections = []

    $(window).on 'beforeunload', () =>
      _.each @client_connections, (connection) => connection.destroy()

    return

  _deferredInit: ->
    return
