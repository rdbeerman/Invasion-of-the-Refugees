--[[
    convoy
    a plugin for IOTR that enables moving targets

    todo V1:
    add checkpoints
    send convoys through the checkpoints

    todo v2:
    give tasks to the convoys, enable them to have a purposes
    convoys that set up sam sites for examples
    transport convoys

]]

convoy = {}

convoy.activeGroups = {}
convoy.targetZone = "targetZone"
convoy.templates = { "convoyTemplate-1", "convoyTemplate-2", "convoyTemplate-3", }
convoy.spawnZones = { "spawnZone-1", "spawnZone-2", "spawnZone-3", "spawnZone-4", "spawnZone-5", "spawnZone-6", }
convoy.checkpoints = { "checkpoint-1", "checkpoint-2", "checkpoint-3" }

convoy.name = "convoy"
convoy.marks = {}
convoy.spawnCounter = 1
convoy.updateRate = 10
convoy.speed = 10
convoy.minDistance = 50000
convoy.maxDistance = 100000

function convoy.setUpdateRate(seconds)
    convoy.updateRate = seconds
end

function convoy.addTemplateTable(table)
    convoy.templates = table
end

function convoy.setTargetZone(zone)
    convoy.targetZone = zone
end

function convoy.setCheckpoints(table)
    convoy.checkpoints = table
end

function convoy.setSpawnZoneTable(table)
    convoy.spawnZones = table
end

function convoy.addCheckpointTable(table)
    convoy.checkpoints = table
end

function convoy.setSpeed(kph)
    convoy.speed = kph * 3.6 --to m/s
end

function convoy.setDistanceLimits(min, max)
    convoy.minDistance = min
    convoy.maxDistance = max
end

function convoy.getActiveConvoys()
    return convoy.activeGroups
end

function convoy.getDistance(startVec3, endVec3)
    local _distance = mist.utils.get2DDist (startVec3, endVec3)
    --simple.notify("distance: " .. _distance, 5)
    return _distance
end

function convoy.markCheckpoints()

end

function convoy.start()
    local _spawnZones = convoy.spawnZones
    local _attempts = 10
    local _spawnPointFound = false
    local _convoyName = false

    local _startVec3 = false
    local _targetVec3 = mist.utils.zoneToVec3(convoy.targetZone)

    while _spawnPointFound == false do
        if #_spawnZones == 0 then
            simple.notify("no good zone found", 5)
            break
        end
        local _tableIndex = math.random(#_spawnZones)
        local _zone = _spawnZones[_tableIndex]

        for i=1, _attempts, 1 do
            _startVec3 = mist.getRandomPointInZone(_zone)
            local _distance = convoy.getDistance(_startVec3, _targetVec3)
        
            if _distance >= convoy.minDistance and _distance <= convoy.maxDistance then --in range
                simple.notify("OK! Distance: " .. _distance, 5)
                _convoyName, _startVec3, _targetVec3 = convoy.spawnConvoy(_startVec3, _targetVec3)
                _spawnPointFound = true
                break
            else --out of range
                simple.notify("NOT OK! Distance: " .. _distance, 5)
            end
            if i == _attempts then
                table.remove(_spawnZones, _tableIndex)
                simple.notify("removed spawnZone-" .. _tableIndex, 5)
            end
        end
    end
    return _convoyName, _startVec3, _targetVec3
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
    if randomize == true then
        local _vars = {
            lowerLimit = 1, 
            upperLimit = #_groupData.units, --doesn't seem to work
        }
        _groupData.units = mist.randomizeGroupOrder(_groupData.units )
    end
    table.remove(convoy.templates, _tableIndex) --if several convoys are spawned and they use the same template the game crashes, this "fixes" it
    return _groupData
end

function convoy.spawnConvoy(spawnVec3, targetVec3) --spawn a template in a spawn zone, returns the name of the Group spawned
    local _groupData = convoy.getRandomTemplate(true)
    _groupData.groupName = tostring (convoy.name .. "-" .. convoy.spawnCounter )
    convoy.spawnCounter = convoy.spawnCounter + 1

    local _roadVec2 = convoy.getRoadVec2(spawnVec3)
    for unitId, unitData in pairs (_groupData.units) do --change the spawn coordinates to the vec3
        _groupData.units[unitId].x = _roadVec2.x
        _groupData.units[unitId].y = _roadVec2.y + 20 * unitId
    end

    --get closest checkpoint
    local _closestCheckIndex = convoy.getNearestCheckpoint (_roadVec2)
    local _cpVec2 = Group.getByName ( convoy.checkpoints[_closestCheckIndex] ):getUnit(1):getPoint()

    _groupData.route = { --creates the route to follow
        [1] = mist.ground.buildWP (_roadVec2, 'on_road'),
        [2] = mist.ground.buildWP (_cpVec2, 'on_road'),
        [3] = mist.ground.buildWP (targetVec3, 'on_road', 10),
    }

    mist.dynAdd(_groupData)

    convoy.activeGroups[#convoy.activeGroups+1] = { --might become useful
        groupName = _groupData.name,
        startVec3 = _roadVec2,
        endVec3 = targetVec3,
        alive = true,
    }

    --mist.scheduleFunction(convoy.logic, { _groupData.name }, timer.getTime() + convoy.updateRate) --not useful right now
    return _groupData.name, _roadVec2, targetVec3
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
    simple.notify("closest checkpoint: " .. _index, 5)
    return _index
end

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
            simple.notify("counter: " .. x, 5)
            break
        end
    end
end

function convoy.logic(groupName) --probably not useful right now
    simple.notify(groupName .. " logic started", 5)

    local _group = Group.getByName(groupName)
    local _targets = _group:getUnit(1):getController():getDetectedTargets()
    if _targets then
        for i = 1, #_targets do
            if _targets[i].object and _targets[i].distance == true and _targets[i].object:getCoalition() == 2 then
                simple.notify ("found something", 8)
            else
                simple.notify ("nothing", 5)
            end
        end
    end

    --repeating
    simple.notify("logic fin", 5)
    mist.scheduleFunction(convoy.logic, { groupName }, timer.getTime() + convoy.updateRate)
end

do
    --setup
    convoy.start()
    convoy.start()
    convoy.start()

    --don't change
    trigger.action.outText("convoy.lua started", 10)
end