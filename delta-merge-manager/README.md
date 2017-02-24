Delta Merge Manager
=======

Backbone for realtime richtext collaboration using quilljs style deltas.

Core idea:

merge = function (delta, baseForDelta) {
  this.applyDelta(delta.transform(diff(this.current, baseForDelta)));
}

Testing
-------

`meteor test-packages --driver-package=practicalmeteor:mocha ./`
