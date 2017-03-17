Template.quill_click_to_edit.onCreated ->

  @editing = new ReactiveVar(false)

Template.quill_click_to_edit.helpers

  editing: -> Template.instance().editing.get()

  mayEdit: -> @options?.mayEdit ? true

  cleanedHTML: -> JustdoHelpers.xssGuard @initial_html

Template.quill_click_to_edit.events

  'dblclick .quill-html-wrapper, click .quill-click-to-edit-button': (e, tmpl) ->
    e.preventDefault()

    # Only enter edit mode if the mayEdit option is enabled or not specified
    if (tmpl.data.options?.mayEdit ? true) == true

      tmpl.editing.set(true)

  'click .quill-click-to-edit-close-button': (e, tmpl) ->

    tmpl.editing.set(false)
