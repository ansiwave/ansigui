import nimgl/opengl
import paranim/gl, paranim/gl/entities
from glm import vec4
from text import nil
from paratext/gl/text as ptext import nil
from constants import nil

#from ansiwavepkg/chafa import nil
from ansiwavepkg/bbs import nil
from illwill as iw import `[]`, `[]=`
import unicode

from wavecorepkg/client import nil
from os import joinPath

var c = client.initClient(constants.address)
client.start(c)

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

proc onKeyPress*(key: int) =
  discard

proc onKeyRelease*(key: int) =
  discard

proc onMouseClick*(button: int) =
  discard

proc onMouseMove*(xpos: float, ypos: float) =
  discard

proc onWindowResize*(windowWidth: int, windowHeight: int, worldWidth: int, worldHeight: int) =
  discard

var
  root = client.query(c, "ansiwaves".joinPath("1.ansiwavez"))
  threads = client.queryPostChildren(c, constants.dbFilename, 1)

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

proc tick*(game: Game) =
  glClearColor(constants.bgColor.arr[0], constants.bgColor.arr[1], constants.bgColor.arr[2], constants.bgColor.arr[3])
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.windowWidth), GLsizei(game.windowHeight))

  let
    fontHeight = text.monoFont.height * fontMultiplier
    windowWidth = int(game.worldWidth.float / (fontHeight / 2))
    windowHeight = int(game.worldHeight.float / fontHeight)
  var tb = iw.newTerminalBuffer(windowWidth, windowHeight)
  bbs.renderBBS(tb, root, threads)

  var e = gl.copy(textEntity)
  text.updateUniforms(e, 0, 0, false)
  for y in 0 ..< windowHeight:
    var line: seq[Rune]
    for x in 0 ..< windowWidth:
      line.add(tb[x, y].ch)
    discard text.addLine(e, baseEntity, text.monoFont, constants.textColor, line)
  e.project(float(game.worldWidth), float(game.worldHeight))
  e.translate(0f, 0f)
  e.scale(fontMultiplier, fontMultiplier)
  render(game, e)

