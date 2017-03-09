describe "DeltaServer.attachRenderCallback", ->

  manager = null
  client_id = null
  beforeEach ->
    manager = new DeltaServer()
    client_id = manager.connect()[0]

    manager.toServer = (delta, cb) => cb(null, manager.connections[client_id].client)

  # Rendering is actually kind of slow, about 150-300 ms for a tiny document
  it "should submit rendered dom to the callback", (done) ->
    @slow(700)

    manager.fromClient(client_id, new Delta().insert("x"))

    manager.attachRenderCallback (document_id, doc) =>

      assert.equal(document_id, null)
      assert.deepEqual(doc, "<p>x</p>")

      done()

    manager.submitChanges(client_id)

  # The second render doesn't take as long even though we're rendering a lot
  # more content
  it "torture test", (done) ->
    @slow(400)

    manager.fromClient(client_id, new Delta({"ops":[{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"},{"insert":"Headings"},{"attributes":{"header":1},"insert":"\n"},{"insert":"Bullets"},{"attributes":{"list":"bullet"},"insert":"\n"},{"insert":"\nLists"},{"attributes":{"list":"ordered"},"insert":"\n"},{"insert":"\nAnd More!"},{"attributes":{"code-block":true},"insert":"\n"}]}))

    manager.attachRenderCallback (document_id, doc) =>

      assert.equal(document_id, null)
      assert.deepEqual(doc, '<h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre><h1>Headings</h1><ul><li>Bullets</li></ul><p></p><ol><li>Lists</li></ol><p></p><pre spellcheck="false">And More!</pre>')

      done()

    manager.submitChanges(client_id)
