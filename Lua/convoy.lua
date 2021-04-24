--[[
    simple.lua
    a small scripting liberary of often used functions
]]

simple = {}
simple.debug = false

function simple.notify(message, duration) --used this so often now... 
    trigger.action.outText(tostring(message), duration)
    env.info("Notify: " .. tostring(message), false)
end

function simple.debugOutput(message)
    local _outputString = "Debug: " .. tostring(message)
    if simple.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function simple.errorOutput(message)
    local _outputString = "ERROR: " .. tostring(message)
    trigger.action.outText(tostring(_outputString), 300)
    env.error(_outputString, false)
end

function simple.smokeVec3 (vec3) --puts smoke at vec3 for debugging
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function simple.printVec3 (vec3) --prints a vec3 to the message box
    trigger.action.outText("vec3.x: " .. vec3.x .. " ; vec3.y: " .. vec3.y .. " ; vec3.z: " .. vec3.z, 5)
end

function simple.getAltitudeAgl (vec3) --returns the altitude AGL of a given vec3
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    local output = vec3.y - _vec3GL.y
    --simple.debugOutput ("getAltitudeAgl: altitude is " .. output .. "m AGL.")
    return output
end

local function dump(table) --https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
	if type(table) == 'table' then
	   local s = '{ \n'
  
	   for k,v in pairs(table) do
		  if type(k) ~= 'number' then
			  k = '"'..k..'"'
		  end
		  s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
	   end
  
	   return s .. '}'
	else
	   return tostring(table)
	end
end

function simple.dumpTable(table) --call this to dumb a table
	env.info("dumpTable: \n" .. dump(table))
end

do
    --simple.debugOutput("simple.lua loaded")
end

--[[

    convoy.lua
    a plugin for IOTR that enables moving targets

    todo V1:
    add checkpoints done
    send convoys through the checkpoints done
    place markers done
    display information 

    todo v2:
    give tasks to the convoys, enable them to have a purposes
    convoys that set up sam sites for examples
    transport convoys
    helicopters

]]

convoy = {}

convoy.activeGroups = {}
convoy.targetZone = {"targetZone"}
convoy.templates = { "convoyTemplate-1" }
convoy.spawnZones = { "spawnZone-1" }
convoy.checkpoints = { "checkpoint-1" }

convoy.name = "convoy"

convoy.updateRate = 10
convoy.speed = 10
convoy.minDistance = 70000
convoy.maxDistance = 100000

convoy.spawnCounter = 1
convoy.markerCounter = 900

function convoy.setup(name, targetZone, templateTable, spawnZoneTable, checkPointTable, vars) --vars.speed, vars.minDist, vars.maxDist, vars.updateRate
    convoy.name = name
    convoy.targetZone = targetZone
    convoy.templates = templateTable
    convoy.spawnZones = spawnZoneTable
    convoy.checkpoints = checkPointTable
    if vars.speed then convoy.speed = vars.speed end
    if vars.minDist then convoy.minDistance = vars.minDist end
    if vars.maxDist then convoy.maxDistance = vars.maxDist end
    if vars.updateRate then convoy.updateRate = vars.updateRate end
    convoy.placeMarks()
end

function convoy.getActiveConvoys()
    return convoy.activeGroups
end

function convoy.placeMarks()
    --mark Target
    trigger.action.markToAll(convoy.markerCounter, convoy.targetZone[1], mist.utils.zoneToVec3(convoy.targetZone[1]), true)
    convoy.markerCounter = convoy.markerCounter + 1
    --mark checkpoints
    for i = 1, #convoy.checkpoints, 1 do 
        local _vec3 = Group.getByName(convoy.checkpoints[i]):getUnit(1):getPoint()
        trigger.action.markToAll(convoy.markerCounter, convoy.checkpoints[i], _vec3, true)
        convoy.markerCounter = convoy.markerCounter + 1
    end
end

