import nimgl/opengl
import paranim/gl, paranim/gl/entities
import stb_image/read as stbi
from glm import vec4
from text import nil
from paratext/gl/text as ptext import nil
from colors import nil

type
  Game* = object of RootGame
    deltaTime*: float
    totalTime*: float
    frameWidth*: int32
    frameHeight*: int32
    windowWidth*: int32
    windowHeight*: int32
    mouseX*: float
    mouseY*: float

var
  baseEntity: ptext.UncompiledTextEntity
  textEntity: text.AnsiwaveTextEntity

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

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  baseEntity = ptext.initTextEntity(text.monoFont)
  textEntity = compile(game, text.initInstancedEntity(baseEntity, text.monoFont))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  var e = gl.copy(textEntity)
  text.updateUniforms(e, 0, 0, false)
  for line in @["Hello, world!", "Goodbye, world!"]:
    discard text.addLine(e, baseEntity, text.monoFont, colors.blackColor, line)
  e.project(float(game.windowWidth), float(game.windowHeight))
  e.translate(0f, 0f)
  e.scale(1/2, 1/2)
  render(game, e)

