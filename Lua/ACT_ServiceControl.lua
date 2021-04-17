    --  Name:                           ACT_ServiceControl
    --  Author:                         Activity
	-- assert(loadfile('C:\\Users\\username\\Saved Games\\DCS.openbeta\\Missions\\ServiceControl.lua'))()
    --  Last Modified On:               17/04/2021
    --  Dependencies:                   Mist.lua
    --  Description:
    --      Enabled player control of AWACS and tankers for IOTR
    --  Usage:
    --      1. Set up units with correct names in ME
    --      2. Load script
    --      3. Use command tanker/awacs.speed.alt

src = {}

--Settings
src.awacsName = "AWACS Blue"
src.tanker1Name = "KC-135 MPRS"
src.tanker2Name = "KC-135 Fast"
src.delimiter = "."

src.zoneName = "airspaceBlue"

--Declarations, do not change
src.awacs = Group.getByName(src.awacsName):getUnit(1)
src.tanker1 = Group.getByName(src.tanker1Name):getUnit(1)
src.tanker2 = Group.getByName(src.tanker2Name):getUnit(1)
src.zone = trigger.misc.getZone(src.zoneName)

src.units = {src.awacs, src.tanker1, src.tanker2}
src.states = {false, false, false}


function src.mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function src.checkInZone()
    for i = 1, #src.units do
        local _range = mist.utils.get2DDist(src.zone.point ,  src.units[i]:getPoint())
        if _range >= src.zone.radius and src.state[i] == false then
            local _controller = src.units[i]:getController()

            local _setInvisible = { 
                id = 'SetInvisible', 
                params = { 
                  value = true 
                } 
              }
            
            _controller:setCommand(_setInvisible)
            src.units[i] = true

            STTS.TextToSpeech("Blue support aircraft entering red airspace", 243, "AM", "1.0", "SERVER", 2)
        elseif src.state[i] == true then
            local _controller = src.units[i]:getController()

            local _setInvisible = { 
                id = 'SetInvisible', 
                params = { 
                  value = false 
                } 
              }
            
            _controller:setCommand(_setInvisible)
            src.units[i] = false

            STTS.TextToSpeech("Blue support aircraft leaving red airspace", 243, "AM", "1.0", "SERVER", 2)
        end
    end
    timer.scheduleFunction(src.checkInZone, nil, timer.getTime() + 5 )
end

function src.EventHandler(event)
    if event.id == 26 then
        --AWACS
        if  string.find (event.text, "awacs") or string.find (event.text, "overlord") then
            local _command = gnd.mysplit(event.text, src.delimiter)

            if _command[2] == nil then
                local _speed = src.awacs:getVelocity()
            else
                local _speed = _command[2] * 0.51
            end

            if _command[3] == nil then
                local _altitude = src.awacs:getPosition().y
            else
                local _altitude = _command[3] * 0.3048
            end

            local _orbitTask = { 
                id = 'Orbit', 
                params = { 
                pattern = "Circle",
                point = mist.utils.makeVec2(event.pos),
                point2 = mist.utils.makeVec2(event.pos),
                speed = _speed,
                altitude = _altitude
                } 
            }
            
            local _controller = src.awacs:getController()
            _controller:setTask(_orbitTask)
            trigger.action.outText("AWACS tasked" , 10 , false)
            STTS.TextToSpeech("Overlord moving towards new position", 243, "AM", "1.0", "SERVER", 2)
        end
        -- Tanker 1
        if  string.find (event.text, "texaco") or string.find (event.text, "tanker1") or string.find (event.text, "tankerdrogue") then
            local _command = gnd.mysplit(event.text, src.delimiter)

            if _command[2] == nil then
                local _speed = src.tanker1:getVelocity()
            else
                local _speed = _command[2] * 0.51
            end

            if _command[3] == nil then
                local _altitude = src.tanker1:getPosition().y
            else
                local _altitude = _command[3] * 0.3048
            end

            local _orbitTask = { 
                id = 'Orbit', 
                params = { 
                pattern = "Circle",
                point = mist.utils.makeVec2(event.pos),
                point2 = mist.utils.makeVec2(event.pos),
                speed = _speed,
                altitude = _altitude
                } 
            }
            
            local _controller = src.tanker1:getController()
            _controller:setTask(_orbitTask)
            trigger.action.outText("Texaco 1 tasked" , 10 , false)
            STTS.TextToSpeech("Texaco 1 moving towards new position", 243, "AM", "1.0", "SERVER", 2)
        end
        --Tanker 2
        if  string.find (event.text, "arco") or string.find (event.text, "tanker2") or string.find (event.text, "tankerprobe") then
            local _command = gnd.mysplit(event.text, src.delimiter)

            if _command[2] == nil then
                local _speed = src.tanker2:getVelocity()
            else
                local _speed = _command[2] * 0.51
            end

            if _command[3] == nil then
                local _altitude = src.tanker2:getPosition().y
            else
                local _altitude = _command[3] * 0.3048
            end

            local _orbitTask = { 
                id = 'Orbit', 
                params = { 
                pattern = "Circle",
                point = mist.utils.makeVec2(event.pos),
                point2 = mist.utils.makeVec2(event.pos),
                speed = _speed,
                altitude = _altitude
                } 
            }
            
            local _controller = src.tanker2:getController()
            _controller:setTask(_orbitTask)
            trigger.action.outText("Arco 1 tasked" , 10 , false)
            STTS.TextToSpeech("Arco 1 moving towards new position", 243, "AM", "1.0", "SERVER", 2)
        end
    end
end

--set vunerable & visible if outside of zone


do
    mist.addEventHandler(src.EventHandler)
end