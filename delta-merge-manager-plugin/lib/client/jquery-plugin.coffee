$.fn.quill = (template, data) ->
  if template == "destroy"
    view = @data 'quill'

    Blaze.remove(view)

    return @

  if not data? and template?
    data = template
    template = "quill_editor"

  view = Blaze.renderWithData Template[template], data, @[0]

  @data 'quill', view

  return @
