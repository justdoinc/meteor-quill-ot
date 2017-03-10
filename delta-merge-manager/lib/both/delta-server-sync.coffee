_.extend DeltaServer.prototype,

  onAfterToServer: (cb) ->
    _toServer = @toServer
    @toServer = (delta, callback) ->
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
        renderFns[id] = renderFns[id] ? _.throttle (doc) =>
          RenderQuill doc, (error, result) =>
            if error?
              return console.warn("Exception in render quill", error)
            cb(id, result)
        , 1000

        renderFns[id](result)
