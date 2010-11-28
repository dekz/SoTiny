(function() {
  var Result, SearchBox, lastSearch, results, searchBox, socket;
  console.log("Bootstrapping");
  this.player = new jsPlayer();
  this.player.playSong("21879031");
  Result = function() {
    function Result() {
      this.element = $(".log");
      true;
    }
    Result.prototype.addElement = function(element) {
      return this.element.appendChild(element);
    };
    Result.prototype.update = function() {
      return this.element.value = "updated";
    };
    return Result;
  }();
  SearchBox = function() {
    function SearchBox() {
      this.element = document.getElementById('search');
      true;
    }
    SearchBox.prototype.getText = function() {
      return this.element.value;
    };
    return SearchBox;
  }();
  searchBox = new SearchBox();
  results = new Result();
  lastSearch = searchBox.getText();
  socket = new io.Socket('localhost', {
    port: 8000,
    rememberTransport: false
  });
  socket.connect();
  socket.on('connect', (function() {
    return console.log("connect");
  }));
  socket.on('message', function(data) {
    var content, messageElement, result, song, _i, _len, _results;
    $(".log").empty();
    result = JSON.parse(data);
    _results = [];
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      song = result[_i];
      messageElement = $(document.createElement("table"));
      content = '<tr> <td class="msg-text">' + song.SongName + '</td>' + '</tr>';
      messageElement.html(content);
      _results.push($(".log").append(messageElement));
    }
    return _results;
  });
  socket.on('disconnect', (function() {
    return console.log("disconnect");
  }));
  setInterval((function() {
    if (!(lastSearch === searchBox.getText())) {
      socket.send(searchBox.getText());
    }
    return lastSearch = searchBox.getText();
  }), 500);
  $(document).ready(function() {});
}).call(this);
