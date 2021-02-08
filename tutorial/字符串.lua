#!/usr/bin/lua5.3

function testArrLen()
  local obj = {}
  obj[1] = 'a'
  obj[2] = nil
  obj[3] = 'a'
  obj[4] = 'a'
  print('len ', #obj)
end


function testStr()
  str = "hello world!"
  print('upper : ' ..str)
  print( string.upper(str) )

  print(tostring(123))
end

print('test1')
testArrLen()

print('test2')
testStr()
