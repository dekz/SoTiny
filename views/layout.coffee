doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title "#{@title} | GroovyList"
    meta(name: 'description', content: @description) if @description?
    link rel: 'stylesheet', href: '/stylesheets/style.css'
    #link rel: 'stylesheet', href: '/javascripts/support/autosuggest/autoSuggest.css'
    
    link rel: 'stylesheet', href: '/stylesheets/jquery/smoothness/jquery-ui-1.8.5.custom.css'
    script src: '/javascripts/support/jquery/jquery-1.4.2.min.js'
    script src: '/javascripts/support/jquery/jquery-ui-1.8.6.custom.min.js'
    script src: '/javascripts/support/socket.io/socket.io.js'
    script src: '/javascripts/support/jquery/jquery.autocomplete.js'
    #script src: '/javascripts/support/autosuggest/jquery.autoSuggest.packed.js'
    script src: '/javascripts/support/grooveshark/player.js'
    #script src: 'http://tinysong.com/webincludes/js/player.js'
 #   script src: '/javascripts/support/grooveshark/tinysong.js'
#    script src: '/javascripts/support/grooveshark/main.js'
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
      # form action: '/', method 'post', ->
      #   div class: 'field', ->
      #     label for: 'search', -> 'Search:'
      #     input id: 'search', name: 'search'

      input id: 'search', name: 'search', autocomplete: false
      div class: 'log', ->
        'test log div'
        #table class: 'message'
    
    