_ = require 'lodash'

module.exports = ({url, client, user, topic} = {}) ->
  guid = require 'browserguid'

  {incoming, outgoing} = require('mqtt-level-store') './data'

  client = require 'mqtt'
    .connect url || process.env.MQTTURL,
      username: user || process.env.MQTTUSER
      clientId: client || process.env.MQTTCLIENT || guid()
      incomingStore: incoming
      outgoingStore: outgoing
      clean: false
    .on 'connect', =>
      client.subscribe "#{client.topic}/#", qos: 2
      console.debug 'mqtt connected'
    .on 'message', (topic, msg) =>
      if topic == client.topic
        try
          msg = JSON.parse msg.toString()
          {action, data} = msg
          switch action
            when 'subscribe'
              subscribe data
            when 'unsubscribe'
              unsubscribe data
        catch err
          console.error err

  client.topic = (topic || process.env.MQTTTOPIC).split('/')[0]

  client.symbols = []

  client.patterns = []

  subscribe = (list) ->
    old = client.symbols
    client.symbols = _.sortedUniq(client.symbols
      .concat list
      .sort (a, b) ->
        a - b
    )
    client.emit 'symbols', client.symbols, old

  unsubscribe = (list) ->
    old = client.symbols
    client.symbols = client.symbols
       .filter (code) ->
         code not in data
    client.emit 'symbols', client.symbols, old
  
  client
