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
    var lyrics, song, songs, _i, _len, _ref;
    console.log(data);
    songs = [];
    lyrics = [];
    if (data.songs != null) {
      _ref = data.songs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        song = _ref[_i];
        songs.push(song.SongName);
        console.log("have some songs");
      }
    }
    if (data.lyrics != null) {
      console.log("have some lyrics");
      console.log(data.lyrics);
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
        var reply;
        reply = {};
        reply.search = request.term;
        console.log('requesting ' + request.term);
        socket.send(reply);
        return auto_callback = response;
      }
    });
  });
}).call(this);
