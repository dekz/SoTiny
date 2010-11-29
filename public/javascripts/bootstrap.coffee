console.log("Bootstrapping")

# @player = new jsPlayer()
# @player.playSong("21879031")

socket = new io.Socket('localhost', {port: 8000, rememberTransport: false})
socket.connect()

auto_callback = null

socket.on('connect', (-> console.log "connect"))
socket.on('message', (data) -> 
  console.log data
  #result = JSON.parse(data.songs)

  songs = []
  lyrics = []
  
  if data.songs?
    for song in data.songs
      songs.push song.SongName
      console.log "have some songs"
  
  if data.lyrics?
    console.log "have some lyrics"
    console.log data.lyrics
  
  if auto_callback
    auto_callback(songs)
)

socket.on('disconnect', (-> console.log "disconnect"))

$(document).ready(->
  jQuery("#auto").autocomplete({
    source: (request, response) ->
      reply = {}
      reply.search = request.term
      console.log 'requesting ' + request.term
      socket.send reply
      auto_callback = response
  })
)