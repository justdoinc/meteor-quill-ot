_.extend DeltaMergeManager.prototype,

  createQuillClient: (document_id, editor, initial_html) ->

    connection = new DeltaServer()
    connection.toServer = (delta, callback) =>
      Meteor.call "#{@messages_collection_name}/submitChanges", document_id, delta, (err, result) =>
        if not err?
          result = new Delta(result)
          callback null, result

          # After the first server sync check if there was initial_html if so
          # and if there's no original text in the editor, paste it into the
          # editor.
          if initial_html?
            if result.ops?.length == 0
              # Remove the trailing newline so that when we paste the html,
              # the callback correctly adds the entire contents of the editor.
              editor.clipboard.dangerouslyPasteHTML(initial_html, 'user')
            initial_html = null

          Meteor.defer =>
            new_doc = connection.fromClient(client_id, new Delta())
            submitUpdate(new_doc)

    # This connection is client side only the only 'client' is the quill editor
    client_id = "default"
    connection.connect(client_id)

    current = new Delta()
    on_change_callback = (delta, original, source) =>

      # Ideally all changes should be recorded, including changes made via
      # the api, however at the moment the only user of the api is us and
      # we don't want to create circular calls here (we cause the editor to
      # emit text-change updates whenever the server submits an update)
      if source == "user"
        updated = new Delta(editor.getContents() ? new Delta())
        change = current.diff(updated)
        current = updated
        connection.fromClient(client_id, change)
        connection.submitChanges(client_id)

    editor.on 'text-change', on_change_callback

    previous_update = new Delta()
    submitUpdate = (doc) =>

      # Quill's setContents method doesn't seem optimized for no-op calls,
      # e.g. where we set the same content twice in a row, so we won't call
      # setContents unless there was an actual change.
      if previous_update.diff(doc).ops.length == 0
        return

      # Quill clears the user's cursor position after every setContents call,
      # since we might be making multiple setContents calls per second, all
      # while the user is typing, here we save the current cursor so we can
      # replace it after updating the contents of the editor
      cursor = editor.getSelection()

      # If we need to update the cursor we'll need to do it relative to the
      # current contents of the editor. Of course, if the cursor doesn't exist
      # this isn't necessary.
      diff = cursor? and editor.getContents().diff doc

      # Update the editor and update the previous_update variable
      editor.setContents doc, 'api'
      current = doc
      previous_update = doc

      # If the user isn't focused on the editor there won't be a cursor and
      # trying to set it will cause errors, so check that the cursor exists
      if cursor?
        start_pos = diff.transformPosition cursor.index

        # If the cursor's length is non-zero we also need to transform the
        # end position (in case edits were made inside the user's selection)
        # if not then we don't have to worry about the end position
        if cursor.length
          end_pos = diff.transformPosition cursor.index + cursor.length
          editor.setSelection start_pos, end_pos - start_pos
        else
          editor.setSelection start_pos, 0

    # At the moment we use long-polling to get updates from the server, this
    # may change in the future
    update_handle = Meteor.setInterval () =>
      new_doc = connection.fromClient(client_id, new Delta())
      submitUpdate(new_doc)
      connection.resyncServer()
    ,
      100

    connection.destroy = () =>
      editor.off 'text-change', on_change_callback
      Meteor.clearInterval update_handle
      Meteor.call "#{@messages_collection_name}/closeConnection", document_id

    if Tracker.currentComputation?
      Tracker.currentComputation.onStop =>
        connection.destroy()

    return connection


  destroy: ->
    if @destroyed
      @logger.debug "Destroyed already"

      return

    @destroyed = true

    @logger.debug "Destroyed"

    return
