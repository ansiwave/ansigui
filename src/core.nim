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

when defined(emscripten):
  from wavecorepkg/client/emscripten import nil

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
  charQueue: Deque[uint32]
  viewHeight*: float

proc onKeyPress*(key: iw.Key) =
  keyQueue.addLast(key)

proc onKeyRelease*(key: iw.Key) =
  discard

proc onChar*(codepoint: uint32) =
  charQueue.addLast(codepoint)

proc onMouseClick*(button: iw.MouseButton) =
  keyQueue.addLast(iw.Key.Mouse)
  iw.gMouseInfo.button = button
  iw.gMouseInfo.action = iw.MouseButtonAction.mbaPressed

proc onMouseMove*(xpos: float, ypos: float) =
  let
    fontHeight = text.monoFont.height * fontMultiplier
    fontWidth = text.blockWidth * fontMultiplier
  iw.gMouseInfo.x = int(xpos / fontWidth)
  iw.gMouseInfo.y = int(ypos / fontHeight)

proc onWindowResize*(windowWidth: int, windowHeight: int, worldWidth: int, worldHeight: int) =
  discard

var clnt: client.Client
clnt = client.initClient(constants.address)
client.start(clnt)
var
  session: bbs.BbsSession
  accessibleText = ""

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
  session = bbs.initSession(clnt)

proc tick*(game: Game): bool =
  glClearColor(constants.bgColor.arr[0], constants.bgColor.arr[1], constants.bgColor.arr[2], constants.bgColor.arr[3])
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.windowWidth), GLsizei(game.windowHeight))

  var finishedLoading = false
  let
    fontHeight = text.monoFont.height * fontMultiplier
    fontWidth = text.blockWidth * fontMultiplier

  var
    termWidth = int(game.worldWidth.float / fontWidth)
    termHeight = int(game.worldHeight.float / fontHeight)

  var
    tb: iw.TerminalBuffer
    rendered = false
  while keyQueue.len > 0 or charQueue.len > 0:
    let
      key = if keyQueue.len > 0: keyQueue.popFirst else: iw.Key.None
      ch = if charQueue.len > 0 and key == iw.Key.None: charQueue.popFirst else: 0
    tb = bbs.render(session, clnt, termWidth, termHeight, (key, ch), finishedLoading)
    rendered = true
  if not rendered:
    tb = bbs.render(session, clnt, termWidth, termHeight, (iw.Key.None, 0'u32), finishedLoading)

  termWidth = iw.width(tb)
  termHeight = iw.height(tb)

  let viewWidth = termWidth.float * fontWidth
  viewHeight = termHeight.float * fontHeight

  result = finishedLoading

  if finishedLoading:
    var e = gl.copy(textEntity)
    text.updateUniforms(e, 0, 0, false)
    for y in 0 ..< termHeight:
      var line: seq[iw.TerminalChar]
      for x in 0 ..< termWidth:
        line.add(tb[x, y])
      discard text.addLine(e, baseEntity, text.monoFont, constants.textColor, line)
    e.project(float(windowWidth), float(windowHeight))
    e.translate(0f, 0f)
    e.scale(fontMultiplier, fontMultiplier)
    render(game, e)

  when defined(emscripten):
    if finishedLoading:
      var text: string
      for y in 0 ..< termHeight:
        for x in 0 ..< termWidth:
          text &= $tb[x, y].ch
        text &= "\n"
      if text != accessibleText:
        emscripten.setInnerHtml("#accessible-text", text)
        accessibleText = text
