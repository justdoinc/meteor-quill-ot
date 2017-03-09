// Import Tinytest from the tinytest Meteor package.
import { Tinytest } from "meteor/tinytest";

import { RenderQuill } from "meteor/cwohlman:render-quill";
import Delta from "quill-delta";

Tinytest.add('RenderQuill - constructor is exported', function (test) {
  test.equal(typeof RenderQuill, "function");
});

Tinytest.addAsync('RenderQuill - renders a simple paragraph', function (test, done) {
  RenderQuill(new Delta().insert("hi")).then(Meteor.bindEnvironment(function (result) {
    test.equal(result, "<p>hi</p>");
    done()
  }));
});
