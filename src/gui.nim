import nimgl/glfw
import core
from ansiwavepkg/illwill as iw import `[]`, `[]=`
import tables

const
  glfwToIllwillKey =
    {GLFWKey.BACKSPACE: iw.Key.Backspace,
     GLFWKey.DELETE: iw.Key.Delete,
     GLFWKey.TAB: iw.Key.Tab,
     GLFWKey.ENTER: iw.Key.Enter,
     GLFWKey.ESCAPE: iw.Key.Escape,
     GLFWKey.UP: iw.Key.Up,
     GLFWKey.DOWN: iw.Key.Down,
     GLFWKey.LEFT: iw.Key.Left,
     GLFWKey.RIGHT: iw.Key.Right,
     GLFWKey.HOME: iw.Key.Home,
     GLFWKey.END: iw.Key.End,
     GLFWKey.PAGE_UP: iw.Key.PageUp,
     GLFWKey.PAGE_DOWN: iw.Key.PageDown
     }.toTable
  glfwToIllwillMouse =
    {GLFWMouseButton.Button1: iw.MouseButton.mbLeft,
     GLFWMouseButton.Button2: iw.MouseButton.mbRight,
     }.toTable

var
  game: Game
  window: GLFWWindow
  density: int

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32) {.cdecl.} =
  if key < 0:
    return
  if glfwToIllwillKey.hasKey(key):
    let iwKey = glfwToIllwillKey[key]
    if action in {GLFW_PRESS, GLFW_REPEAT}:
      onKeyPress(iwKey)
    elif action == GLFW_RELEASE:
      onKeyRelease(iwKey)

proc charCallback(window: GLFWWindow, codepoint: uint32) {.cdecl.} =
  onChar(codepoint)

proc mouseButtonCallback(window: GLFWWindow, button: int32, action: int32, mods: int32) {.cdecl.} =
  if action == GLFWPress and glfwToIllwillMouse.hasKey(button):
    onMouseClick(glfwToIllwillMouse[button])

proc cursorPosCallback(window: GLFWWindow, xpos: float64, ypos: float64) {.cdecl.} =
  onMouseMove(xpos, ypos)

proc mousePositionCallback(window: GLFWWindow, xpos: float64, ypos: float64): void {.cdecl.} =
  game.mouseX = xpos
  game.mouseY = ypos

proc frameSizeCallback(window: GLFWWindow, width: int32, height: int32) {.cdecl.} =
  game.windowWidth = width
  game.windowHeight = height
  game.worldWidth = int32(width / density)
  game.worldHeight = int32(height / density)
  onWindowResize(game.windowWidth, game.windowHeight, game.worldWidth, game.worldHeight)

proc scrollCallback(window: GLFWWindow, xoffset: float64, yoffset: float64) {.cdecl.} =
  discard

when defined(emscripten):
  proc emscripten_set_main_loop(f: proc() {.cdecl.}, a: cint, b: bool) {.importc.}
  proc emscripten_get_canvas_element_size(target: cstring, width: ptr cint, height: ptr cint): cint {.importc.}
  proc emscripten_set_canvas_element_size(target: cstring, width: cint, height: cint) {.importc.}

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
          if height != core.viewHeight.int32:
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

  density = max(1, int(width / windowWidth))
  window.frameSizeCallback(width, height)

  game.init()
  game.totalTime = glfwGetTime()

  when defined(emscripten):
    emscripten_set_main_loop(mainLoop, 0, true)
  else:
    while not window.windowShouldClose:
      mainLoop()

  window.destroyWindow()
  glfwTerminate()
