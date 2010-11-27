(function() {
  var socket;
  socket = new io.Socket('localhost', {
    port: 8000,
    rememberTransport: false
  });
  console.log("test");
  socket.connect();
  socket.on('connect', function() {});
  socket.on('message', function() {});
  socket.on('disconnect', function() {});
}).call(this);
