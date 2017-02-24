// Import Tinytest from the tinytest Meteor package.
import { Tinytest } from "meteor/tinytest";

// Import and rename a variable exported by delta.js.
import Delta from "meteor/cwohlman:delta";

// Write your tests here!
// Here is an example.
Tinytest.add('delta - constructor is exported', function (test) {
  test.equal(new Delta() instanceof Delta, true);
});
