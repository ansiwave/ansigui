import nimgl/opengl
import paranim/gl, paranim/gl/entities
from glm import vec4
from ./text import nil
from paratext/gl/text as ptext import nil
from ./constants import nil
import deques

#from ansiwavepkg/chafa import nil
from ansiwavepkg/bbs import nil
from ansiwavepkg/illwill as iw import `[]`, `[]=`
import unicode

from wavecorepkg/client import nil
from os import joinPath

type
  Game* = object of RootGame
    deltaTime*: float
    totalTime*: float
    windowWidth*: int32
    windowHeight*: int32
    worldWidth*: int32
    worldHeight*: int32
    mouseX*: float
    mouseY*: float

var
  baseEntity: ptext.UncompiledTextEntity
  textEntity: text.AnsiwaveTextEntity
  fontMultiplier = 1/4
  keyQueue: Deque[iw.Key]

proc onKeyPress*(key: iw.Key) =
  keyQueue.addLast(key)

proc onKeyRelease*(key: iw.Key) =
  discard

proc onMouseClick*(button: iw.MouseButton) =
  keyQueue.addLast(iw.Key.Mouse)
  iw.gMouseInfo.button = button
  iw.gMouseInfo.action = iw.MouseButtonAction.mbaPressed

proc onMouseMove*(xpos: float, ypos: float) =
  let
    fontHeight = text.monoFont.height * fontMultiplier
    fontWidth = fontHeight / 2
  iw.gMouseInfo.x = int(xpos / fontWidth)
  iw.gMouseInfo.y = int(ypos / fontHeight)

proc onWindowResize*(windowWidth: int, windowHeight: int, worldWidth: int, worldHeight: int) =
  discard

var clnt: client.Client
clnt = client.initClient(constants.address)
client.start(clnt)
var session = bbs.initSession(clnt)

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  baseEntity = ptext.initTextEntity(text.monoFont)
  textEntity = compile(game, text.initInstancedEntity(baseEntity, text.monoFont))

  #const img = staticRead("aintgottaexplainshit.jpg")
  #echo chafa.imageToAnsi(img, 80)

proc tick*(game: Game): bool =
  glClearColor(constants.bgColor.arr[0], constants.bgColor.arr[1], constants.bgColor.arr[2], constants.bgColor.arr[3])
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.windowWidth), GLsizei(game.windowHeight))

  let
    fontHeight = text.monoFont.height * fontMultiplier
    fontWidth = fontHeight / 2
    windowWidth = int(game.worldWidth.float / fontWidth)
    windowHeight = int(game.worldHeight.float / fontHeight)
    key = if keyQueue.len > 0: keyQueue.popFirst else: iw.Key.None
  var finishedLoading = false
  let tb = bbs.render(session, clnt, windowWidth, windowHeight, key, finishedLoading)

  result = finishedLoading and keyQueue.len == 0

  if finishedLoading:
    var e = gl.copy(textEntity)
    text.updateUniforms(e, 0, 0, false)
    for y in 0 ..< windowHeight:
      var line: seq[iw.TerminalChar]
      for x in 0 ..< windowWidth:
        line.add(tb[x, y])
      discard text.addLine(e, baseEntity, text.monoFont, constants.textColor, line)
    e.project(float(game.worldWidth), float(game.worldHeight))
    e.translate(0f, 0f)
    e.scale(fontMultiplier, fontMultiplier)
    render(game, e)

