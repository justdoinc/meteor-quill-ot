Template.quill_editor.onCreated ->
  @editor_id = Random.id().replace /^\d/, "x"

Template.quill_editor.helpers

  editor_id: () -> Template.instance().editor_id

Template.quill_editor.onRendered ->
  options = _.defaults @data.options ? {},
    theme: 'bubble'

  @editor = new Quill "##{@editor_id}", options

  document_id = new ReactiveVar()
  initial_html = null
  @autorun =>
    data = Template.currentData()

    document_id.set(data.document_id)
    initial_html = data.initial_html ? null

  # Running createQuillClient inside of an autorun will teardown the connection
  # (and create a new one) if the document_id ever changes.
  @autorun =>
    @editor.setContents({ops: []})
    @connection = APP.delta_merge_manager_plugin.delta_merge_manager.createQuillClient(document_id.get(), @editor, initial_html)
