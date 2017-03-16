_.extend DeltaMergeManagerPlugin.prototype,
  _attachCollectionsSchemas: ->
    APP.executeAfterAppLibCode =>
      @tasks_delta_description = new SimpleSchema
        description_managed_by_quill:
          label: "Description managed by Quill editor"
          type: Boolean

      APP.collections.Tasks.attachSchema @tasks_delta_description
