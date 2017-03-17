DeltaServer = @DeltaServer = ->

  @connections = {}
  @server = new Delta()

  return @

# profile_time_total = [0, 0, 0]
# profile_time_total_1 = [0, 0, 0]

_.extend DeltaServer.prototype,

  connect: (id) ->
    id = id ? Random.id()
    @connections[id] = @connections[id] ?
      base: @server
      client: @server

    return [id, @connections[id].client]

  disconnect: (id) ->

    delete @connections[id]

  current: (id) -> @connections[id].client

  finalize: (id, base, client) ->
    connection = @connections[id]

    # client's server should now be connection.client
    # let's update client's base
    client_base = base
    client_server = connection.client
    client_change = client_base.diff(client_server).transform(client_base.diff(client))

    updated_client = client_server.compose(client_change)

    return @fromClient(id, connection.client.diff(updated_client))

  fromClient: (id, diff) ->
    # if Meteor.isServer
    #   profile_start_time = process.hrtime()
    # Assume base: +a
    # Assume server: +ab
    # Assume client: +ac
    # Assume diff: ..+d

    # Correct output:
    # base: +ab
    # client: +acdb
    # return +acdb

    connection = @connections[id]

    connection.client = connection.client.compose(diff)

    if connection.paused
      return connection.client

    update = connection.base.diff(@server).transform(connection.base.diff(connection.client))
    connection.client = @server.compose(update)

    if not connection.paused
      connection.base = @server

    # if Meteor.isServer
    #   profile_duration_time = process.hrtime(profile_start_time)
    #   profile_time_total = [ profile_duration_time[0] + profile_time_total[0], profile_duration_time[1] + profile_time_total[1], 1 + profile_time_total[2] ]
    #   while profile_time_total[1] > 1e9
    #     profile_time_total[1] = profile_time_total[1] - 1e9
    #     profile_time_total[0] = profile_time_total[0] + 1
    #
    #   console.log "current: " + profile_duration_time[1], "average: " + (profile_time_total[0] * 1e9 + profile_time_total[1]) / profile_time_total[2], "count: " + profile_time_total[2], "total: " + (profile_time_total[0] * 1e9 + profile_time_total[1])


    return connection.client

  submitChanges: (id) ->
    # if Meteor.isServer
    #   profile_start_time = process.hrtime()
    # Assume base: +a
    # Assume server: +ab
    # Assume client: +ac

    connection = @connections[id]

    if connection.paused
      return

    update = connection.base.diff(@server).transform(connection.base.diff(connection.client))

    if update.ops.length == 0
      return

    connection.paused = true
    connection.old_client = connection.client
    @toServer update, (err, result) =>
      if err
        throw err

      @server = result
      connection.base = connection.old_client
      connection.paused = false


      # if Meteor.isServer
      #   profile_duration_time = process.hrtime(profile_start_time)
      #   profile_time_total_1 = [ profile_duration_time[0] + profile_time_total_1[0], profile_duration_time[1] + profile_time_total_1[1], 1 + profile_time_total_1[2] ]
      #   while profile_time_total_1[1] > 1e9
      #     profile_time_total_1[1] = profile_time_total_1[1] - 1e9
      #     profile_time_total_1[0] = profile_time_total_1[0] + 1
      #
      #   console.log "toServer: " + profile_duration_time[1], "average: " + (profile_time_total_1[0] * 1e9 + profile_time_total_1[1]) / profile_time_total_1[2], "count: " + profile_time_total_1[2], "total: " + (profile_time_total_1[0] * 1e9 + profile_time_total_1[1])


  resyncServer: () ->

    @toServer new Delta(), (err, result) =>
      @server = result
