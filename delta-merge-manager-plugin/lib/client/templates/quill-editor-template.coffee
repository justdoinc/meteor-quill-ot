Template.quill_editor.onCreated ->
  @is_full_screen = new ReactiveVar(false)
  @editor_id = Random.id().replace /^\d/, "x"

Template.quill_editor.helpers

  editor_id: () -> Template.instance().editor_id

  is_full_screen: () -> Template.instance().is_full_screen.get()

Template.quill_editor.onRendered ->
  options = _.defaults @data.quillOptions ? {},
    theme: 'bubble'
    bounds: @$('.quill-wrapper')[0]
  full_screen_options = _.defaults @data.quillFullscreenOptions ? {}, options

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

  # editor_is_fullscreen
  # @autorun =>
  #   is_full_screen = @is_full_screen.get()
  #   if is_full_screen == true and @data.quillFullscreenOptions?
  #     contents = @editor.getContents()
  #
  #     editor = @$("##{@editor_id}")
  #     $("<div id=\"#{@editor_id}\">").insertAfter(editor)
  #     editor.remove()
  #
  #     @editor = new Quill "##{@editor_id}", full_screen_options
  #     @editor.setContents contents, 'silent'
  #     @connection = APP.delta_merge_manager_plugin.delta_merge_manager.createQuillClient(document_id.get(), @editor, initial_html)
  #
  #     editor_is_fullscreen = true
  #
  #   if is_full_screen == false and editor_is_fullscreen
  #     contents = @editor.getContents()
  #
  #     editor = @$("##{@editor_id}")
  #     $("<div id=\"#{@editor_id}\">").insertAfter(editor)
  #     editor.remove()
  #
  #     @editor = new Quill "##{@editor_id}", options
  #     @editor.setContents contents, 'silent'
  #
  #     editor_is_fullscreen = true



Template.quill_editor.events
  'click .quill-full-screen-button': (e, tmpl) ->
    e.preventDefault()
    
    tmpl.is_full_screen.set not tmpl.is_full_screen.get()
