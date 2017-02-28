Template.quill.onRendered ->
  @editor = new Quill '#editor',
    theme: 'bubble'

  @subscriber = DeltaManager.subscriber "vNHpGQwx8CatNdsx9"

  @subscriber.onUpdate (doc) =>
    if doc?
      newContent = new Delta doc.latest
      cursor = @editor.getSelection()
      diff = @editor.getContents().diff newContent
      @editor.setContents newContent, "api"

      if cursor?
        newIndex = diff.transformPosition(cursor.index)
        newLength = diff.transformPosition(cursor.index + cursor.length) - newIndex
        @editor.setSelection newIndex, newLength


  # XXX throttle this so we have only 1-2 requests per second, or something reasonable.
  @editor.on 'text-change', (delta, original, source) =>
    if source == "user"
      # XXX check that original matches current source, otherwise fix.
      @subscriber.update delta, original
