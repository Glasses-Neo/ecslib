# Package

version       = "0.1.0"
author        = "Glasses-Neo"
description   = "A nimble package for entity component system"
license       = "WTFPL"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

task tests, "run all tests":
  exec "testament p 'tests/**.nim'"
