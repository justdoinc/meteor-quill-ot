Package.describe({
  name: 'cwohlman:quill-delta',
  version: '3.4.3_1',
  // Brief, one-line summary of the package.
  summary: 'Simple api for Quill Deltas, a simple, yet expressive format that can be used to describe contents and changes.',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  "quill-delta": "3.4.3"
});

Package.onUse(function(api) {
  api.versionsFrom('1.4.3.1');
  api.use('ecmascript');
  api.mainModule('delta.js');

  api.export('Delta');
});

Package.onTest(function(api) {
  api.use('ecmascript');
  api.use('tinytest');
  api.use('cwohlman:delta');
  api.mainModule('delta-tests.js');
});
