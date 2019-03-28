client = require('../index')()
data =
  action: 'subscribe'
  data: [ 56 ]
client.publish client.topic, JSON.stringify data
