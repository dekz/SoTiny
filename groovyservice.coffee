io = require 'socket.io'
express = require 'express'
connect = require 'connect'
sys = require 'sys'
http = require 'http'

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
		sys.puts(data)
		getSongs(data)
	)
)


target = "Beethoven"
connection = http.createClient(80, "tinysong.com")

getSongs = (song) ->
	request = connection.request('GET', "/s/" +  target + "?format=json", {"host": "tinysong.com", "User-Agent": "NodeJS TinySong Client"})
	request.addListener("response", (response) ->
		responseBody = ""
		response.setEncoding("utf8");
		response.addListener("data", (chunk) ->
			responseBody += chunk
		)
		response.addListener("end", ->
			results = JSON.parse(responseBody)
			length = results.length
			for song in results
				sys.puts(song.SongName + " - " + song.ArtistName)
		)
	)
	request.end()


