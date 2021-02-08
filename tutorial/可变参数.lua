#!/usr/bin/lua5.3

function testArgs1(...)
  -- 这里使用的是{...}而不是ipairs(...)
  -- 使用{...},遇上nil可能会提前截断
  for i,v in ipairs{...} do
    print("i ", i, " v ", v)
  end
end


function testArgs2(...)
  local args = {...}
  for i = 1, #args do
	local arg = args[i];
    print("arg ", arg)   --自动换行
    -- print("arg "..arg) 若arg为nil会因类型无法转换而error
  end
end


function testArgs3(...)
  for i = 1, select('#',...) do
	local arg = select(i,...)
	print("arg ", arg )
	-- print("arg ", select(i,...) )
  end
end


print('test1')
testArgs1('a','b',nil,'d')

print('test2')
testArgs2(1,2,nil,4)

print('test3')
testArgs3(1,2,nil,4)
