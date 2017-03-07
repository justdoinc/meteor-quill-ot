Template.quill.onRendered ->
  @editor = new Quill '#editor',
    theme: 'bubble'

  @connection = DeltaManager.createClient "doc"

  # @autorun =>

  original = new Delta()
  update = @connection.start (doc) =>
    if doc.diff(original).ops.length == 0
      return

    cursor = @editor.getSelection()
    diff = @editor.getContents().diff doc
    @editor.setContents doc, "api"
    original = doc

    if cursor?
      newIndex = diff.transformPosition(cursor.index)
      newLength = diff.transformPosition(cursor.index + cursor.length) - newIndex
      @editor.setSelection newIndex, newLength

  @editor.on 'text-change', (delta, original, source) =>
    if source == "user"
      Meteor.defer => update(delta)
