_.extend DeltaMergeManager.prototype,

  # Returns a subscriber object which manages the details of merging upstream
  # snapshots and pushing local snapshots
  # NOTE: At the moment assumes that you've already subscribed to changes for
  # the relevant document.
  subscriber: (document_id, subscribe, update) ->
    # We allow these callbacks to be overridden so that the app doesn't have
    # to use the built in security model
    if not subscribe?
      subscribe = (document_id) => @subscribe(document_id)
    if not update?
      update = (document_id, snapshot) => @clientUpdate(document_id, snapshot)

    subscribe(document_id)

    manager = @

    result =
      on_update_callbacks: []
      onUpdate: (callback) ->
        @fireCallback(callback)
        @on_update_callbacks.push(callback)

      update: (delta, original) ->

        if @latest?
          @latest = @latest.applyDelta(delta)
          update(document_id, @latest)
        else
          if original
            @client_latest = new Snapshot(original).applyDelta(delta)
          else
            @client_latest = new Snapshot(delta)
          # XXX initialize new doc creation


      fireCallbacks: () ->

        _.each @on_update_callbacks, (cb) => @fireCallback(cb)

      fireCallback: (callback) ->

        if @latest?
          try
            callback(@latest)
          catch error
            manager.logger.error error

      snapshots: {}


    result.computation = Tracker.autorun =>

      document = manager.subscription_documents.findOne({ _id: document_id })


      # TODO: cursor handling
      if document?
        snapshot = Snapshot.fromJSON(document.snapshot)

        result.snapshots[snapshot._id] = snapshot

        if result.latest?
          result.latest = Snapshot.mergeSnapshots(snapshot, result.latest, (id) => result.snapshots[id])
        else
          result.latest = snapshot

        result.fireCallbacks()

    return result

  subscribe: (document_id) ->

    Meteor.subscribe "__delta_merge_manager_documents__", document_id

  clientUpdate: (document_id, update, callback) ->

    Meteor.call "delta-merge-manager_update", document_id, update.toJSON(), callback

  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
