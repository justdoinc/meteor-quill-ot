describe "hammer tests", ->
  manager = null

  beforeEach ->
    manager = new DeltaMergeManager
      documents: new Mongo.Collection null
      snapshots: new Mongo.Collection null
      messages_collection_name: null

  it "test #1 historical client submissions", ->

    `
    var messages = [
    [{"_id":"Mx9frTTaWCpnCaxi7","base_id":"fgET9E4gsjsjLZSzu","content":{"ops":[{"insert":"1\n"}]}},[{"_id":"Mx9frTTaWCpnCaxi7","base_id":"fgET9E4gsjsjLZSzu","delta":{"ops":[{"insert":"1"}]}}]],
    [{"_id":"Lf43KyNuAjb3sd5n5","base_id":"Mx9frTTaWCpnCaxi7","content":{"ops":[{"insert":"11\n"}]}},[{"_id":"Lf43KyNuAjb3sd5n5","base_id":"Mx9frTTaWCpnCaxi7","delta":{"ops":[{"retain":1},{"insert":"1"}]}}]],
    [{"_id":"DbG7yHQWoASDS88qv","base_id":"Lf43KyNuAjb3sd5n5","content":{"ops":[{"insert":"111\n"}]}},[{"_id":"DbG7yHQWoASDS88qv","base_id":"Lf43KyNuAjb3sd5n5","delta":{"ops":[{"retain":2},{"insert":"1"}]}}]],
    [{"_id":"KztYDPTyxgSawTaHf","base_id":"Lf43KyNuAjb3sd5n5","content":{"ops":[{"insert":"111\n"}]}},[{"_id":"KztYDPTyxgSawTaHf","base_id":"Lf43KyNuAjb3sd5n5","delta":{"ops":[{"retain":2},{"insert":"1"}]}}]],
    [{"_id":"pnuhvgkox9JbCP2ML","base_id":"6RPhdYxBGnoT7u3Ge","content":{"ops":[{"insert":"11111\n"}]}},[{"_id":"pnuhvgkox9JbCP2ML","base_id":"6RPhdYxBGnoT7u3Ge","delta":{"ops":[{"retain":4},{"insert":"1"}]}}]],
    [{"_id":"FwzYRDgrfqqnyBwAF","base_id":"2Pi479xSJzkgKHfcE","content":{"ops":[{"insert":"111111\n"}]}},[{"_id":"FwzYRDgrfqqnyBwAF","base_id":"2Pi479xSJzkgKHfcE","delta":{"ops":[{"retain":5},{"insert":"1"}]}}]],
    [{"_id":"4bc7PpDiAM36Qop2g","base_id":"pnuhvgkox9JbCP2ML","content":{"ops":[{"insert":"111111\n"}]}},[{"_id":"4bc7PpDiAM36Qop2g","base_id":"pnuhvgkox9JbCP2ML","delta":{"ops":[{"retain":5},{"insert":"1"}]}}]],
    [{"_id":"yBnnrefkjgpXH2Eug","base_id":"L4N7Tcm2BD5gKSxGM","content":{"ops":[{"insert":"11111111\n"}]}},[{"_id":"yBnnrefkjgpXH2Eug","base_id":"L4N7Tcm2BD5gKSxGM","delta":{"ops":[{"retain":7},{"insert":"1"}]}}]],
    [{"_id":"rZZFNRbvsn8WBemrr","base_id":"4bc7PpDiAM36Qop2g","content":{"ops":[{"insert":"1111111\n"}]}},[{"_id":"rZZFNRbvsn8WBemrr","base_id":"4bc7PpDiAM36Qop2g","delta":{"ops":[{"retain":6},{"insert":"1"}]}}]],
    [{"_id":"pWAop6pjWvAzcDtqh","base_id":"damAxPascX8pRqWu3","content":{"ops":[{"insert":"1111111111\n"}]}},[{"_id":"pWAop6pjWvAzcDtqh","base_id":"damAxPascX8pRqWu3","delta":{"ops":[{"retain":9},{"insert":"1"}]}}]],
    [{"_id":"qhbXH3BuyCxrcWZeg","base_id":"HP6TjYCfkbinHTXcc","content":{"ops":[{"insert":"111111111111\n"}]}},[{"_id":"qhbXH3BuyCxrcWZeg","base_id":"HP6TjYCfkbinHTXcc","delta":{"ops":[{"retain":11},{"insert":"1"}]}}]],
    [{"_id":"ubc2F3dbYxqnKpmCg","base_id":"rZZFNRbvsn8WBemrr","content":{"ops":[{"insert":"11111111\n"}]}},[{"_id":"ubc2F3dbYxqnKpmCg","base_id":"rZZFNRbvsn8WBemrr","delta":{"ops":[{"retain":7},{"insert":"1"}]}}]],
    [{"_id":"7ZYHyBzJm89ZXKBJW","base_id":"YjHLdo544WFLSY3W2","content":{"ops":[{"insert":"11111111111111\n"}]}},[{"_id":"7ZYHyBzJm89ZXKBJW","base_id":"YjHLdo544WFLSY3W2","delta":{"ops":[{"retain":13},{"insert":"1"}]}}]],
    [{"_id":"4kK44cRnT64FGWcPR","base_id":"ubc2F3dbYxqnKpmCg","content":{"ops":[{"insert":"111111111\n"}]}},[{"_id":"4kK44cRnT64FGWcPR","base_id":"ubc2F3dbYxqnKpmCg","delta":{"ops":[{"retain":8},{"insert":"1"}]}}]],
    [{"_id":"CSSWfvtw3FL2yxuXr","base_id":"gARSMS56tt8nBbaGY","content":{"ops":[{"insert":"1111111111111111\n"}]}},[{"_id":"CSSWfvtw3FL2yxuXr","base_id":"gARSMS56tt8nBbaGY","delta":{"ops":[{"retain":15},{"insert":"1"}]}}]],
    [{"_id":"GQ8xDLANkjsefKQoZ","base_id":"4kK44cRnT64FGWcPR","content":{"ops":[{"insert":"1111111111\n"}]}},[{"_id":"GQ8xDLANkjsefKQoZ","base_id":"4kK44cRnT64FGWcPR","delta":{"ops":[{"retain":9},{"insert":"1"}]}}]],
    [{"_id":"kGPHaAgKXqY2Z7We6","base_id":"GQ8xDLANkjsefKQoZ","content":{"ops":[{"insert":"11111111111\n"}]}},[{"_id":"kGPHaAgKXqY2Z7We6","base_id":"GQ8xDLANkjsefKQoZ","delta":{"ops":[{"retain":10},{"insert":"1"}]}}]],
    [{"_id":"QKxJyXasEkWQhNNgL","base_id":"wRXZRhHYfkpYModkJ","content":{"ops":[{"insert":"111111111111111111\n"}]}},[{"_id":"QKxJyXasEkWQhNNgL","base_id":"wRXZRhHYfkpYModkJ","delta":{"ops":[{"retain":17},{"insert":"1"}]}}]],
    [{"_id":"MxC25rwwnJqf9fpbt","base_id":"GrtRnonAnfsn2XzJJ","content":{"ops":[{"insert":"11111111111111111111\n"}]}},[{"_id":"MxC25rwwnJqf9fpbt","base_id":"GrtRnonAnfsn2XzJJ","delta":{"ops":[{"retain":19},{"insert":"1"}]}}]],
    [{"_id":"MQjZcNRLuFCQef9kL","base_id":"kGPHaAgKXqY2Z7We6","content":{"ops":[{"insert":"111111111111\n"}]}},[{"_id":"MQjZcNRLuFCQef9kL","base_id":"kGPHaAgKXqY2Z7We6","delta":{"ops":[{"retain":11},{"insert":"1"}]}}]],
    [{"_id":"6SiQDkaXYAyxYHEKW","base_id":"MQjZcNRLuFCQef9kL","content":{"ops":[{"insert":"1111111111111\n"}]}},[{"_id":"6SiQDkaXYAyxYHEKW","base_id":"MQjZcNRLuFCQef9kL","delta":{"ops":[{"retain":12},{"insert":"1"}]}}]],
    [{"_id":"xLoWsccEXLJoiGyAF","base_id":"3StJjSsG5jwkRE92W","content":{"ops":[{"insert":"1111111111111111111111\n"}]}},[{"_id":"xLoWsccEXLJoiGyAF","base_id":"3StJjSsG5jwkRE92W","delta":{"ops":[{"retain":21},{"insert":"1"}]}}]],
    [{"_id":"Apv9ZGBjzd8BaA7uu","base_id":"6SiQDkaXYAyxYHEKW","content":{"ops":[{"insert":"11111111111111\n"}]}},[{"_id":"Apv9ZGBjzd8BaA7uu","base_id":"6SiQDkaXYAyxYHEKW","delta":{"ops":[{"retain":13},{"insert":"1"}]}}]],
    [{"_id":"Rmr895gSYLntRgfrS","base_id":"TBLsejiAbkGephbQ6","content":{"ops":[{"insert":"111111111111111111111111\n"}]}},[{"_id":"Rmr895gSYLntRgfrS","base_id":"TBLsejiAbkGephbQ6","delta":{"ops":[{"retain":23},{"insert":"1"}]}}]],
    [{"_id":"rYhYeyCRRETxKJtdN","base_id":"22ebpF6fCsZwjib3a","content":{"ops":[{"insert":"11111111111111111111111111\n"}]}},[{"_id":"rYhYeyCRRETxKJtdN","base_id":"22ebpF6fCsZwjib3a","delta":{"ops":[{"retain":25},{"insert":"1"}]}}]],
    [{"_id":"fvmFKMCkFx5y9DQ94","base_id":"Apv9ZGBjzd8BaA7uu","content":{"ops":[{"insert":"111111111111111\n"}]}},[{"_id":"fvmFKMCkFx5y9DQ94","base_id":"Apv9ZGBjzd8BaA7uu","delta":{"ops":[{"retain":14},{"insert":"1"}]}}]],
    [{"_id":"wTnAPRzRio8ZYA5Zt","base_id":"gR266hzNddJCQ2buh","content":{"ops":[{"insert":"1111111111111111111111111111\n"}]}},[{"_id":"wTnAPRzRio8ZYA5Zt","base_id":"gR266hzNddJCQ2buh","delta":{"ops":[{"retain":27},{"insert":"1"}]}}]],
    [{"_id":"8Z4HcsZMFsSo2F68z","base_id":"fvmFKMCkFx5y9DQ94","content":{"ops":[{"insert":"1111111111111111\n"}]}},[{"_id":"8Z4HcsZMFsSo2F68z","base_id":"fvmFKMCkFx5y9DQ94","delta":{"ops":[{"retain":15},{"insert":"1"}]}}]],
    [{"_id":"eN5sGne57pf3FCRMo","base_id":"8Z4HcsZMFsSo2F68z","content":{"ops":[{"insert":"11111111111111111\n"}]}},[{"_id":"eN5sGne57pf3FCRMo","base_id":"8Z4HcsZMFsSo2F68z","delta":{"ops":[{"retain":16},{"insert":"1"}]}}]],
    [{"_id":"LY5qcZ39KJRQ5sxpC","base_id":"ECZ34imjoX3rs5kCT","content":{"ops":[{"insert":"111111111111111111111111111111\n"}]}},[{"_id":"LY5qcZ39KJRQ5sxpC","base_id":"ECZ34imjoX3rs5kCT","delta":{"ops":[{"retain":29},{"insert":"1"}]}}]],
    [{"_id":"HkmbZEfXvsNXJv4Zp","base_id":"uKJk4uCZg2t3biPcc","content":{"ops":[{"insert":"11111111111111111111111111111111\n"}]}},[{"_id":"HkmbZEfXvsNXJv4Zp","base_id":"uKJk4uCZg2t3biPcc","delta":{"ops":[{"retain":31},{"insert":"1"}]}}]],
    [{"_id":"DTvAZPPAqQHyLTNN7","base_id":"eN5sGne57pf3FCRMo","content":{"ops":[{"insert":"111111111111111111\n"}]}},[{"_id":"DTvAZPPAqQHyLTNN7","base_id":"eN5sGne57pf3FCRMo","delta":{"ops":[{"retain":17},{"insert":"1"}]}}]]
    ]
    `

    connection = manager.createServer "document"

    connection.fromClient { _id: "fgET9E4gsjsjLZSzu", content: new Delta() }

    for update in messages

      connection.fromClient.apply connection, update

  # it "test #2 many many merge operations", ->
  #   @timeout(4000)
  #   @slow(2500)
  #
  #   connection = manager.createServer "document"
  #
  #   managers = []
  #   for i in [0..100]
  #     m = new Connection()
  #     managers.push m
  #
  #     for i in [0..100]
  #
  #       m.fromClient
  #         base_id: m.base?._id
  #         delta: new Delta().insert(i + '-')
  #
  #   for m in managers
  #     connection.fromClient(m.base)

  it "test #3 ping pong merges", ->

    server_messages = []
    client_messages = []
    server = new Connection()
    client = new Connection()

    server.toClient = (args...) => server_messages.push args
    client.toServer = (args...) => client_messages.push args

    server.requestClientResync = () => return
    client.requestServerResync = () => return

    server.toServer = () => return
    client.toClient = () => return

    server.fromServer({ content: new Delta() })
    client.fromServer.apply(client, server_messages.pop())

    for i in [0..15]

      # Every eighth tick the client submits all messages to the server
      if (i % 8) == 0
        len = client_messages.length
        for i in [0...len]
          server.fromClient.apply server, client_messages.shift()

      # Every seventh tick the server submits all message to the client
      if (i % 7) == 0
        len = server_messages.length
        for i in [0...len]
          client.fromServer.apply client, server_messages.shift()

      # Every tick the client submits a message adding '-' to the end of the doc
      if i % 1 == 0
        length = client.content()?.ops[0]?.insert?.length ? 0
        client.fromClient { base_id: client.base._id, delta: new Delta().retain(length).insert("-") }
      # Every other tick the server submits a message adding 'x' to the start of the doc
      if i % 2 == 0
        server.fromServer { base_id: server.base._id, delta: new Delta().insert("x") }

      # Every third tick or so, the client submits a message to the server
      if (i % 10) % 3 == 0
        if client_messages.length != 0
          server.fromClient.apply server, client_messages.shift()

      # Every third tick or so, the server submits a message to the client
      if (i % 11) % 3 == 0
        if client_messages.length != 0
          client.fromServer.apply client, server_messages.shift()

      len = server_messages.length
      for i in [0...len]
        client.fromServer.apply client, server_messages.shift()

      len = client_messages.length
      for i in [0...len]
        server.fromClient.apply server, client_messages.shift()

      len = server_messages.length
      for i in [0...len]
        client.fromServer.apply client, server_messages.shift()

    assert.deepEqual(server.content(), client.content())
    assert.equal server_messages.length, 0
    assert.equal client_messages.length, 0
