// Write your package code here!

// Variables exported by this module can be imported by other packages and
// applications. See delta-tests.js for an example of importing.
import Delta from 'quill-delta';

Delta.prototype.inspect = function () {
  return "[Delta " + this.ops.map(function (op) {
    if (op.insert != null) return "+++" + op.insert;
    if (op.retain != null) return "..." + op.retain;
    if (op.delete != null) return "---" + op.delete;
  }).join("") + "]"
}

Delta.prototype.toString = Delta.prototype.inspect

export { Delta };
