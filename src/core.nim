import nimgl/opengl
import paranim/gl, paranim/gl/entities
from glm import vec4
from ./text import nil
from paratext/gl/text as ptext import nil
from ./constants import nil
import deques
from wavecorepkg/paths import nil

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
  clnt: client.Client
  session*: bbs.BbsSession
  accessibleText = ""
  baseEntity: ptext.UncompiledTextEntity
  textEntity: text.AnsiwaveTextEntity
  fontMultiplier* = 1/4
  keyQueue: Deque[(iw.Key, iw.MouseInfo)]
  charQueue: Deque[uint32]
  viewHeight*: float
  pixelDensity*: float

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

proc insertAccessibleText(finishedLoading: bool, webglSupported: bool) =
  when defined(emscripten):
    var text: string
    if finishedLoading:
      text = bbs.renderHtml(session)
    if text != accessibleText:
      if webglSupported:
        emscripten.setInnerHtml("#accessible-text", text)
      else:
        let header = "<div>Your browser doesn't support WebGL 2! Falling back to text-only mode.</div>"
        emscripten.setInnerHtml("#accessible-text", header & text)
      accessibleText = text

when defined(emscripten):
  proc hashChanged() {.exportc.} =
    bbs.insertHash(session, emscripten.getHash())

  proc getMaxViewSize*(): cint =
    glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE, result.addr)

  proc getCurrentFocusTop*(): int {.exportc.} =
    let fontHeight = fontHeight()
    int(bbs.getCurrentFocusArea(session).top.float * fontHeight / pixelDensity)

  proc getCurrentFocusBottom*(): int {.exportc.} =
    let fontHeight = fontHeight()
    int(bbs.getCurrentFocusArea(session).bottom.float * fontHeight / pixelDensity)

proc init*(game: var Game) =
  clnt = client.initClient(paths.address, paths.postAddress)
  client.start(clnt)

  bbs.init()

  # this must be done before the gl stuff
  # that way, it will initialize even if the gl stuff fails
  session = bbs.initSession(clnt)

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

  var
    tb: iw.TerminalBuffer
    rendered = false
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

  let viewWidth = termWidth.float * fontWidth
  viewHeight = termHeight.float * fontHeight

  var e = gl.copy(textEntity)
  text.updateUniforms(e, 0, 0, false)
  for y in 0 ..< termHeight:
    var line: seq[iw.TerminalChar]
    for x in 0 ..< termWidth:
      line.add(tb[x, y])
    discard text.addLine(e, baseEntity, text.monoFont, constants.textColor, line)
  e.project(viewWidth, viewHeight)
  e.translate(0f, 0f)
  e.scale(fontMultiplier, fontMultiplier)
  render(game, e)

  insertAccessibleText(finishedLoading, webglSupported = true)

  return finishedLoading

proc tickHeadless*(game: Game) =
  insertAccessibleText(true, webglSupported = false)

