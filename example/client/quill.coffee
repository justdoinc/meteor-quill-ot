Template.quill.onRendered ->
  @editor = new Quill '#editor',
    theme: 'bubble'

  @connection = DeltaManager.createClient "doc", (doc) =>

    if doc?
      cursor = @editor.getSelection()
      diff = @editor.getContents().diff doc
      @editor.setContents doc, "api"

      if cursor?
        newIndex = diff.transformPosition(cursor.index)
        newLength = diff.transformPosition(cursor.index + cursor.length) - newIndex
        @editor.setSelection newIndex, newLength

  @editor.on 'text-change', (delta, original, source) =>
    if source == "user"
      # XXX check that original matches current source, otherwise fix.
      @connection.fromClient delta
