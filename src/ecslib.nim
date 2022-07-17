import
  std/tables,
  std/typetraits,
  std/hashes,
  std/macros


type
  EntityId = uint64

  Entity* = ref object
    id: EntityId
    world: World

  AbstructComponent = ref object of RootObj
    index: Table[Entity, int]
    freeIndex: seq[int]

  Component*[T] = ref object of AbstructComponent
    components: seq[T]

  World* = ref object
    lastId: EntityId
    components: Table[string, AbstructComponent]

proc hash*(self: Entity): Hash {.inline.} =
  self.id.hash

proc `==`*(self: Entity, other: Entity): bool {.inline.} =
  self.id == other.id

proc new*(_: type[World]): World =
  return World(
    lastId: 0
  )

proc createEntity*(self: World): Entity =
  self.lastId.inc
  result = Entity(id: self.lastId, world: self)

proc has*(self: World, T: typedesc): bool =
  self.components.hasKey(typetraits.name(T))

proc componentsOf*(self: World, T: typedesc): Component[T] {.inline.} =
  cast[Component[T]](self.components[typetraits.name(T)])

proc has(self: AbstructComponent, entity: Entity): bool {.inline.} =
  self.index.hasKey(entity)

proc has*(self: Entity, T: typedesc): bool {.inline.} =
  self.world.has(T) and self.world.componentsOf(T).has(self)

proc assign[T](self: Component[T], entity: Entity, component: T) =
  if self.index.hasKey(entity):
    self.components[self.index[entity]] = component
    return
  if self.freeIndex.len > 0:
    let index = self.freeIndex.pop
    self.index[entity] = index
    self.components[index] = component
    return
  self.index[entity] = self.components.len
  self.components.add(component)

proc createComponent(self: World, T: typedesc) {.inline.} =
  self.components[typetraits.name(T)] = Component[T]()

proc assign[T](self: World, entity: Entity, component: T) =
  if not self.has(T):
    self.createComponent(T)
  self.componentsOf(T).assign(entity, component)

proc add*[T](self: World, entity: Entity, component: T) =
  self.assign(entity, component)

proc add*[T](
    self: Entity,
    component: T
): Entity {.inline, discardable.} =
  result = self
  self.world.add(self, component)

proc get[T](self: Component[T], entity: Entity): T {.inline.} =
  return self.components[self.index[entity]]

proc get*(self: World, T: typedesc, entity: Entity): T =
  self.componentsOf(T).get(entity)

proc get*(self: Entity, T: typedesc): T =
  self.world.get(T, self)

iterator items*[T](self: Component[T]): T =
  for i in self.index.values:
    yield self.components[i]

iterator pairs*[T](self: Component[T]): tuple[key: Entity, val: T] =
  for e, i in self.index.pairs:
    yield (e, self.components[i])

proc remove(self: AbstructComponent, entity: Entity) =
  if self.has(entity):
    self.freeIndex.add(self.index[entity])
    self.index.del(entity)

let InvalidEntityId: EntityId = 0

proc deleteEntity(self: World, entity: Entity) =
  for c in self.components.values:
    c.remove(entity)

proc delete*(self: Entity) =
  self.world.deleteEntity(self)
  self.id = InvalidEntityId

template systemized* {.pragma.}

template bundle* {.pragma.}

macro bundled*(theProc: untyped): untyped =
  result = theProc
  result.params[0] = ident"Entity"
  result.params.insert 1, newIdentDefs(ident"entity", ident"Entity")
  result.addPragma ident"bundle"
