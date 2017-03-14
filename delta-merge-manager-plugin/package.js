Package.describe({
  name: "justdoinc:delta-merge-manager-plugin",
  version: "1.0.0",
  summary: "Integrates the delta merge manager into justdo for realtime editing of misc. fields",
  git: "https://github.com/justdoinc/justdo-shared-packages/tree/master/delta-merge-manager-plugin"
});

client = "client"
server = "server"
both = [client, server]

Package.onUse(function (api) {
  api.versionsFrom("1.4.1.1");

  // TODO: We're currently using the ecmascript module for imports in imports.js
  // let's see if we can eliminate that in the future
  api.use("ecmascript", both);
  api.use("coffeescript", both);
  api.use("underscore", both);
  api.use("random", both);

  // api.use("stevezhu:lodash@4.17.2", both);
  api.use("templating", client);
  api.use('fourseven:scss@3.2.0', client);

  api.use("raix:eventemitter@0.1.1", both);
  api.use("meteorspark:util@0.2.0", both);
  api.use("meteorspark:logger@0.3.0", both);
  // api.use("justdoinc:justdo-helpers@1.0.0", both);

  api.use("matb33:collection-hooks@0.8.4", both);

  api.use("justdoinc:delta-merge-manager", both);

  api.use("reactive-var", both);
  api.use("tracker", client);
  api.use("jquery", client);

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

  api.addFiles("lib/imports.js", client);

  api.addFiles("lib/client/init.coffee", client);
  api.addFiles("lib/client/api.coffee", client);
  api.addFiles("lib/client/methods.coffee", client);

  api.addFiles("lib/client/templates/quill-editor-template.html", client)
  api.addFiles("lib/client/templates/quill-editor-template.coffee", client)
  api.addFiles("lib/client/templates/quill-editor-template.sass", client)

  // Uncomment only in packages that integrate with the main applications
  // Pure logic packages should avoid any app specific integration.
  api.use("meteorspark:app@0.3.0", both);
  api.use("justdoinc:justdo-webapp-boot@1.0.0", both);
  api.addFiles("lib/both/app-integration.coffee", both);
  // // Note: app-integration need to load last, so immediateInit procedures in
  // // the server will have the access to the apis loaded after the init.coffee
  // // file.

  api.export("DeltaMergeManagerPlugin", both);
});
