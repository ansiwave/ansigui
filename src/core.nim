import nimgl/opengl
import paranim/gl, paranim/gl/entities
import stb_image/read as stbi
from glm import vec4
from text import nil
from paratext/gl/text as ptext import nil
from constants import nil
from ansiwavepkg/chafa import nil

from wavecorepkg/client import nil
from os import joinPath

var c = client.initClient(constants.address)
client.start(c)

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

var
  root = client.query(c, "ansiwaves".joinPath("1.ansiwave"))
  user = client.queryUser(c, constants.dbFilename, "Alice")
  post = client.queryPost(c, constants.dbFilename, 4)
  threads = client.queryPostChildren(c, constants.dbFilename, 1)

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  baseEntity = ptext.initTextEntity(text.monoFont)
  textEntity = compile(game, text.initInstancedEntity(baseEntity, text.monoFont))

  const img = staticRead("aintgottaexplainshit.jpg")
  echo chafa.imageToAnsi(img, 80)

import sets
var printed: HashSet[string]

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  var e = gl.copy(textEntity)
  text.updateUniforms(e, 0, 0, false)
  for line in @["Hello, world!", "Goodbye, world!"]:
    discard text.addLine(e, baseEntity, text.monoFont, constants.blackColor, line)
  e.project(float(game.windowWidth), float(game.windowHeight))
  e.translate(0f, 0f)
  e.scale(1/2, 1/2)
  render(game, e)

  client.get(root)
  if root.ready and not printed.contains("root"):
    echo root.value.valid.body
    printed.incl("root")

  client.get(user)
  if user.ready and not printed.contains("user"):
    echo user.value.valid
    printed.incl("user")

  client.get(post)
  if post.ready and not printed.contains("post"):
    echo post.value.valid
    printed.incl("post")

  client.get(threads)
  if threads.ready and not printed.contains("threads"):
    echo threads.value.valid
    printed.incl("threads")

