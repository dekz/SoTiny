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
		#msg = JSON.parse data
#		getList(data)
		finalResponse = ""
		getList(data, client)
		sys.puts("moving on")
#		sys.puts(finalResponse)
#		client.send(finalResponse)
	)
)

connection = http.createClient(80, "tinysong.com")

getList = (search, client) ->
	search = search.split(' ').join('+')
	sys.puts("Searching for text: " + search)
	redisClient.get(search, (err, reply) ->
		if err
			sys.puts("Err: " + err)
		else
			if reply
				results = JSON.parse(reply)
				#finalResponse = reply
				for item in results
					sys.puts(item.SongName + " - " + item.ArtistName)
				client.send(reply)
				#sys.puts("response is" + finalResponse + "\n")
				return
			else
				request = connection.request('GET', "/s/" +  search + "?format=json", {"host": "tinysong.com", "User-Agent": "NodeJS TinySong Client"})
				request.addListener("response", (response) ->
					responseBody = ""
					response.setEncoding("utf8");
					response.addListener("data", (chunk) ->
						responseBody += chunk
					)
					response.addListener("end", ->
						results = JSON.parse(responseBody)
						#finalResponse = responseBody
						redisClient.set(search, responseBody, redis.print)
						for item in results
							sys.puts(item.SongName + " - " + item.ArtistName)
						client.send(responseBody)
						#sys.puts("response is2" + finalResponse + "\n")
						return	
					)
				)
				request.end()
	)


