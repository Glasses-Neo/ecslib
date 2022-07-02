
import
  ../src/ecslib

type Position = ref object
  x, y: int

type Name = ref object
  name: string

proc echoPosition(pos: Position) =
  echo "x: ", pos.x, " y: ", pos.y

proc updatePosition(pos: Position) =
  pos.x += 1
  pos.y += 1

var world = World.new()

let
  e1 = world.createEntity()
  e2 = world.createEntity()

e1.add(Position(x: 2, y: 4)).add(Name(name: "e1"))
e2.add(Position(x: 1, y: 7)).add(Name(name: "e2"))

e1.add(Position(x: 3, y: 5))


let n = e1.get(Name)
n.name = "renamed"
echo e1.get(Name).name

for p in world.componentsOf(Position):
  updatePosition(p)
  echoPosition(p)
