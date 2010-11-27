Cortex = require('cortex/cortex').Cortex
Cortex.Client = require('cortex/client').Client
Cortex.Worker = require('cortex/worker').Worker

Li = require('li/li').Li
Li.Camera = require('li/camera').Camera
Li.Line = require('li/line').Line
Li.Plane = require('li/plane').Plane
Li.Program = require('li/program').Program
Li.Shader = require('li/shader').Shader
# Li.Terrain = require('li/terrain').Terrain
Li.Triangle = require('li/triangle').Triangle
Li.Viewport = require('li/viewport').Viewport
Li.Cube = require('li/cube').Cube
Li.Keys = require('li/keys').Keys
Li.Instancer = require('li/instancer').Instancer
Li.Sampler = require('li/sampler').Sampler
Li.Chunk = require('li/chunk').Chunk

class Hud
  constructor: ->
    @element = document.getElementById 'hud_hook'
    true
    
  update: ->
    @element.innerText = "#{window.cubes} cubes \n #{window.vertices} vertices \n #{window.chunks} chunks \n camera_position: #{window.camera.position[0].toFixed(2)}, #{window.camera.position[1].toFixed(2)}, #{window.camera.position[2].toFixed(2)} \n a, b, c -> 16, 32, 16 \n workers -> #{window.workers}"

hud = new Hud()

setInterval((->
  hud.update()
  # window.socket.send(JSON.stringify({position: window.camera.position, rotation: window.camera.rotation}))
), 250)

gl = null

