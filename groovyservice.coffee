io = require 'socket.io'
express = require 'express'
connect = require 'connect'
sys = require 'sys'
http = require 'http'
redis = require 'redis'
jsdom = require 'jsdom'

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
    if data.search?
      getList(data.search, (result) ->
        reply = {};
        reply.songs = JSON.parse(result)
        client.send(reply)
      )
      #Guess the lyrics from the data sent over
      getMusixLyrics({ guess: data.search }, (result) ->
        reply = {};
        sys.puts("looking for lyrics")
        reply.lyrics = JSON.stringify(result)
        client.send(reply)
      )
  )
)



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
      else
        connection = http.createClient(80, "tinysong.com")
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
            #stored as 'this+is+a+test' as a key
            redisClient.hset(search, 'queryResult', responseBody, redis.print)
            callback(responseBody) 
          )
        )
        request.end()
  )

#Weekly key for lyricsfly - 5cf03f65d7370a44d-temporary.API.access
lyricsflyKey = "5cf03f65d7370a44d-temporary.API.access"
#lyricsSearchURL = "http://api.lyricsfly.com/api/txt-api.php?i=" + lyricsflyKey + "&l="
#Access is restricted to like 30% of the lyrics, need a permanent key if we are to use this service

getLyrics = (opts, callback) ->
  if opts.guess?
    connection = http.createClient(80, "api.lyricsfly.com")
    search = opts.guess.split(' ').join('+')
    sys.puts("searching for lyrics")
    request = connection.request('GET', "/api/txt-api.php?i=" + lyricsflyKey + "&l=" +  search , {"host": "api.lyricsfly.com", "User-Agent": "NodeJS Client"})
    request.addListener("response", (response) ->
      responseBody = ""
      response.setEncoding("utf8");
      response.addListener("data", (chunk) ->
        responseBody += chunk
      )
      response.addListener("end", ->
        #probably a better way to do this
        window = jsdom.jsdom(response.body).createWindow()
        jsdom.jQueryify(window, 'public/jquery/js/jquery-1.4.2.min.js',  (window, jquery) ->
          window.jQuery('body').append("responseBody")
          lyrics = window.jQuery(responseBody).find("tx").text()
#          redisClient.hset(search, 'lyrics', lyrics, redis.print)
          callback(lyrics)
        )
      )
    )
    request.end()


# MusixMatch
musixAPIKey = "d324bfea6aa638544d9099cce2da93ca"

getMusixLyrics = (opts, callback) ->
  if opts.guess?
    getMusixData({lyricSearch: opts.guess }, (result) ->
      getMusixData({lyric: result}, (lyrics) ->
        callback(lyrics)
      )
    )
     
getMusixData = (opts, callback) ->
  if opts.lyricSearch?
    connection = http.createClient(80, "api.musixmatch.com")
    search = opts.lyricSearch.split(' ').join('+')
    request = connection.request('GET', "/ws/1.1/track.search?apikey=" + musixAPIKey + "&q_lyrics=" +  search , {"host": "api.musixmatch.com", "User-Agent": "NodeJS Client"})
    request.addListener("response", (response) ->
      responseBody = ""
      response.setEncoding("utf8");
      response.addListener("data", (chunk) ->
        responseBody += chunk
      )
      response.addListener("end", ->
        trackID = JSON.parse(responseBody)
        trackID = trackID.message.body.track_list[0].track.track_id
        callback(trackID)
      )
    )
    request.end()
  if opts.lyric?
    connection = http.createClient(80, "api.musixmatch.com")
    request = connection.request('GET', "/ws/1.1/track.lyrics.get?apikey=" + musixAPIKey + "&track_id=" +  opts.lyric + "&format=json" , {"host": "api.musixmatch.com", "User-Agent": "NodeJS Client"})
    request.addListener("response", (response) ->
      responseBody = ""
      response.setEncoding("utf8");
      response.addListener("data", (chunk) ->
        responseBody += chunk
      )
      response.addListener("end", ->
        lyrics = JSON.parse(responseBody)
        lyrics = lyrics.message.body.lyrics.lyrics_body
        callback(lyrics)
      )
    )
    request.end()     
     