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

function src.taskOrbit(args)
    local _orbitTask = { 
        id = 'Orbit', 
        params = { 
        pattern = "Circle",
        point = mist.utils.makeVec2(args[2]),
        point2 = mist.utils.makeVec2(args[2]),
        speed = args[3],
        altitude = args[4]
        } 
    }

    local _controller = args[1]:getGroup():getController()
    _controller:setTask(_orbitTask)
end

function src.taskRacetrack(_args)
    local _orbitTask = { 
        id = 'Orbit', 
        params = { 
        pattern = "Race-Track",
        point = mist.utils.makeVec2(args[2]),
        point2 = mist.utils.makeVec2(src.raceTrackPoint),
        speed = _speed,
        altitude = _altitude
        } 
    }

    local _controller = _args[2]:getGroup():getController()
    _controller:setTask(_orbitTask)
end

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

            local path = {}
            path[1] = mist.fixedWing.buildWP(mist.utils.makeVec3GL(src.awacs:getPoint()), TurningPoint, _altitude, _speed, 'agl')
            path[2] = mist.fixedWing.buildWP(mist.utils.makeVec3GL(event.pos), TurningPoint, _altitude, _speed, 'agl')
            
            mist.goRoute(src.awacsName, path)
            
            local _controller = src.awacs:getGroup():getController()
            local args = {}
            args[1] = src.awacs
            args[2] = event.pos
            args[3] = _speed
            args[4] = _altitude

            timer.scheduleFunction(src.taskOrbit, args, timer.getTime() + 5 )

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

            local path = {}
            path[1] = mist.fixedWing.buildWP(mist.utils.makeVec3GL(src.tanker1:getPoint()), TurningPoint, _altitude, _speed, 'agl')
            path[2] = mist.fixedWing.buildWP(mist.utils.makeVec3GL(event.pos), TurningPoint, _altitude, _speed, 'agl')
            
            mist.goRoute(src.tanker1Name, path)
            
            local _controller = src.tanker1:getGroup():getController()
            local args = {}
            args[1] = src.tanker1
            args[2] = event.pos
            args[3] = _speed
            args[4] = _altitude

            if string.find (event.text, "racetrack") then
                if src.raceTrackPoint ~= nil then   -- check if racetrack2 exists, if not instruct to place one
                    timer.scheduleFunction(src.taskRacetrack, args, timer.getTime() + 5 )

                    trigger.action.outText("Texaco 1 tasked racetrack" , 10 , false)
                else
                    trigger.action.outText("Place racetrack end point first" , 5 , false)
                end
            else
                timer.scheduleFunction(src.taskOrbit, args, timer.getTime() + 5 )

                trigger.action.outText("Texaco 1 tasked" , 10 , false)
            end
            
            
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

            local path = {}
            path[1] = mist.fixedWing.buildWP(mist.utils.makeVec3GL(src.tanker2:getPoint()), TurningPoint, _altitude, _speed, 'agl')
            path[2] = mist.fixedWing.buildWP(mist.utils.makeVec3GL(event.pos), TurningPoint, _altitude, _speed, 'agl')
            
            mist.goRoute(src.tanker2Name, path)
            
            local _controller = src.tanker1:getGroup():getController()
            local args = {}
            args[1] = src.tanker2
            args[2] = event.pos
            args[3] = _speed
            args[4] = _altitude

            if string.find (event.text, "racetrack") then
                if src.raceTrackPoint ~= nil then   -- check if racetrack2 exists, if not instruct to place one
                    timer.scheduleFunction(src.taskRacetrack, args, timer.getTime() + 5 )

                    trigger.action.outText("Arco 1 tasked racetrack" , 10 , false)
                else
                    trigger.action.outText("Place racetrack end point first" , 5 , false)
                end
            else
                timer.scheduleFunction(src.taskOrbit, args, timer.getTime() + 5 )

                trigger.action.outText("Arco 1 tasked" , 10 , false)
            end
            
            
            STTS.TextToSpeech("Arco 1 moving towards new position", 243, "AM", "1.0", "SERVER", 2)
        end
        --Racetrack point 2
        if string.find(event.text, "racetrack") then
            src.raceTrackPoint = event.pos
            trigger.action.outText("Racetrack endpoint added" , 10 , false)
        end
    end
end

do
    mist.addEventHandler(src.EventHandler)
end