(function() {
  var Result, SearchBox, lastSearch, results, searchBox, socket, valueData;
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
  valueData = [
    {
      "Url": "http://tinysong.com/fQKz",
      "SongID": 7499379,
      "SongName": "Hollow Bones",
      "ArtistID": 401591,
      "ArtistName": "Wu-Tang Clan",
      "AlbumID": 1121549,
      "AlbumName": "The W"
    }, {
      "Url": "http://tinysong.com/weeX",
      "SongID": 26103091,
      "SongName": "Florida (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/wslt",
      "SongID": 26103082,
      "SongName": "Beatin (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/weiQ",
      "SongID": 26103078,
      "SongName": "Everything (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/whgM",
      "SongID": 26103076,
      "SongName": "Dro (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/wg2B",
      "SongID": 26103071,
      "SongName": "Spaceship (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/weVS",
      "SongID": 26103070,
      "SongName": "What It Is (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/wfii",
      "SongID": 26103066,
      "SongName": "Hit The Sky (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/whLj",
      "SongID": 26103061,
      "SongName": "Loose Cannon (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }, {
      "Url": "http://tinysong.com/wfi6",
      "SongID": 26103056,
      "SongName": "Goin Crazy (w/ skit)",
      "ArtistID": 1356458,
      "ArtistName": "Tay Dizm",
      "AlbumID": 4689648,
      "AlbumName": "Point Em Out: The Mixtape (w/ skit)"
    }
  ];
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
    valueData = JSON.stringify(valueData);
    $("#search}").unbind(".autocomplete");
    $("#search").autocomplete(valueData, {
      minChars: 0,
      width: 310,
      matchContains: "word",
      autoFill: false,
      formatItem: function(row, i, max) {
        return i + "/" + max + ": \"" + row.SongName + "\" [" + row.ArtistName + "]";
      },
      formatMatch: function(row, i, max) {
        return row.SongName + " " + row.ArtistName;
      },
      formatResult: function(row) {
        return row.SongName;
      }
    });
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
  $(document).ready(function() {
    return $("#search").autocomplete(valueData, {
      minChars: 0,
      width: 310,
      matchContains: "word",
      autoFill: false,
      formatItem: function(row, i, max) {
        return i + "/" + max + ": \"" + row.SongName + "\" [" + row.ArtistName + "]";
      },
      formatMatch: function(row, i, max) {
        return row.SongName + " " + row.ArtistName;
      },
      formatResult: function(row) {
        return row.SongName;
      }
    });
  });
}).call(this);
