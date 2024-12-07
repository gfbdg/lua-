#!/usr/bin/lua5.3

Animal = { name='' }
function Animal:new(o,name)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.name = name
  print(self)
  return o
end

function Animal:getname()
  print(self.name)
end


function testOOP()
  print(Animal)
  dog = Animal:new(nil,'dog')
  dog:getname()

  cat = Animal:new(nil,'cat')
  cat:getname()
  dog:getname()
end


testOOP()
