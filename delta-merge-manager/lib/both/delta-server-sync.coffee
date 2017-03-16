_.extend DeltaServer.prototype,

  onAfterToServer: (cb) ->
    _toServer = @toServer
    @toServer = (delta, callback) ->
      callback = Meteor.bindEnvironment(callback)
      inner_callback = (error, result) =>
        if error?
          return callback(error)
        try
          cb(result, @)
        catch e
          console.warn("Exception in onAfterToServer callback", e)

        callback(null, result)

      _toServer.apply(@, [delta, inner_callback])

_.extend DeltaMergeManager.prototype,

  attachRenderCallback: (cb) ->
    renderFns = {}

    @onConnection (connection) =>
      connection.onAfterToServer (result, connection) =>
        # Throttle the render function so that we render at most once per second
        id = connection.document_id
        callback = Meteor.bindEnvironment((error, result) =>
          if error?
            return console.warn("Exception in render quill", error)
          cb(id, result)
        )
        renderFns[id] = renderFns[id] ? _.throttle (doc, cb) =>
          RenderQuill doc, cb
        , 1000

        renderFns[id](result, callback)
