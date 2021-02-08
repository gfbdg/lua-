#!/usr/bin/lua5.3

--注意max和init的位置不能随意交换
function iter1(max, init) 
  if init < max then
	init = init + 1
	return init, init*init
  end
end


-- 第2个参数对应索引，第3个参数无所谓
-- 注意如果iter2有参数seq与i，那么可能需要在for语句中进行初始化声明！
function iter2(seq, i, other)
  if seq[i] ~= nil then
    seq[i] = seq[i] + 1
    return i+1
  end
end


-- 如何无状态迭代器也能转为有状态迭代器
function statefulIpairs(tbl)
  local func, seq, i = ipairs(tbl)
  return function()
		   if i ~= nil then
             local tmp, var = func(seq, i)
    	     i = tmp
		     return tmp, var
	       end
         end
end


-- 能反复使用的有状态的迭代器
function resetableStatefulIpairs(tbl)
  local func, seq, i = ipairs(tbl)
  local start = i
  -- 只需要一个参数reset，纯粹用来控制reset
  return function(reset)
		   if reset ~= nil then
		     i = start
			 return
		   end

		   local tmp, var = func(seq, i)
		   i = tmp
		   return tmp, var
		 end
end


function testIter()
  print('iter1')
  init = iter1(3,0)
  for i, n in iter1,3,0 do
	print(i, n)
  end

  print('iter2')
  seq = {1,2,3}
  -- func, seq, controlVar
  for i in iter2,seq,1 do
    print('seq[i]', seq[i-1])
  end

  print('iter3')
  tbl = {'a', 'b', 'c'}
  sip = statefulIpairs(tbl)
  -- 下面2个for只会执行第一个
  -- for i,v in sip() do 不是调用sip()而是传进一个函数参数
  for i,v in sip do
	print(i,v)
  end
  for i,v in sip do
	print(i,v)
  end

  print('iter4')
  sip = resetableStatefulIpairs(tbl)
  for i,v in sip do
	print(i,v)
  end
  sip(true)
  for i,v in sip do
	print(i,v)
  end

end

testIter()