$(document).ready(->
  cortex = window.cortex = new Cortex
  client = window.cortex.client = new Cortex.Client cortex: cortex, guid: null
  
  li = window.li = new Li {
    model_view: null
    projection: null
    viewports: []
    client: client
    objects: []
    textures: []
    hud: hud
  }
  
  client.li = li
  
  li.canvas = document.getElementById 'cortex_canvas'
  gl = li.canvas.getContext 'experimental-webgl'
  window.gl = gl
  li.gl = gl
  
  gl.clearColor 0.0, 0.0, 0.0, 0.0
  gl.clearDepth 1.0

  gl.enable gl.DEPTH_TEST
  gl.depthFunc gl.LEQUAL
  
  # gl.enable gl.CULL_FACE
  # gl.cullFace gl.CCW
  
  $(li.canvas).attr 'width', $(window).width() 
  $(li.canvas).attr 'height', $(window).height()
    
  # instancer = li.instancer = new Li.Instancer instances: [], mesh: cube, li: li
  # li.objects.push instancer
  
  # socket = window.socket = new io.Socket null, port: 1337
  # # # 
  # # 
  # # # 
  # socket.on 'connect', (message) =>
  #   # payload = JSON.parse(message)
  #   console.log 'connected'
  # #   
  # socket.on 'message', (message) =>
  #   payload = JSON.parse(message)
  #   console.log message
  #   # console.log 'updating moon'
  #   if payload.position
  #     console.log 'updating moon'
  #     li.moon.position = payload.position
  #     li.moon.rotation = payload.rotation
  # # 
  # socket.connect()
  # `
  # window.socket = new io.Socket(); 
  # socket = window.socket;
  # socket.on('connect', function(){ 
  #   // socket.send('hi!'); 
  # });
  # socket.on('message', function(data){ 
  #   console.log(data);
  # });
  # socket.on('disconnect', function(){});
  # `
  
  #   
  #   if payload.client
  #     @guid = payload.client.guid
  #     console.log 'got guid ' + @guid
  #     
  #   if payload.world
  #     # li.world = payload.world
  #     # console.log 'world loaded'
  #     z = 50
  #     li.world = []
  #     for [i, j, k] in payload.world
  #       li.world[(((i * z) + k) * 20) + j] = true
  #     
  #   if payload.tick      
  #     socket.send JSON.stringify
  #       tock: true
  #       client:
  #         position: client.position
  #   
  #   if payload.job
  #     console.log 'got job ' + payload.job
  #     if payload.task is 'resample'
  #       sampler = new Li.Sampler {
  #         src: payload.src
  #         i: payload.i
  #         j: payload.j
  #         callback: (data) ->
  #           console.log 'sending back ' + payload.task + ' job results'
  #           socket.send JSON.stringify({result: data})
  #       }
    
  # preset_map = [presets.top, presets.left, presets.front, presets.home]
  li.model_view_stack = 
  li.push = (m) ->
    if m
      li.stack.push m.dup()
      li.model_view = m.dup()
    else
      li.model_view_stack.push li.model_view.dup()
  
  li.cameras = []
  
  window.camera = camera = new Li.Camera
    position: [0, 2.7, 10]
    aspect_ratio: li.canvas.width / li.canvas.height
    # target: presets.origin
    li: li
    yaw: -Math.PI
    pitch: 0 #-Math.PI*2
    roll: 0
  
  li.cameras.push camera
  
  li.viewports = []
  
  viewport = {
    x: 0 # li.canvas.width
    y: 0 # li.canvas.height
    width: $(window).width()
    height: $(window).height()
    camera: camera
  }
  li.viewports.push viewport
  gl.viewport 0, 0, li.canvas.width, li.canvas.height
  
  li.projection = M4x4.makePerspective 45, viewport.camera.aspect_ratio, 0.1, 1000.0
  
  resize = ->
    console.log 'resize'
    $(li.canvas).attr 'width', $(window).width()
    $(li.canvas).attr 'height', $(window).height()
    
    for viewport in li.viewports
      viewport.width = $(window).width()
      viewport.height = $(window).height()
      viewport.aspect_ratio = viewport.width / viewport.height
  
  $(window).resize =>
    resize()
    
  li.haveTexture = (texture) ->
    li.textures.push texture

    gl.bindTexture gl.TEXTURE_2D, texture
    gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST)
    gl.generateMipmap(gl.TEXTURE_2D)
    
    gl.bindTexture gl.TEXTURE_2D, null
  
  li.loadTextures = ->
    li.texture = gl.createTexture()
    li.texture.image = new Image
    li.texture.image.onload = ->
      li.haveTexture(li.texture)
      li.callback 'texture'

    li.texture.image.src = "/images/blocks.png"
    
    # li.callback 'texture'
  
  li.callbacks = {}
  li.callback = (handle) ->
    li.callbacks[handle] = true

    # console.log handle
    if li.callbacks.program and not li.callbacks.texture
      li.loadTextures()
      
      # textureWidth = 512
      # textureCanvas = document.getElementById("texture")
      # # textureCanvas = document.createElement("canvas")
      # textureCanvas.width = textureCanvas.height = textureWidth
      # textureContext = textureCanvas.getContext("2d")
      # textureImage = textureContext.createImageData(textureWidth, textureWidth)
      # for i in [0...textureWidth]
      #   for j in [0...textureWidth]
      #     index = (j * textureWidth + i) * 4
      #     textureImage.data[index + 0] = i
      #     textureImage.data[index + 1] = Math.floor((i + j) / 2)
      #     textureImage.data[index + 2] = j
      #     textureImage.data[index + 3] = 255
      # textureContext.putImageData(textureImage, 0, 0)
      # 
      # li.textures = li.textures || []
      # li.textures[0] = gl.createTexture()
      # gl.activeTexture(gl.TEXTURE0)
      # gl.bindTexture(gl.TEXTURE_2D, li.texture)
      # # gl.texImage2D(gl.TEXTURE_2D, 0, textureCanvas)
      # gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, textureCanvas
      # gl.generateMipmap(gl.TEXTURE_2D)
      # 
      # li.callback 'texture'
      
    else if li.callbacks.program and li.callbacks.texture
      li.init()
      
  li.chunks = []
  
  li.programs = {}
  li.programs.master = new Li.Program
    handle: 'color'
    gl: window.gl
    li: li
    callback: -> ( li.callback('program') )
    
  # li.map = {
  #   0: [Math.random() * 0.25, Math.random() * 0.25, Math.max(0.75, Math.random()), 1] # water
  #   1: [Math.max(Math.min(Math.random(), 0.9), 0.75), Math.max(Math.min(Math.random(), 0.9), 0.75), Math.random() * 0.25, 1] # beach
  #   2: [Math.random() / 4, Math.random() / 4, Math.random() / 4, 1] # rock
  #   3: [Math.random() * 0.1, Math.max(Math.random(), 0.9), Math.random() * 0.1, 1] # forest
  #   4: [Math.max(Math.min(Math.random(), 0.9), 0.75), Math.max(Math.min(Math.random(), 0.9), 0.75), Math.random() * 0.25, 1] # desert
  #   5: [Math.max(Math.min(Math.random(), 0.9), 0.75), Math.max(Math.min(Math.random(), 0.9), 0.75), Math.random() * 0.25, 1] # desert
  #   6: [Math.random() / 2, Math.random() / 2, Math.random() / 2, 1] # mountain
  #   7: [Math.max(Math.random(), 0.5),Math.max(Math.random(), 0.5), Math.max(Math.random(), 0.5), 1] # flats
  #   8: [Math.max(Math.random(), 0.5),Math.max(Math.random(), 0.5), Math.max(Math.random(), 0.5), 1] # alpine
  #   9: [1, 1, 1, 1] # snow
  # }
  
  li.init = =>    
    # li.objects.push new Li.Triangle
    #   gl: gl
    #   li: li

    li.line = new Li.Line
      gl: gl
      li: li
      
    li.objects.push li.line
    #   
    # li.objects.push new Li.Line
    #   gl: gl
    #   li: li
    #   a: [0, 0, 0]
    #   b: [0, 0, 1]
    #   color: [0, 1, 0, 1]
    #   
    # li.objects.push new Li.Line
    #   gl: gl
    #   li: li
    #   a: [0, 0, 0]
    #   b: [0, 1, 0]
    #   color: [0, 0, 1, 1]
    
    gl.uniformMatrix4fv li.programs.master.uniforms.projection, false, li.projection
    
    # sun = new Li.Cube {
    #   gl: gl
    #   li: li
    #   position: [0, 0, 0]
    #   color: [0, 0, 0, 1]
    #   # update: ->
    #   #   @position[0] = Math.sin(window.time / 1000) * 10
    #   #   @position[2] = Math.cos(window.time / 1000) * 10
    #   # scale: 1
    # }
    # li.objects.push sun
    # 
    moon = new Li.Cube {
      gl: gl
      li: li
      position: [0, 2, 0]
      rotation: [0, 0, 0]
      # color: [0, 0, 0, 1]
      # update: ->
      #   @position[0] = Math.sin(window.time / 1000) * 10
      #   @position[2] = Math.cos(window.time / 1000) * 10
      # scale: 1
    }
    li.objects.push moon
    li.moon = moon
    
    window.cubes = 0
    window.chunks = 0
    window.vertices = 0
    window.workers = 0
    
    positions = []
    for i in [-4...4]
      for j in [-4...4]
        positions.push [i, 0, j]
        
    # for i in [0...8]
    #   for j in [0...8]
    #     positions.push [i, 1, j]
    
    fetch = (callback, i) ->
      position = positions[i]
      worker = new Worker('/javascripts/worker.js')
      worker.postMessage(position)
      window.workers++
      worker.onmessage = (message_event) ->
        # debugger
        chunk = new Li.Chunk {
          li: li
          position: position
          vertices: message_event.data.vertices
          colors: message_event.data.colors
          indices: message_event.data.indices
          coords: message_event.data.coords
          normals: message_event.data.normals
          cubes: message_event.data.cubes
        }
        li.objects.push chunk
        window.cubes += chunk.cubes
        window.vertices += chunk.vertices.length
        # console.log window.cubes + ' cubes'
        # z = position[2]
        # x = position[0]
        window.chunks++
        window.workers--
        
    # if i < 64
    # setTimeout((-> (fetch(i+1))), 250)
    # callback(i)
          
    # fetch_four = (i) ->
    #   callbacks = []
    #   callback = (index) ->
    #     callbacks[index] = true
    #     done = true
    #     for z in [0...2]
    #       done = done and callbacks[i + z]
    #     if done and i < 128
    #       setTimeout((-> fetch_four(i + 2)), 250)
      
    # fetch(callback, i)
    # fetch(callback, i + 1)
    # fetch(callback, i + 2)
    # fetch(callback, i + 3)
    # for z in [0...2]
    # fetch(callback, i + z)
    
    for i in [0...64]
      setTimeout((=>
        fetch((-> true), i)
        # fetch((-> true), i + 1)
      ), i * 100)
      
    # for i in [1...4]
    # for j in [1...4]
        
    # window.cubes = 0
    # for i in [1...4]
    #   for j in [1...4]
    #     world = new Li.World {
    #       li: li
    #       position: [i, 0, j]
    #     }
    #     li.objects.push world
    #     
    # window.cubes = 0
    # for i in [5...8]
    #   for j in [5...8]
    #     world = new Li.World {
    #       li: li
    #       position: [i, 0, j]
    #     }
    #     li.objects.push world
    
    # for i in [0...16] by 4
    #   for j in [0...16]
    #     world = new Li.World {
    #       li: li
    #       position: [i, 0, j]
    #       road: true
    #     }
    #     li.objects.push world
    # for i in [0...16]
    #   for j in [0...16] by 4
    #     world = new Li.World {
    #       li: li
    #       position: [i, 0, j]
    #       road: true
    #     }
    #     li.objects.push world
        
    # console.log window.cubes + ' cubes'
    

    # window.delta = 0
    window.frames = 0
    
    setInterval((=>
      console.log window.frames
      window.frames = 0
    ), 1000)
    
    # setInterval((=>
      # console.log window.frames
      # window.frames = 0
    # ), 1000)
    
    setInterval((=>
      # debugger
      #update
      window.frames++
      
      if window.time? and window.previous_time?
        time = Date.now()
        window.delta = time - window.previous_time
        window.time += window.delta
        
        window.previous_time = time
        # console.log "time: #{window.time}, delta: #{window.delta}"
      else
        window.time = 0
        window.previous_time = Date.now()
      
      # li.update()
      
      viewport.camera.update { delta: window.delta, time: window.time }
      
      #draw
      
      gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    
      # # li.model_view: M4x4.makeTranslate @camera.position
      # li.model_view = M4x4.makeLookAt viewport.camera.position, Li.Camera.presets.origin, V3.y
      # li.model_view = M4x4.I
      # li.model_view = M4x4.rotate viewport.camera.rotation[0], -V3.x, li.model_view
      # li.model_view = M4x4.rotate viewport.camera.rotation[1], V3.y, li.model_view
      # li.model_view = M4x4.rotate viewport.camera.rotation[3], V3.z, li.model_view
      
      # li.model_view = M4x4.mul(M4x4.translate V3.neg(viewport.camera.position), li.model_view, 
    
      # here model_view is the camera looking at a pitch yaw and roll
            
      for object in li.objects
        object.draw()
    ), 15)
)