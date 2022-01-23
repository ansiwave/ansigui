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

requires "nim >= 1.2.6"
requires "paranim >= 0.11.0"
requires "paratext >= 0.12.0"
requires "ansiwave >= 1.4.0"
