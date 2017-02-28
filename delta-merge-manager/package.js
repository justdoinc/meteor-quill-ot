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

  api.use("raix:eventemitter@0.1.1", both);
  api.use("meteorspark:util@0.2.0", both);
  api.use("meteorspark:logger@0.3.0", both);
  // api.use("justdoinc:justdo-helpers@1.0.0", both);

  api.use("cwohlman:quill-delta@3.4.3", both);
  api.imply("cwohlman:quill-delta@3.4.3", both);

  api.use("reactive-var", both);
  api.use("tracker", client);

  api.addFiles("lib/both/snapshot.coffee", both);

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

  // Uncomment only in packages that integrate with the main applications
  // Pure logic packages should avoid any app specific integration.
  // api.use("meteorspark:app@0.3.0", both);
  // api.use("justdoinc:justdo-webapp-boot@1.0.0", both);
  // api.addFiles("lib/both/app-integration.coffee", both);
  // // Note: app-integration need to load last, so immediateInit procedures in
  // // the server will have the access to the apis loaded after the init.coffee
  // // file.

  api.export("DeltaMergeManager", both);
  api.export("SnapshotManager", both);
});

Package.onTest(function (api) {
  // Meteor packages
  api.use('meteor');
  api.use('coffeescript');
  api.use('mongo');

  // The tests
  api.use('practicalmeteor:mocha');
  api.use('practicalmeteor:chai');

  // The package
  api.use('justdoinc:delta-merge-manager');

  api.addFiles('tests/snapshotManager.tests.coffee');

});
