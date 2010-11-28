console.log("Bootstrapping")

@player = new jsPlayer()
@player.playSong("21879031")

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

# data = {items: [
#   {value: "21", name: "Mick Jagger"},
#   {value: "43", name: "Johnny Storm"},
#   {value: "46", name: "Richard Hatch"},
#   {value: "54", name: "Kelly Slater"},
#   {value: "55", name: "Rudy Hamilton"},
#   {value: "79", name: "Michael Jordan"}
#   ]}

# valueData = [
#   {SongName: "Welcome Home", ArtistName: "Coheed and Cambria"},
#   {SongName: "Once Upon Your Dead Body"},
#   {SongName: "Jacob"},
#   {SongName: "Test2"},
#   {SongName: "Test3"},
#   {SongName: "Test4"}
#   ]

valueData = [{"Url":"http://tinysong.com/fQKz","SongID":7499379,"SongName":"Hollow Bones","ArtistID":401591,"ArtistName":"Wu-Tang Clan","AlbumID":1121549,"AlbumName":"The W"},{"Url":"http://tinysong.com/weeX","SongID":26103091,"SongName":"Florida (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/wslt","SongID":26103082,"SongName":"Beatin (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/weiQ","SongID":26103078,"SongName":"Everything (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/whgM","SongID":26103076,"SongName":"Dro (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/wg2B","SongID":26103071,"SongName":"Spaceship (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/weVS","SongID":26103070,"SongName":"What It Is (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/wfii","SongID":26103066,"SongName":"Hit The Sky (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/whLj","SongID":26103061,"SongName":"Loose Cannon (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"},{"Url":"http://tinysong.com/wfi6","SongID":26103056,"SongName":"Goin Crazy (w/ skit)","ArtistID":1356458,"ArtistName":"Tay Dizm","AlbumID":4689648,"AlbumName":"Point Em Out: The Mixtape (w/ skit)"}]

searchBox = new SearchBox()
results = new Result()
lastSearch = searchBox.getText()


socket = new io.Socket('localhost', {port: 8000, rememberTransport: false})
socket.connect()

socket.on('connect', (-> console.log "connect"))
socket.on('message', (data) -> 
  $(".log").empty()
  result = JSON.parse(data)
  valueData = result
  console.log JSON.stringify(valueData)
  $("#search}").unbind(".autocomplete")

  $("#search").autocomplete(valueData, {
          minChars: 0,
          width: 310,
          matchContains: "word",
          autoFill: false,
          formatItem: (row, i, max) ->
            return i + "/" + max + ": \"" + row.SongName + "\" [" + row.ArtistName + "]"
          formatMatch: (row, i, max) ->
            return row.SongName + " " + row.ArtistName
          formatResult: (row) ->
            return row.SongName
    })
    
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
  #$("input").autoSuggest(valueData, {selectedItemProp: "SongName", searchObjProps: "SongName", selectedValuesProp: "SongName", startText: "", neverSubmit: true})
  #$("#search").autocomplete(valueData)
  $("#search").autocomplete(valueData, {
          minChars: 0,
          width: 310,
          matchContains: "word",
          autoFill: false,
          formatItem: (row, i, max) ->
            return i + "/" + max + ": \"" + row.SongName + "\" [" + row.ArtistName + "]"
          formatMatch: (row, i, max) ->
            return row.SongName + " " + row.ArtistName
          formatResult: (row) ->
            return row.SongName
    })
  
)