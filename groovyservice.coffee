io = require 'socket.io'
express = require 'express'
connect = require 'connect'
sys = require 'sys'
http = require 'http'
redis = require 'redis'

redisClient = redis.createClient()
redisClient.on("error", (err) -> 
  sys.puts("Redis connection error to " + redisClient.host + ":" + redisClient.port + " - " + err)
)

app = module.exports =  express.createServer()

app.register '.coffee', require('coffeekup')
app.set 'view engine', 'coffee'

app.configure ->
  app.set 'views', __dirname + '/views'
  app.use(connect.bodyDecoder())
  app.use(connect.methodOverride())
  app.use(connect.compiler({ src: __dirname + '/public', enable: ['less', 'coffeescript'] }))
  app.use(app.router)
  app.use(connect.staticProvider(__dirname + '/public'))
  
app.configure 'development', ->
  app.use(connect.errorHandler({ dumpExceptions: true, showStack: true}))

app.configure 'production', ->
  app.use connect.errorHandler()

app.get '/', (req, res) ->
  res.render 'layout', {
      context: {
          title: 'layout'
      }
  }
  
app.listen(8000) if !module.parent

socket = io.listen(app)
socket.on('connection', (client) ->
  sys.puts("new socket connection")
  client.on('message', (data) ->
    getList(data, (result) ->
      client.send(result)
    )
  )
)

connection = http.createClient(80, "tinysong.com")

getList = (search, callback) ->
  search = search.split(' ').join('+')
  redisClient.hget(search, 'queryResult', (err, reply) ->
    if err
      sys.puts("Err: " + err)
    else
      if reply
        results = JSON.parse(reply)
        #Sometimes result from the API is 0, might be throttled
        #Update the query count
        redisClient.hincrby(search, 'queryCount', 1)
        callback(reply)
        return
      else
        sys.puts("Querying API for: " + search)
        request = connection.request('GET', "/s/" +  search + "?format=json", {"host": "tinysong.com", "User-Agent": "NodeJS TinySong Client"})
        request.addListener("response", (response) ->
          responseBody = ""
          response.setEncoding("utf8");
          response.addListener("data", (chunk) ->
            responseBody += chunk
          )
          response.addListener("end", ->
            results = JSON.parse(responseBody)
            redisClient.hset(search, 'queryResult', responseBody, redis.print)
            callback(responseBody)
            return  
          )
        )
        request.end()
  )


