# Package

version       = "0.1.0"
author        = "FIXME"
description   = "FIXME"
license       = "FIXME"
srcDir        = "src"
bin           = @["ansigui"]

task dev, "Run dev version":
  exec "nimble run ansigui"

# Dependencies

requires "nim >= 1.6.4"
requires "paranim >= 0.12.0"
requires "paratext >= 0.13.0"
requires "ansiwave >= 1.6.0"
requires "nimwave >= 0.1.0"
