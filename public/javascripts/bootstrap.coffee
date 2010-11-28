console.log("Bootstrapping")



class Result
  constructor: ->
    @element = $(".log")
    true
  
  addElement: (element) ->
    @element.appendChild(element)
      
  update: ->
    @element.value = "updated"

class SearchBox
  constructor: ->
    @element = document.getElementById 'search'
    true
    
  getText: ->
    return @element.value

searchBox = new SearchBox()
results = new Result()
lastSearch = searchBox.getText()


socket = new io.Socket('localhost', {port: 8000, rememberTransport: false})
socket.connect()

socket.on('connect', (-> console.log "connect"))
socket.on('message', (data) -> 
  $(".log").empty()
  result = JSON.parse(data)
  for song in result
    messageElement = $(document.createElement("table"))
    content = '<tr> <td class="msg-text">' + song.SongName  + '</td>' + '</tr>'
    messageElement.html(content)
    $(".log").append(messageElement)  
)

socket.on('disconnect', (-> console.log "disconnect"))

setInterval((->
  socket.send(searchBox.getText()) if !(lastSearch == searchBox.getText())
  lastSearch = searchBox.getText()
), 500)

$(document).ready(->

)