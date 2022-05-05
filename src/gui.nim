import paranim/glfw
import core
from ansiwavepkg/illwill as iw import `[]`, `[]=`
import tables
import bitops
from ansiwavepkg/ui/editor import nil
from strutils import nil

const
  glfwToIllwillKey =
    {GLFWKey.Backspace: iw.Key.Backspace,
     GLFWKey.Delete: iw.Key.Delete,
     GLFWKey.Tab: iw.Key.Tab,
     GLFWKey.Enter: iw.Key.Enter,
     GLFWKey.Escape: iw.Key.Escape,
     GLFWKey.Up: iw.Key.Up,
     GLFWKey.Down: iw.Key.Down,
     GLFWKey.Left: iw.Key.Left,
     GLFWKey.Right: iw.Key.Right,
     GLFWKey.Home: iw.Key.Home,
     GLFWKey.End: iw.Key.End,
     GLFWKey.PageUp: iw.Key.PageUp,
     GLFWKey.PageDown: iw.Key.PageDown,
     GLFWKey.Insert: iw.Key.Insert,
     }.toTable
  glfwToIllwillCtrlKey =
    {GLFWKey.A: iw.Key.CtrlA,
     GLFWKey.B: iw.Key.CtrlB,
     GLFWKey.C: iw.Key.CtrlC,
     GLFWKey.D: iw.Key.CtrlD,
     GLFWKey.E: iw.Key.CtrlE,
     GLFWKey.F: iw.Key.CtrlF,
     GLFWKey.G: iw.Key.CtrlG,
     GLFWKey.H: iw.Key.CtrlH,
     # Ctrl-I is Tab
     GLFWKey.J: iw.Key.CtrlJ,
     GLFWKey.K: iw.Key.CtrlK,
     GLFWKey.L: iw.Key.CtrlL,
     # Ctrl-M is Enter
     GLFWKey.N: iw.Key.CtrlN,
     GLFWKey.O: iw.Key.CtrlO,
     GLFWKey.P: iw.Key.CtrlP,
     GLFWKey.Q: iw.Key.CtrlQ,
     GLFWKey.R: iw.Key.CtrlR,
     GLFWKey.S: iw.Key.CtrlS,
     GLFWKey.T: iw.Key.CtrlT,
     GLFWKey.U: iw.Key.CtrlU,
     GLFWKey.V: iw.Key.CtrlV,
     GLFWKey.W: iw.Key.CtrlW,
     GLFWKey.X: iw.Key.CtrlX,
     GLFWKey.Y: iw.Key.CtrlY,
     GLFWKey.Z: iw.Key.CtrlZ,
     GLFWKey.Backslash: iw.Key.CtrlBackslash,
     GLFWKey.RightBracket: iw.Key.CtrlRightBracket,
     }.toTable
  glfwToIllwillMouseButton =
    {GLFWMouseButton.Button1: iw.MouseButton.mbLeft,
     GLFWMouseButton.Button2: iw.MouseButton.mbRight,
     }.toTable
  glfwToIllwillMouseAction =
    {GLFWPress: iw.MouseButtonAction.mbaPressed,
     GLFWRelease: iw.MouseButtonAction.mbaReleased,
     }.toTable

var
  game: Game
  window: GLFWWindow

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32) {.cdecl.} =
  if key < 0:
    return
  let keys =
    if 0 != bitand(mods, GLFW_MOD_CONTROL):
      glfwToIllwillCtrlKey
    else:
      glfwToIllwillKey
  if keys.hasKey(key):
    let iwKey = keys[key]
    if action in {GLFW_PRESS, GLFW_REPEAT}:
      onKeyPress(iwKey)
    elif action == GLFW_RELEASE:
      onKeyRelease(iwKey)

proc charCallback(window: GLFWWindow, codepoint: uint32) {.cdecl.} =
  onChar(codepoint)

proc updateCoords(xpos: var float64, ypos: var float64) =
  let mult = core.pixelDensity
  xpos = xpos * mult
  ypos = ypos * mult

proc cursorPosCallback(window: GLFWWindow, xpos: float64, ypos: float64) {.cdecl.} =
  var
    mouseX = xpos
    mouseY = ypos
  updateCoords(mouseX, mouseY)
  onMouseMove(mouseX, mouseY)

proc mouseButtonCallback(window: GLFWWindow, button: int32, action: int32, mods: int32) {.cdecl.} =
  if glfwToIllwillMouseButton.hasKey(button) and glfwToIllwillMouseAction.hasKey(action):
    var
      xpos: float64
      ypos: float64
    getCursorPos(window, xpos.addr, ypos.addr)
    updateCoords(xpos, ypos)
    onMouseUpdate(xpos, ypos)
    onMouseClick(glfwToIllwillMouseButton[button], glfwToIllwillMouseAction[action])

proc frameSizeCallback(window: GLFWWindow, width: int32, height: int32) {.cdecl.} =
  game.windowWidth = width
  game.windowHeight = height
  onWindowResize(game.windowWidth, game.windowHeight)

proc scrollCallback(window: GLFWWindow, xoffset: float64, yoffset: float64) {.cdecl.} =
  discard

proc main*() =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)
  glfwWindowHint(GLFWTransparentFramebuffer, GLFW_TRUE)

  window = glfwCreateWindow(1024, 768, "ANSIWAVE")
  if window == nil:
    quit(-1)

  window.makeContextCurrent()
  glfwSwapInterval(1)

  discard window.setKeyCallback(keyCallback)
  discard window.setCharCallback(charCallback)
  discard window.setMouseButtonCallback(mouseButtonCallback)
  discard window.setCursorPosCallback(cursorPosCallback)
  discard window.setFramebufferSizeCallback(frameSizeCallback)
  discard window.setScrollCallback(scrollCallback)

  var width, height: int32
  window.getFramebufferSize(width.addr, height.addr)

  var windowWidth, windowHeight: int32
  window.getWindowSize(windowWidth.addr, windowHeight.addr)

  window.frameSizeCallback(width, height)

  editor.copyCallback =
    proc (lines: seq[string]) =
      let s = strutils.join(lines, "\n")
      window.setClipboardString(s)

  game.init()

  core.pixelDensity = max(1f, width / windowWidth)
  core.fontMultiplier *= core.pixelDensity

  game.totalTime = glfwGetTime()

  while not window.windowShouldClose:
    try:
      let ts = glfwGetTime()
      game.deltaTime = ts - game.totalTime
      game.totalTime = ts
      let canSleep = game.tick()
      window.swapBuffers()
      if canSleep:
        glfwWaitEvents()
      else:
        glfwPollEvents()
    except Exception as ex:
      stderr.writeLine(ex.msg)
      stderr.writeLine(getStackTrace(ex))
      core.failAle = true

  window.destroyWindow()
  glfwTerminate()

