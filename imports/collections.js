import Delta from 'quill-delta';

Documents = new Mongo.Collection('documents');

// Autopublish for now
Meteor.methods({ "update": (delta, original) => {
  original = original && new Delta(original);
  delta = delta && new Delta(delta);

  return Documents.upsert({
    _id: 'default',
  }, {
    $set: {
      content: original && original.compose(delta) || delta,
    },
    $push: {
      changes: delta,
    },
  });
}})

if (Meteor.isServer)
  Meteor.publish(null, () => Documents.find() )

export { Documents };
