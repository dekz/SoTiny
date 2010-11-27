doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title "#{@title} | GroovyList"
    meta(name: 'description', content: @description) if @description?
    link rel: 'stylesheet', href: '/stylesheets/style.css'
    
    link rel: 'stylesheet', href: '/stylesheets/jquery/smoothness/jquery-ui-1.8.5.custom.css'
    script src: '/javascripts/support/jquery/jquery-1.4.2.min.js'
    script src: '/javascripts/support/jquery/jquery-ui-1.8.6.custom.min.js'
    script src: '/javascripts/support/socket.io/socket.io.js'
    script src: '/javascripts/support/yabble/yabble.js'

    
    coffeescript (->
      require.setModuleRoot 'javascripts/'
      require.run 'bootstrap'
    )

  body id: 'layout', ->
    @body