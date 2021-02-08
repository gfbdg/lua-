require "TSLib"

-- 数字转为16进制字符串格式 
HexTab = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}
function toHexStr( num )
    local str = ''
    while num > 0 do
        str = str..HexTab[num % 16 + 1]
        num = math.floor(num / 16)
    end
    str = str..'x0'
    return string.reverse(str)
end


-- 找一个左边中心坐标和右边中心坐标
targetPosLX,targetPosLY,targetPosRX,targetPosRY = 230,575,510,580
-- 小人所在区域范围
regionL_x, regionL_y, regionR_x, regionR_y = 60, 500, 670, 820
step = 0


-- 确定下一次跳跃目标的坐标，并返回其颜色值
function getTargetPos(dest_x, dest_y, onLeft)
	local target_x, target_y = -1, -1
	local color = 0

	if onLeft then  --跳左边
    	for j=dest_y, dest_y+3, 3 do
    	    for i=dest_x-3, dest_x+3, 3 do
    	        color = getColor(i,j)
    	        if getColor(i+10,j) == color and getColor(i-10,j) == color and getColor(i,j+10) == color and getColor(i,j-10) == color then 
    	            return i, j, color
    	        end
    	    end
    	end
    else     -- 跳右边
    	for j=dest_y, dest_y+6, 3 do
    	    for i=dest_x, dest_x+9, 3 do
    	        color = getColor(i,j)
    	        if getColor(i+10,j) == color and getColor(i-10,j) == color and getColor(i,j+10) == color and getColor(i,j-10) == color then 
    	            return i, j, color
    	        end
    	    end
    	end
    end
	
	-- 找不到合适的就跳到默认中心点
	return dest_x, dest_y, getColor(dest_x, dest_y)
end



-- 判断跳跃的方向，下一个块总是在上方
function isLeft()
    local x1, y1, x2, y2 = 100, 500, 682, 568
    for j=y1, y2, 15 do
	    for i=x1, x2, 5 do
	        color = getColor(i,j)
	        if math.abs(color - getColor(i-20,j)) > 1000 and color == getColor(i+2,j+2) then 
	            return i < 374  --在表示左边
	        end
	    end
	end
end


-- 微调操作, 如果木块本身就很小，则不进行微调
-- 当跳跃目标在木块边缘，那么做一点调整
function adjust( target_x, target_y, target_color, onLeft )
    local appending1, offset1 = 5, 25
    local appending2, offset2 = -1*appending1, -1*offset1 
	if onLeft then 
	    offset2 = -1 * offset2
	    appending2 = -1 * appending2
	end
	
	if math.abs(getColor(target_x+offset1, target_y+offset2)-target_color) < 1000  or  math.abs(getColor(target_x-offset1, target_y-offset2)-target_color) < 1000 then    
    	if math.abs(getColor(target_x-offset1, target_y-offset2)-target_color) > 1000 and math.abs(getColor(target_x-offset1+5, target_y-offset2+5)-getColor(target_x-offset1, target_y-offset2)) < 1000  then 
    	  target_x = target_x + appending1
    	  target_y = target_y + appending2
    	  if onLeft then nLog(step..'down') else nLog(step..'up') end
        elseif math.abs(getColor(target_x+offset1, target_y+offset2)-target_color) > 1000  and math.abs(getColor(target_x+offset1, target_y+offset2)-getColor(target_x+offset1+5, target_y+offset2+5)) < 1000  then
    	  target_x = target_x - appending1
    	  target_y = target_y - appending2
    	  if onLeft then nLog(step..'up') else nLog(step..'down') end
        end
	end
	
	return target_x, target_y
end


-- 确定小人所在坐标，再计算小人到目标的距离
onLeft = false
function getDistance()
	local dest_x, dest_y = targetPosRX, targetPosRY
	onLeft = false
	if isLeft() then
	    dest_x, dest_y = targetPosLX,targetPosLY
	    onLeft = true
	end
	
    -- 确定小人所在坐标
    local x,y = findMultiColorInRegionFuzzy( 0x363158, "0|-20|0x3f3354,-2|-40|0x3d3848,10|-62|0x746998,10|-104|0x938ab2,-6|-104|0x414064,-6|-58|0x414064,-8|-22|0x3b3150,-10|-8|0x373259,14|2|0x3a355d", 95, regionL_x, regionL_y, regionR_x, regionR_y)
	if x == -1 then
		return 0;
	end

	-- 通过颜色差异来确定目标所在坐标
	--[[
	color = getColor(dest_x, dest_y)
	color = toHexStr(color)
	posandcolor = '0|0|'..color..',0|20|'..color..',0|-20|'..color..',20|0|'..color..',-20|0|'..color
	local target_x, target_y = findMultiColorInRegionFuzzy( color, posandcolor, 100, dest_x-30, dest_y-30, dest_x+30, dest_y+30)
	]]--

	target_x, target_y, target_color = getTargetPos(dest_x, dest_y, onLeft)
	target_x, target_y = adjust( target_x, target_y, target_color, onLeft )


	-- 计算距离
	local distance = math.sqrt(math.pow(target_x - x,2) + math.pow(target_y-y,2));		
	step = step + 1
	nLog(step..'\nplayer site : x '..x..',y '..y..'\ntarget site : x '..target_x..',y '..target_y..'\ndistance : '..distance)
	toast('flush')
	return distance;
end


function gameIsOver()
    x,y = findMultiColorInRegionFuzzy( 0x3d3a3d, "0|0|0x3d3a3d, 4|16|0x3d3b3d,-40|-12|0x3b393b,-46|-78|0x3a383a,-360|128|0x3e3d3d,-422|122|0x3f3d3e,-366|100|0x3d3b3d,-376|152|0x3f3d3e,-376|-20|0x3a3839,92|144|0x403e40", 90, 0, 0, 719, 1279)
    return x~=-1 and y~=-1
end


function main()
    init(0)
    while not gameIsOver() do
    	dist = getDistance();
    	-- 往左边跳跃经常失败，太近跳过头，太远跳不到
    	-- 远的就让系数大些，近的就让系数小些
        local ratio = 2.124
    	if onLeft then
        	if dist > 350 then 
        	    ratio = 2.155
        	elseif dist > 300 then 
        	    ratio = 2.15
        	elseif dist > 250 then 
        	    ratio = 2.13
        	else
        	    ratio = 1.85
    	    end
    	else
        	if dist > 400 then 
        	    ratio = 2.15
        	elseif dist > 330 then 
        	    ratio = 2.15
        	elseif dist > 300 then 
        	    ratio = 2.126
        	elseif dist > 250 then 
        	    ratio = 2.15
        	else
        	    ratio = 1.75
    	    end 
	    end
    	
    	if dist > 390 then 
    	    dist = dist * ratio + 30
    	elseif  dist > 230 then
    	    dist = dist * ratio
    	elseif  dist > 150 then
    	    dist = dist * 1.85
    	else 
    	    dist = 285
    	end
    	
    	touchDown(targetPosLX,targetPosLY);
    	mSleep(dist);
    	touchUp(targetPosLX,targetPosLY);
        -- 画面还没有完全执行就执行了下一次小人坐标的计算，那么就会得到错误的结果
        mSleep(500)
    end
end

main()


