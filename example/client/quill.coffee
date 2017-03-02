Template.quill.onRendered ->
  @editor = new Quill '#editor',
    theme: 'bubble'

  @connection = DeltaManager.createClient "doc"

  @connection.toClient = (snapshot) =>
    doc = @connection.content(snapshot)

    cursor = @editor.getSelection()
    diff = @editor.getContents().diff doc
    @editor.setContents doc, "api"

    if cursor?
      newIndex = diff.transformPosition(cursor.index)
      newLength = diff.transformPosition(cursor.index + cursor.length) - newIndex
      @editor.setSelection newIndex, newLength

  @editor.on 'text-change', (delta, original, source) =>
    if source == "user"
      Meteor.defer =>
        @connection.fromClient
          base_id: @connection.base?._id
          delta: (@connection.content() ? new Delta()).diff(@editor.getContents())

  @autorun =>

    @connection.start()
