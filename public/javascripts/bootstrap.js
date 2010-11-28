(function() {
  var auto_callback, socket;
  console.log("Bootstrapping");
  socket = new io.Socket('localhost', {
    port: 8000,
    rememberTransport: false
  });
  socket.connect();
  auto_callback = null;
  socket.on('connect', (function() {
    return console.log("connect");
  }));
  socket.on('message', function(data) {
    var result, song, songs, _i, _len;
    result = JSON.parse(data);
    console.log(JSON.stringify(result));
    songs = [];
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      song = result[_i];
      songs.push(song.SongName);
    }
    if (auto_callback) {
      return auto_callback(songs);
    }
  });
  socket.on('disconnect', (function() {
    return console.log("disconnect");
  }));
  $(document).ready(function() {
    return jQuery("#auto").autocomplete({
      source: function(request, response) {
        console.log('requesting ' + request.term);
        socket.send(request.term);
        return auto_callback = response;
      }
    });
  });
}).call(this);
