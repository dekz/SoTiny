doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title "#{@title} | GroovyList"
    meta(name: 'description', content: @description) if @description?
    link rel: 'stylesheet', href: '/stylesheets/style.css'
    
    link href: "/jquery/css/ui-lightness/jquery-ui-1.8.6.custom.css", rel: "stylesheet"
    script src: "/jquery/js/jquery-1.4.2.min.js"
    script src: "/jquery/js/jquery-ui-1.8.6.custom.min.js"
		
    script src: '/javascripts/support/socket.io/socket.io.js'
    
    # script src: '/javascripts/support/grooveshark/player.js'
    #script src: 'http://tinysong.com/webincludes/js/player.js'
    #script src: '/javascripts/support/grooveshark/tinysong.js'
    #script src: '/javascripts/support/grooveshark/main.js'
    # script src: '/javascripts/support/other/swfobject.js'
    
    script src: '/javascripts/support/coffee-script/coffee-script.js'
    script src: '/javascripts/support/coffeekup/coffeekup.js'
    
    script src: '/javascripts/support/yabble/yabble.js'
    
    coffeescript (->
      require.setModuleRoot 'javascripts/'
      require.run 'bootstrap'
      
      $(document).ready(->
        $('#monster').click(->
          $('#auto').val('monster')
          $('#auto').autocomplete('search', 'monster') #sigh, just setting the value isnt enough
        )
      )
    )
#this caused it to load layout twice and connect twice
#  body id: 'layout', ->
 #   @body
  body ->
    # h1 @title
        
    input id: "auto"
    a id: 'monster', href: '#', -> 'the automatic - monster'