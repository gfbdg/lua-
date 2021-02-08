#!/usr/bin/lua5.3

function testMetaTable()
  tab1 = { a='apple' }
  tab2 = {}

  tab1.__index = tab1
  tab1.b = 'banana'
  setmetatable(tab2, tab1)

  tab1.b = 'ban'
  tab2.b = 'bxx'
  print(tab2.b, tab1.b)
end


testMetaTable()
