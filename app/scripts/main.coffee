
WIDTH = 320
HEIGHT = 320
SEPARATE_RADIUS = 20
SEPARATE_SPD = 1
SEPARATE_RATE = 0.05
COHERE_SPD = 1
COHERE_RATE = 0.01
ALIGN_RATE = 0.05
ALIGN_RADIUS = 50
ESCAPE_RADIUS = 200
ESCAPE_SPD = 5
ESCAPE_RATE = 0.3
CHASE_RADIUS = 200
CHASE_SPD = 3
CHASE_RATE = 0.01

enchant()

sin = (x) -> Math.sin(x * Math.PI / 180)
cos = (x) -> Math.cos(x * Math.PI / 180)
atan2 = (y,x) -> Math.atan2(y,x)*180/Math.PI
rand = (n) -> Math.floor(Math.random() * n + 1)
mod = (x,m) -> if x < 0 then (x % m + m) else (x % m)
add = (a,b) -> a + b
Array::sum = -> @reduce add, 0
Array::ave = -> if @length is 0 then 0 else @sum() / @length

class Pos
  constructor: (@x,@y) ->
  add: (v) -> @x += v.x; @y += v.y; @
  sub: (v) -> @x -= v.x; @y -= v.y; @

  forward: (pol) ->
    if pol.to_pos.x > 10
      console.log pol.to_pos.x
    @add pol.to_pos()
    @x = mod @x, WIDTH
    @y = mod @y, HEIGHT
    @

  rotate: (th) ->
    x = @x; y = @y
    @x = x * cos(th) - y * sin(th)
    @y = x * sin(th) + y * cos(th)
    @

  to_pol: -> new Pol atan2(@y,@x), Math.sqrt(@x*@x,@y*@y)

class Pol
  constructor: (@th,@r) ->
  to_pos: -> new Pos(cos(@th)*@r, sin(@th)*@r)
  pull: (pol,force) ->
    @r += (pol.r - @r) * force
    dth = mod(@th - pol.th, 360)
    dth -= 360 if dth > 180
    dth += 360 if dth < -180
    @th -= (dth * force)

NORTH = new Pol(270,5)

class Bear extends Sprite
  constructor: (@game) ->
    super(16,16)
    @image = @game.assets['images/delta.png']

    @size = rand(100) / 100
    @opacity = @size
    @scale @size, @size
    @pos = new Pos(rand(WIDTH), rand(HEIGHT))
    @pol = new Pol(rand(360), @size*5)

    @on 'enterframe', ->
      @pos.forward(@pol)
      @pol.pull(NORTH,0.1)
      @x = @pos.x
      @y = @pos.y
      @rotation = @pol.th

    @game.rootScene.addChild this

class Bears extends Array

class MyLabel extends Label
  constructor: (text) ->
    super(text)
    @x = 2
    @y = 2
    @color = "white"
    @font = '14px "Arel"'

window.onload = ->
  game = new Core(WIDTH, HEIGHT)
  game.preload 'images/delta.png'
  game.fps = 30

  game.onload = ->

    bears = new Bears()
    for i in [1..70]
      bears.push new Bear(game)

    label = new MyLabel "++++"
    game.rootScene.addChild label

    game.on 'enterframe', ->
      NORTH.th += 1
      center = (bear.pos for bear in bears).reduce (a,b) -> a.add(b)
      label.text = "#{bears[0].pol.th}"

  game.start()
