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
	console.log "test"
	#console.log data
	result = JSON.parse(data)
	for song in result
		console.log song.SongName
		messageElement = $(document.createElement("table"))
		#messageElement.addClass("message")
		content = '<tr> <td class="msg-text">' + song.SongName  + '</td>' + '</tr>'
		messageElement.html(content)
		$(".log").append(messageElement)	
		#results.addElement(messageElement)
)

socket.on('disconnect', (-> console.log "disconnect"))

setInterval((->
	socket.send(searchBox.getText()) if !(lastSearch == searchBox.getText())
	lastSearch = searchBox.getText()
), 500)

$(document).ready(->

)