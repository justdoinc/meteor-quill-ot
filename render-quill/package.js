Package.describe({
  name: 'cwohlman:render-quill',
  version: '1.0.5_1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  "render-quill": "1.0.5"
});

Package.onUse(function(api) {
  api.versionsFrom('1.4.3.1');
  api.use('ecmascript');
  api.mainModule('render-quill.js', 'server');

  api.export("RenderQuill", 'server')
});

Package.onTest(function(api) {
  api.use('ecmascript');
  api.use('tinytest');
  api.use('cwohlman:render-quill');
  api.mainModule('render-quill-tests.js', 'server');
});
