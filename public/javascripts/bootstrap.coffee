console.log("Bootstrapping")

# @player = new jsPlayer()
# @player.playSong("21879031")

socket = new io.Socket('localhost', {port: 8000, rememberTransport: false})
socket.connect()

auto_callback = null

socket.on('connect', (-> console.log "connect"))
socket.on('message', (data) -> 
  result = JSON.parse(data)
  console.log JSON.stringify(result)
  
  songs = []
    
  for song in result
    songs.push song.SongName
  
  if auto_callback
    auto_callback(songs)
)

socket.on('disconnect', (-> console.log "disconnect"))

$(document).ready(->
  jQuery("#auto").autocomplete({
    source: (request, response) ->
      console.log 'requesting ' + request.term
      socket.send request.term
      auto_callback = response
  })
)