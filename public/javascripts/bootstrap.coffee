socket = new io.Socket('localhost', {port: 8000, rememberTransport: false})
console.log("test")

socket.connect()
socket.on('connect', ->)
socket.on('message', ->)
socket.on('disconnect', ->)