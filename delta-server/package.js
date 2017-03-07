Package.describe({
  name: 'justdoinc:delta-server',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: '',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

client = "client"
server = "server"
both = [client, server]

Package.onUse(function(api) {
  api.versionsFrom('1.4.3.1');

  api.use("coffeescript", both);
  api.use("underscore", both);
  api.use("random", both);

  api.use("cwohlman:quill-delta@3.4.3", both);
  api.imply("cwohlman:quill-delta@3.4.3", both);

  api.addFiles('delta-server.coffee', both);
  api.addFiles('delta-server-mongo.coffee', both);

  api.export("DeltaServer", both)
});

Package.onTest(function(api) {
  api.use("justdoinc:delta-server", both)

  api.use("coffeescript", both);
  api.use("underscore", both);
  api.use("random", both);
  api.use("mongo", both);

  // The tests
  api.use('practicalmeteor:mocha');
  api.use('practicalmeteor:chai');

  api.addFiles('delta-server.tests.coffee')
  api.addFiles('delta-server-mongo.tests.coffee')
});
