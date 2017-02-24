Document = (base) ->

  @current = base

  return @

_.extend Document.prototype,

  applyDelta: (delta) ->

    @current = @current.compose delta

    return @
