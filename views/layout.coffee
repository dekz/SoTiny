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
    
    script src: '/javascripts/support/grooveshark/player.js'
    #script src: 'http://tinysong.com/webincludes/js/player.js'
    #script src: '/javascripts/support/grooveshark/tinysong.js'
    #script src: '/javascripts/support/grooveshark/main.js'
    script src: '/javascripts/support/other/swfobject.js'
    
    script src: '/javascripts/support/yabble/yabble.js'
    
    coffeescript (->
      require.setModuleRoot 'javascripts/'
      require.run 'bootstrap'
    )
#this caused it to load layout twice and connect twice
#  body id: 'layout', ->
 #   @body
  body ->
    section ->
      h1 @title
          
      input id: "auto"