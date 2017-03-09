Package.describe({
  name: "justdoinc:delta-merge-manager",
  version: "1.0.0",
  summary: "Resolves delta merges on both the client and the server allowing for realtime richtext collaboration using the quilljs delta format",
  git: "https://github.com/justdoinc/justdo-shared-packages/tree/master/delta-merge-manager"
});

client = "client"
server = "server"
both = [client, server]

Package.onUse(function (api) {
  api.versionsFrom("1.4.1.1");

  api.use("coffeescript", both);
  api.use("underscore", both);
  api.use("random", both);
  api.use("mongo", both);

  api.use("raix:eventemitter@0.1.1", both);
  api.use("meteorspark:util@0.2.0", both);
  api.use("meteorspark:logger@0.3.0", both);
  // api.use("justdoinc:justdo-helpers@1.0.0", both);

  api.use("cwohlman:quill-delta@3.4.3_1", both);
  api.use("cwohlman:render-quill@1.0.5_1", both);

  api.use("reactive-var", both);
  api.use("tracker", client);

  api.addFiles('lib/both/delta-server.coffee', both);
  api.addFiles('lib/both/delta-server-mongo.coffee', both);
  api.addFiles('lib/both/delta-server-sync.coffee', server);

  api.export("DeltaServer", both)

  api.addFiles("lib/both/init.coffee", both);
  api.addFiles("lib/both/errors-types.coffee", both);
  api.addFiles("lib/both/api.coffee", both);
  api.addFiles("lib/both/schemas.coffee", both);

  api.addFiles("lib/server/init.coffee", server);
  api.addFiles("lib/server/api.coffee", server);
  api.addFiles("lib/server/allow-deny.coffee", server);
  api.addFiles("lib/server/collections-hooks.coffee", server);
  api.addFiles("lib/server/collections-indexes.coffee", server);
  api.addFiles("lib/server/methods.coffee", server);
  api.addFiles("lib/server/publications.coffee", server);

  api.addFiles("lib/client/init.coffee", client);
  api.addFiles("lib/client/api.coffee", client);
  api.addFiles("lib/client/methods.coffee", client);

  api.export("DeltaMergeManager", both);
});

Package.onTest(function (api) {
  // Meteor packages
  api.use('meteor');
  api.use('coffeescript');
  api.use('mongo');
  api.use('underscore');

  // The tests
  api.use('practicalmeteor:mocha');
  api.use('practicalmeteor:chai');

  // The package
  api.use('justdoinc:delta-merge-manager');
  api.use("cwohlman:quill-delta@3.4.3_1", both);

  api.addFiles('tests/delta-server.tests.coffee')
  api.addFiles('tests/delta-server-mongo.tests.coffee')
  api.addFiles('tests/delta-server-sync.tests.coffee', server)
});
