import
  std/macros,
  std/unittest,
  ../src/ecslib

type
  CircleCollider = ref object
    radius: uint

  Position = ref object
    x, y: int

proc circle(radius: uint, x, y: int) {.bundled.} =
  return entity
    .add(CircleCollider(radius: radius))
    .add(Position(x: x, y: y))

let world = World.new()

let circle1 {.used.} = world.createEntity()
  .circle(radius = 10, x = 0, y = 0)

check circle.hasCustomPragma bundle