function convoy.start()
    local _spawnZones = convoy.spawnZones
    local _attempts = 10
    local _spawnPointFound = false
    local _convoyGroupName = false

    local _startVec3 = false
    local _targetVec3 = mist.utils.zoneToVec3(convoy.targetZone[1])

    while _spawnPointFound == false do --searches for a point within one of the zones that is within the desired range
        if #_spawnZones == 0 then
            simple.debugOutput("no good zone found")
            break
        end
        local _tableIndex = math.random(#_spawnZones)
        local _zone = _spawnZones[_tableIndex]

        for i=1, _attempts, 1 do
            _startVec3 = mist.getRandomPointInZone(_zone)
            local _distance = mist.utils.get2DDist (_startVec3, _targetVec3)
        
            if _distance >= convoy.minDistance and _distance <= convoy.maxDistance then --in range
                simple.debugOutput("OK! Distance: " .. _distance)
                _convoyGroupName = convoy.spawnConvoy(_startVec3, _targetVec3)
                _spawnPointFound = true
                break
            else --out of range
                simple.debugOutput("NOT OK! Distance: " .. _distance)
            end
            if i == _attempts then
                table.remove(_spawnZones, _tableIndex)
                simple.debugOutput("removed spawnZone-" .. _tableIndex)
            end
        end
    end
    return _convoyGroupName
end

--https://wiki.hoggitworld.com/view/DCS_func_getClosestPointOnRoads
function convoy.getRoadVec2(vecIn)  --takes in vec2 and vec3 coordinates and returns vec2 coordinates on the nearest road
    local _output = false
    if vecIn.z then --vec3 if it has an altitude
        local _roadx, _roady = land.getClosestPointOnRoads("roads" , vecIn.x , vecIn.z )
        _output = {
        x = _roadx,
        y = _roady,
        }
    else --no z coordinate, therefore it is vec2
        local _roadx, _roady = land.getClosestPointOnRoads("roads" , vecIn.x , vecIn.y )
        _output = {
        x = _roadx,
        y = _roady,
        }
    end
    return _output
end

function convoy.getRandomTemplate(randomize)
    local _tableIndex = math.random(#convoy.templates)
    local _groupData = mist.getGroupData (convoy.templates[_tableIndex])

    _groupData.groupId = nil --clear the IDs and names of the units to avoid issues with the same template
    for i=1, #_groupData.units, 1 do
        _groupData.units[i].unitId = nil
        _groupData.units[i].unitName = nil
    end

    if randomize == true then
        local _vars = {
            lowerLimit = 1, 
            upperLimit = #_groupData.units, --doesn't seem to work
        }
        _groupData.units = mist.randomizeGroupOrder(_groupData.units, _vars )
    end
    return _groupData
end

function convoy.spawnConvoy(spawnVec3, targetVec3) --spawn a template in a spawn zone, returns the name of the Group spawned
    local _groupData = convoy.getRandomTemplate(false)
    _groupData.groupName = tostring (convoy.name .. "-" .. convoy.spawnCounter )
    convoy.spawnCounter = convoy.spawnCounter + 1
    

    local _roadVec2 = convoy.getRoadVec2(spawnVec3)
    for unitId, unitData in pairs (_groupData.units) do --change the spawn coordinates to the vec3
        _groupData.units[unitId].x = _roadVec2.x
        _groupData.units[unitId].y = _roadVec2.y + 20 * unitId
    end

    --get closest checkpoint
    local _cpIndex = convoy.getNearestCheckpoint (_roadVec2)
    local _cpVec2 = Group.getByName ( convoy.checkpoints[_cpIndex] ):getUnit(1):getPoint()

    _groupData.route = { --creates the route to follow
        [1] = mist.ground.buildWP (_roadVec2, 'on_road'),
        [2] = mist.ground.buildWP (_cpVec2, 'on_road'), --checkpoint
        [3] = mist.ground.buildWP (targetVec3, 'on_road', 10), --target
    }

    mist.dynAdd(_groupData)

    convoy.activeGroups[#convoy.activeGroups+1] = { --might become useful
        groupName = _groupData.name,
        startVec2 = _roadVec2,
        cpVec2 = _cpVec2,
        endVec3 = targetVec3,
        alive = true,
    }

    trigger.action.markToAll(convoy.markerCounter, _groupData.name, mist.utils.makeVec3(_roadVec2), true)
    convoy.markerCounter = convoy.markerCounter + 1

    --mist.scheduleFunction(convoy.logic, { _groupData.name }, timer.getTime() + convoy.updateRate) --not useful right now
    return _groupData.name
end

function convoy.getNearestCheckpoint (startVec2)
    local _index = 0
    local _distance = 9999999

    for i = 1, #convoy.checkpoints, 1 do
        local _dist = mist.utils.get2DDist(startVec2, Group.getByName ( convoy.checkpoints[i] ):getUnit(1):getPoint() )
        if _dist <= _distance then
            _index = i
            _distance = _dist
        end
    end
    simple.debugOutput("closest checkpoint: " .. _index)
    return _index
end

function convoy.logic(groupName) --probably not useful right now
    simple.debugOutput(groupName .. " logic started")

    local _group = Group.getByName(groupName)
    local _controller = _group:getController()
    --do things

    --repeating
    mist.scheduleFunction(convoy.logic, { groupName }, timer.getTime() + convoy.updateRate)
end

--unused debug functions

function convoy.markPath(startVec3, endVec3) --pure debugging
    local route =  land.findPathOnRoads("road" , startVec3.x , startVec3.z ,endVec3.x , endVec3.z )
    simple.dumpTable (route)
    for i=1, #route, 1 do
        local iVec3 = mist.utils.makeVec3(route[i])
        simple.smokeVec3 (iVec3)
        trigger.action.markToAll(i, tostring(i), iVec3)
    end
end

function convoy.getCheckpointPosition (startVec2, endVec2) --very slow, produces noticeable lagg
    local _route = land.findPathOnRoads("road" , startVec2.x , startVec2.y ,endVec2.x , endVec2.y )
    local x = 1 
    for i = #_route, 1, -10 do
        x = x + 1
        local _distance = mist.utils.get2DDist(_route[i], endVec2)
        if _distance >= 5000 then
            local _iVec3 = mist.utils.makeVec3(_route[i])
            simple.smokeVec3 (_iVec3)
            trigger.action.markToAll(i, tostring(i), _iVec3)
            simple.debugOutput("counter: " .. x)
            break
        end
    end
end


do
    --setup

    --[[
    local _vars = {
        speed = 15,
        minDist = 40000,
        maxDist = 60000,
    }

    convoy.setup("convoyName", "targetZone", { "convoyTemplate-1", "convoyTemplate-2", "convoyTemplate-3" }, { "spawnZone-1", "spawnZone-2", "spawnZone-3", "spawnZone-4", "spawnZone-5", "spawnZone-6" }, { "checkpoint-1", "checkpoint-2", "checkpoint-3" }, _vars)
    convoy.start()

    for i = 1, 0, 1 do
        convoy.start()
    end
    ]]


    --don't change
    simple.notify("convoy.lua started", 10)
end