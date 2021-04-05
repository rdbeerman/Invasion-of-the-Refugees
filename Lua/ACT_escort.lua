--[[
  Name:                           ACT_Escort
  Author:                         R.D. Beerman
  Last Modified On:               27/01/2021
  Dependencies:         	      mist.lua               
  Description:
      Provides intercepting and escorting function for DCS World.
  Usage:
        Set desired range (in meters), maxAngle and minAngle (relative to target heading to the right)
        debug = true enabled overlay with position and zone information.
        esc.timeReq is amount of time interceptor needs to be in zone for escortee to respond
        esc.follow = true means target will follow escort until esc.state is changed externally to "complete"
        otherwise target will fly back to zone with name "escortZone" set in ME.
  
  Planned functions:
        Set reaction to threat to enable escorting REDFOR
        Random chance of target becoming hostile if REDFOR
        Radio callouts with voice lines
        ]]

esc = {}

-- Settings

esc.debug = false
esc.maxRange = 300
esc.maxAngle = 0.8*math.pi
esc.minAngle = 0.10 * math.pi
esc.timeReq = 2
esc.follow = true

-- Declarations, do not change
esc.timer = 0
esc.state = "start"

function esc.checkPos(_args)
    for i = 1, Group.getByName(_args[1]):getInitialSize() do
        local target = Group.getByName(_args[1]):getUnit(1)
        local interceptor = Group.getByName(_args[2]):getUnit(i) -- do entire thing for all units in group

        local interceptorVec3 = interceptor:getPoint()
        local targetVec3 = target:getPoint()

        local relVec3 = mist.vec.sub(targetVec3, interceptorVec3)
        local distance = mist.vec.mag(relVec3)

        local targetHeading = mist.getHeading(target)
        local relAngle = targetHeading - math.atan2(relVec3.z, relVec3.x)
        
        if relAngle >= 2*math.pi then
            relAngle = relAngle - 2*math.pi
        end

        if esc.debug == true then
            local message = "Heading "..tostring(targetHeading * (180 / math.pi)).."\n"
                            .."relAngle "..tostring(relAngle * (180 / math.pi)).."\n"
                            .."Distance "..tostring(distance)
            
            trigger.action.outText(message, 1, true)
        end

        if distance <= esc.maxRange and relAngle >= esc.minAngle and relAngle <= esc.maxAngle then 
            if esc.debug == true then
                trigger.action.outText("In zone", 1, false)
            end
            esc.timer = esc.timer + 1
            return true
        else 
            if esc.debug == true then
                trigger.action.outText("Out of zone", 1, false)
            end
            esc.timer = 0
            
            return false 
        end
    end
end

function esc.start(_args)
    esc.pos = esc.checkPos(_args)

    if esc.timer >= esc.timeReq and esc.state == "start" then
        local target = Group.getByName(_args[2])

        if esc.follow == true then
            local interceptor = Group.getByName(_args[1])

            local followTask = {
                id = 'Follow',
                params = {
                groupId = interceptor:getID(),
                pos = {x = 75, y = 0, z = 75},
                lastWptIndexFlag = false,
                lastWptIndex = 3
                }  
            }

            target:getController():pushTask(followTask)
            
            if esc.debug == true then
                trigger.action.outText("Following", 5, false)
            end
            --STTS.TextToSpeech("Interceptor, visual, we'll follow you to safe airspace.", 121.5, "AM", "1.0", "SERVER", 2)

            esc.state = "escorting"
        else 
            local startPoint = target:getUnit(1):getPoint()
            local endPoint = mist.utils.zoneToVec3("escortZone")
            local altitude = startPoint.y
            
            local path = {}
            path[1] = mist.fixedWing.buildWP(endPoint, "turningpoint", 250, altitude, "ASL") 
            mist.goRoute(target, path)

            if esc.debug == true then
                trigger.action.outText("Returning home", 5, false)
            end

            esc.state = "complete"
        end 
    end

    timer.scheduleFunction(esc.start, _args, timer.getTime() + 1 )
end

function esc.complete(target)
    local target = Group.getByName(target)
    local startPoint = mist.utils.makeVec2(target:getUnit(1):getPoint())
    local heading = mist.getHeading(target:getUnit(1))
    
    local contVec = {
        x = 35000,
        y = 0
    }

    -- rotate vector with heading, add to startPoint
    local endPoint = { 
        x = mist.vec.rotateVec2(contVec, heading).x + startPoint.x,
        y = mist.vec.rotateVec2(contVec, heading).y + startPoint.y}

    local path = {}
    path[1] = mist.fixedWing.buildWP(endPoint, "turningpoint", 250, altitude, "ASL") 
    mist.goRoute(target, path)

    esc.state = "complete"
    --STTS.TextToSpeech("Interceptor, we can find our way from here, continueing on current heading.", 121.5, "AM", "1.0", "SERVER", 2)

    if esc.debug == true then
        trigger.action.outText("Continuing on heading", 5, false)
    end
end

do 
    env.error("---ACT Escort init ---", false)
end
