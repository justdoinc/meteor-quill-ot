Template.quill.onRendered ->
  @editor = new Quill '#editor',
    theme: 'bubble'


  @autorun (c) =>
    doc = Documents.findOne()
    if doc?
      newContent = new Delta doc.content
      cursor = @editor.getSelection()
      diff = @editor.getContents().diff newContent
      @editor.setContents newContent, "api"
      newIndex = diff.transformPosition(cursor.index)
      newLength = diff.transformPosition(cursor.index + cursor.length) - newIndex
      @editor.setSelection newIndex, newLength
      # c.stop()

  # XXX throttle this so we have only 1-2 requests per second, or something reasonable.
  @editor.on 'text-change', (delta, original, source) =>
    if source == "user"
      Meteor.call 'update', delta, original
