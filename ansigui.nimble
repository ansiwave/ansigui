# Package

version       = "0.1.0"
author        = "FIXME"
description   = "FIXME"
license       = "FIXME"
srcDir        = "src"
bin           = @["ansigui"]

task dev, "Run dev version":
  exec "nimble run ansigui"

task emscripten_dev, "Build the emscripten dev version":
  exec "nimble build -d:emscripten"
  exec "nimble build -d:emscripten -d:emscripten_worker"

task emscripten, "Build the emscripten release version":
  exec "nimble build -d:release -d:emscripten"
  exec "nimble build -d:release -d:emscripten -d:emscripten_worker"

# Dependencies

requires "nim >= 1.2.6"
requires "paranim >= 0.11.0"
requires "paratext >= 0.12.0"
requires "pararules >= 0.18.0"
requires "stb_image >= 2.5"
requires "ansiwave >= 0.7.0"
