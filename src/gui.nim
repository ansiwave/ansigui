import nimgl/glfw
import core
from ansiwavepkg/illwill as iw import `[]`, `[]=`
import tables
from ansiwavepkg/bbs import nil
import bitops

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
     GLFWKey.PageDown: iw.Key.PageDown
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
  let
    mult =
      when defined(emscripten):
        1f
      else:
        core.pixelDensity
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

when defined(emscripten):
  proc emscripten_set_main_loop(f: proc() {.cdecl.}, a: cint, b: bool) {.importc.}
  proc emscripten_get_canvas_element_size(target: cstring, width: ptr cint, height: ptr cint): cint {.importc.}
  proc emscripten_set_canvas_element_size(target: cstring, width: cint, height: cint) {.importc.}
  from wavecorepkg/client/emscripten import nil

proc mainLoop() {.cdecl.} =
  let ts = glfwGetTime()
  game.deltaTime = ts - game.totalTime
  game.totalTime = ts
  let canSleep =
    when defined(emscripten):
      try:
        let ret = game.tick()
        var width, height: cint
        if emscripten_get_canvas_element_size("#canvas", width.addr, height.addr) >= 0:
          window.frameSizeCallback(width, height)
          if bbs.isEditor(core.session):
            emscripten.setSizeMax("#canvas", core.pixelDensity, 0,  - int32(core.fontHeight() / 2))
          else:
            emscripten_set_canvas_element_size("#canvas", game.windowWidth, core.viewHeight.int32)
        ret
      except Exception as ex:
        echo ex.msg
        false
    else:
      game.tick()
  window.swapBuffers()
  if canSleep:
    glfwWaitEvents()
  else:
    glfwPollEvents()

proc mainLoopHeadless() {.cdecl.} =
  game.tickHeadless()

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

  proc run() =
    game.init()

    core.pixelDensity =
      when defined(emscripten):
        if core.getMaxViewSize() >= 16384:
          emscripten.getPixelDensity()
        else:
          1f
      else:
        max(1f, width / windowWidth)
    core.fontMultiplier *= core.pixelDensity

    game.totalTime = glfwGetTime()

    when defined(emscripten):
      emscripten_set_main_loop(mainLoop, 0, true)
    else:
      while not window.windowShouldClose:
        mainLoop()

  when defined(emscripten):
    try:
      run()
    except Exception as ex:
      echo ex.msg
      emscripten.setDisplay("#canvas", "none")
      emscripten_set_main_loop(mainLoopHeadless, 0, true)
  else:
    run()

  window.destroyWindow()
  glfwTerminate()

