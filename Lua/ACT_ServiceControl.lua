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

--Declarations, do not change
src.awacs = Group.getByName(src.awacsName):getUnit(1)
src.tanker1Name = Group.getByName(src.tanker1Name):getUnit(1)
src.tanker2Name = Group.getByName(src.tanker2Name):getUnit(1)

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

function src.EventHandler(event)
    if event.id == 26 then
        if  string.find (event.text, "awacs") then
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
                pattern = AI.Task.OrbitPattern,
                point = event.pos,
                point2 = event.pos,
                speed = _speed,
                altitude = _altitude
                } 
            }
            
            local _controller = src.awacs:getController()
            _controller:pushTask(_orbitTask)
            trigger.action.outText("Awacs tasked" , 10 , false)
        end
    end
end

do
    mist.addEventHandler(src.EventHandler)
end