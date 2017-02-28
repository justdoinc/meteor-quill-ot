@DeltaManager = new DeltaMergeManager
  snapshots: new Mongo.Collection "snapshots"
  documents: new Mongo.Collection "documents"

if Meteor.isServer
  DeltaManager.security
    update: -> true
    publish: -> true
