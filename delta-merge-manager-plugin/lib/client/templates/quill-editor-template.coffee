Template.quill_editor.onCreated ->
  @editor_id = Random.id()

Template.quill_editor.helpers

  editor_id: () -> Template.instance().editor_id

Template.quill_editor.onRendered ->
  options = _.defaults @data.options ? {},
    theme: 'bubble'

  @editor = new Quill "##{@editor_id}", options

  document_id = new ReactiveVar()
  @autorun =>
    data = Template.currentData()

    document_id.set(data.document_id)

  # Running createQuillClient inside of an autorun will teardown the connection
  # (and create a new one) if the document_id ever changes.
  @autorun =>
    @editor.setContents({ops: []})
    @connection = DeltaManager.createQuillClient(document_id.get(), @editor)
