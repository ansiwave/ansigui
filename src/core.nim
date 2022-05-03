import paranim/opengl
import paranim/gl, paranim/gl/entities
from paranim/glm import vec4
from ./text import nil
from paratext/gl/text as ptext import nil
from ./constants import nil
import deques
from wavecorepkg/paths import nil
from strutils import nil
import tables

from ansiwavepkg/bbs import nil
from ansiwavepkg/illwill as iw import `[]`, `[]=`
from ansiwavepkg/codes import nil

from wavecorepkg/client import nil

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
  clnt: client.Client
  session*: bbs.BbsSession
  accessibleText = ""
  baseEntity: ptext.UncompiledTextEntity
  textEntity: text.AnsiwaveTextEntity
  fontMultiplier* = 1/4
  keyQueue: Deque[(iw.Key, iw.MouseInfo)]
  charQueue: Deque[uint32]
  viewHeight*: int32
  maxViewSize*: int32
  pixelDensity*: float
  failAle*: bool

proc fontWidth*(): float =
  text.blockWidth * fontMultiplier

proc fontHeight*(): float =
  text.monoFont.height * fontMultiplier

proc onKeyPress*(key: iw.Key) =
  keyQueue.addLast((key, iw.gMouseInfo))

proc onKeyRelease*(key: iw.Key) =
  discard

proc onChar*(codepoint: uint32) =
  charQueue.addLast(codepoint)

proc onMouseClick*(button: iw.MouseButton, action: iw.MouseButtonAction) =
  iw.gMouseInfo.button = button
  iw.gMouseInfo.action = action
  keyQueue.addLast((iw.Key.Mouse, iw.gMouseInfo))

proc onMouseUpdate*(xpos: float, ypos: float) =
  iw.gMouseInfo.x = int(xpos / fontWidth() - 0.25)
  iw.gMouseInfo.y = int(ypos / fontHeight() - 0.25)

proc onMouseMove*(xpos: float, ypos: float) =
  onMouseUpdate(xpos, ypos)
  if iw.gMouseInfo.action == iw.MouseButtonAction.mbaPressed and bbs.isEditor(session):
    keyQueue.addLast((iw.Key.Mouse, iw.gMouseInfo))

proc onWindowResize*(windowWidth: int, windowHeight: int) =
  discard

proc init*(game: var Game) =
  clnt = client.initClient(paths.address, paths.postAddress)
  client.start(clnt)

  bbs.init()

  var hash: Table[string, string]
  if "board" notin hash:
    hash["board"] = paths.defaultBoard

  # this must be done before the gl stuff
  # that way, it will initialize even if the gl stuff fails
  session = bbs.initBbsSession(clnt, hash)

  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  baseEntity = ptext.initTextEntity(text.monoFont)
  textEntity = compile(game, text.initInstancedEntity(baseEntity, text.monoFont))

proc tick*(game: Game): bool =
  glClearColor(constants.bgColor.arr[0], constants.bgColor.arr[1], constants.bgColor.arr[2], constants.bgColor.arr[3])
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.windowWidth), GLsizei(game.windowHeight))

  var finishedLoading = false
  let
    fontWidth = fontWidth()
    fontHeight = fontHeight()

  var
    termWidth = int(game.windowWidth.float / fontWidth)
    termHeight = int(game.windowHeight.float / fontHeight)

  var tb: iw.TerminalBuffer

  if failAle:
    tb = iw.newTerminalBuffer(termWidth, termHeight)
    const lines = strutils.splitLines(staticRead("assets/failale.ansiwave"))
    var y = 0
    for line in lines:
      codes.write(tb, 0, y, line)
      y += 1
  else:
    var rendered = false
    while keyQueue.len > 0 or charQueue.len > 0:
      let
        (key, mouseInfo) = if keyQueue.len > 0: keyQueue.popFirst else: (iw.Key.None, iw.gMouseInfo)
        ch = if charQueue.len > 0 and key == iw.Key.None: charQueue.popFirst else: 0
      iw.gMouseInfo = mouseInfo
      tb = bbs.tick(session, clnt, termWidth, termHeight, (key, ch), finishedLoading)
      rendered = true
    if not rendered:
      tb = bbs.tick(session, clnt, termWidth, termHeight, (iw.Key.None, 0'u32), finishedLoading)

  termWidth = iw.width(tb)
  termHeight = iw.height(tb)

  let vWidth = termWidth.float * fontWidth
  let vHeight = termHeight.float * fontHeight
  viewHeight = int32(vHeight)

  var e = gl.copy(textEntity)
  text.updateUniforms(e, 0, 0, false)
  for y in 0 ..< termHeight:
    var line: seq[iw.TerminalChar]
    for x in 0 ..< termWidth:
      line.add(tb[x, y])
    discard text.addLine(e, baseEntity, text.monoFont, constants.textColor, line)
  e.project(vWidth, vHeight)
  e.translate(0f, 0f)
  e.scale(fontMultiplier, fontMultiplier)
  render(game, e)

  return finishedLoading

