console.log("Bootstrapping")

song_template = ->
  autoplay = 0 # 1 is on 0 is off (you dont want this on trust me)
  url = 'http://listen.grooveshark.com/songWidget.swf'
  host = 'cowbell.grooveshark.com'
  style = 'metal' || 'wood' || 'water' || 'grass'
  width = "220" # 150-1000
  height = "40" # must be 40?
  
  div ->
    object width: width, height: height, style: "z-index: -1", class: 'flash', ->
      param name: "movie", value: url
      param name: "wmode", value: "window"
      param name: "allowScriptAccess", value: "always"
      param name: "flashvars", value: "hostname=#{host}&amp;songID=#{@song_id}&amp;style=#{style}&amp;p=#{autoplay}"
      embed src: url, type: "application/x-shockwave-flash", class: 'flash', width: width, height: height, flashvars: "hostname=#{host}&amp;songID=#{@song_id}&amp;style=#{style}&amp;p=#{autoplay}", allowscriptaccess: "always", wmode: "window"

# auto_callback stores the response callback that autoomplete gives us
# initialise to null until we get one from jquery
auto_callback = null

$(document).ready(->
  $("#auto").autocomplete({
    source: (request, response) ->
      console.log 'requesting ' + request.term
      socket.send request.term
      auto_callback = response
      # now we have a response callback from jquery
      # we can call at anytime to give the autocompleter new results
      # when we call it, the autocompleter's data and UI are both updated
  })
)

socket = new io.Socket('localhost', {port: 8000, rememberTransport: false})
socket.on('connect', (-> console.log "connect"))
socket.on('message', (data) -> 
  results = JSON.parse(data)
  console.log JSON.stringify(results)
  
  songs = []
  for song in results
    songs.push song.SongName
  
  if auto_callback
    # since we've intialised the autocompleter we have a callback and can simply call it with our new data
    auto_callback(songs)
  else
    # if for some reason the socket gets data before the autocompleter is initalise (possible but rare)
    false
    
  i = 0
  for result in results
    context = {
      song_name: result.SongName
      song_id: result.SongID
    }
    lambda = ->
      $('body').append(CoffeeKup.render(song_template, context: context))
    setTimeout(lambda, 1500 * i)
    i++
)

socket.on('disconnect', (-> console.log "disconnect"))
socket.connect()