Template.quill.onRendered ->
  @editor = new Quill '#editor',
    theme: 'bubble'

  @connection = DeltaManager.createQuillClient("doc", @editor)
