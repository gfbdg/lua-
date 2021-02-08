--[[
-- 这是网上找的一个优化版本，性能和准确率都更高，而且很简洁。
----]]


local screenWidth, screenHeight= getScreenSize();--获取屏幕分辨率
local distanceTimeRate = 1.89--按压时间与距离的系数，数字越大表示蓄力时间越长
local targetPositionOffset = screenHeight * 0.012--表示方块最上方的点，距离中心点的偏移

function Touch(x, y, millsSecond)
    touchDown(x, y)
    mSleep(millsSecond)
    touchUp(x, y)
end

function main()
--  dialog("请在3秒内打开游戏，并点击开始按钮", 0);
    mSleep(1000)
    DoLoop()
end

function DoLoop()
    while true do 
        keepScreen(true);  --提高性能和准确率
        if DoJump() == false then
            keepScreen(false); 
            break
        end
        keepScreen(false); 
        mSleep(2000)
    end
end

function DoJump() 
    local x, y = GetCalcSelfPosition()
    if x == -1 or x == 0 then
        return false
    end
    local endX = screenWidth-3  -- 1080 1920
    local endY = screenHeight * 0.7
    local startX = 0
    local startY = screenHeight * 0.2

	-- 对半查找
    if x < screenWidth / 2 then
        startX =  screenWidth / 2
    else
        endX = screenWidth / 2
    end
    
    local targetX, targetY = GetTargetPosition(startX, startY, endX, endY)
    local distance = math.sqrt( (x - targetX) * (x - targetX) + (y - targetY) * (y - targetY) )
    local pressTime = CalcHoldTime(distance)
    -- nLog('x '..x..' y '..y..', targetX '..targetX..' targetY '..targetY..', distance '..distance)
    -- toast('flush')
    Touch(100,100, pressTime)
    return true
end


-- 确定人物所在坐标
function GetCalcSelfPosition()
    x,y = findMultiColorInRegionFuzzy( 0x363158, "0|-20|0x3f3354,-2|-40|0x3d3848,10|-62|0x746998,10|-104|0x938ab2,-6|-104|0x414064", 95, 0, 0, screenWidth, screenHeight) -- 6p
    return x, y
end


-- 通过色差确定跳跃目标的坐标
function GetTargetPosition(startX, startY, endX, endY)
    local step = 3
    local r, g, b, rr, gg, bb 
    for y = startY , endY, step do
        r, g, b = getColorRGB(1, y)
        for x = startX, endX , step do
            rr, gg, bb  = getColorRGB(x, y)
            if isColor(r, g, b, rr, gg, bb, 98)  then
			    -- 更新背景颜色
                r = rr
                g = gg
                b = bb
            else
                return x, y + targetPositionOffset
            end
        end
    end
    return -1, -1
end

function isColor(rr, gg, bb, r, g, b ,s) 
    local fl,abs = math.floor,math.abs
    s = fl(0xff*(100-s)*0.01)
    if abs(r-rr)<s and abs(g-gg)<s and abs(b-bb)<s then
        return true
    end
    return false
end

function CalcHoldTime(distance)
    return distance * distanceTimeRate
end

main()
