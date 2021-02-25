--[[
  Name:                           ACT CAPCheckin
  Author:                         Activity
  Last Modified On:               20/02/2021
  Dependencies:                   mist
                                  ACT Escort
                                  MOOSE
  Description:
      Provides blue CAP tasking such as escort (friendle or hostile), intercepts
  Usage:
  Add all groups capable of checking in so capc.groups
  ]]


capc = {}

-- Settings
capc.groups = {
    "F-16C - Springfield 1",
    "F-15 - Enfield 5",
    "F/A-18C - Enfield 1",
    "JF-17 - Chevy 1",
    "F-14B - Pontiac 1",
    "M-2000C - Uzi 1",
    "MiG-21bis - Uzi 3",
    "F-5E - Uzi 4",
    "F/A-18C - Enfield 2 - Naval",
    "F/A-18C - Enfield 3 - Naval",
    "F-14A - Pontiac 3 - Naval",
    "F-14B - Pontiac 2 - Naval"
}


capc.escortBlue = act.getEscortBlue() --Gets templates frm ACT MapOptions
capc.escortRed = act.getEscortRed()
capc.escortGrey = act.getEscortGrey()
capc.redTarget = act.getRedTarget()
capc.redCap = act.getRedCap()
capc.escortedChange = 1
capc.blueZone = "airspaceBlue"

capc.baseBlue = 21
capc.baseGrey = {16, 2, 6, 9}

capc.timeLow = 1
capc.timeHigh = 5

capc.minAltitude = 500
capc.maxAltitude = 7000

capc.debug = false
capc.frequency = 240

capc.overlordTimer = 180

-- Declarations, do not edit
capc.states = {} -- key is groupID, value is state "active", "tasked" or nil 
capc.objectives = {} -- format: {groupName, category, state}
capc.counter = 0

-- TODO
    --Escort reds chance
    --Escort function
    -- Anti Ship possibility

function capc.checkin(_groupID)
    missionCommands.removeItemForGroup(_groupID, capc.radioCheckin)
    capc.radioCheckout = missionCommands.addCommandForGroup(_groupID, "CAP Check out", nil, capc.checkout , _groupID)
    capc.states[_groupID] = "active"

    timer.scheduleFunction(capc.genTask, _groupID, timer.getTime() + math.random(capc.timeLow, capc.timeHigh))

    STTS.TextToSpeech("Copy check in, start patrol", 240, "AM", "1.0", "SERVER", 2)
    if capc.debug == true then
        trigger.action.outText(tostring(_groupID).." Checked in", 5, false)
    end
end

function capc.checkout(_groupID)
    missionCommands.removeItemForGroup(_groupID, capc.radioCheckout)
    capc.radioCheckin = missionCommands.addCommandForGroup(_groupID, "CAP Check in", nil, capc.checkin , _groupID)
    
    capc.states[_groupID] = nil
    STTS.TextToSpeech("Copy check out, continue patrol", 240, "AM", "1.0", "SERVER", 2)

    if capc.debug == true then
        trigger.action.outText(tostring(_groupID).." Checked out", 5, false)
    end
end

function capc.genTask(_groupID)
    local x = math.random(3, 3)
    if x == 1 then
        capc.escortBlueSpawn(_groupID)
    elseif x == 2 then
        capc.escortRedSpawn(_groupID) -- Changed to red for now because escort doesn't work yet.
    elseif x ==3 then
        capc.escortRedSpawn(_groupID)
    end
end

function capc.escortBlueSpawn(_groupID)
    local _groupData = mist.getGroupData(capc.escortBlue[math.random(1,#capc.escortBlue)])
    capc.counter = capc.counter + 1
    _groupData.clone = true
    _groupData.groupName = "capc-"..capc.counter

    _takeoffPoint = {
		['type'] = "TakeOffParkingHot",
		['form'] = "From Parking Area Hot",
		['action'] = "From Parking Area Hot",
		['airdromeId'] = capc.baseBlue,
		["task"] = {
            id = 'EngageTargets', 
            params = { 
            maxDist = 20000, 
            targetTypes = "All", 
            priority = 1  
            },
	    },
    }   
    
    if missionData.vec3Prim == nil then
        capc.targetVec2 = mist.utils.makeVec2(mist.getRandomPointInZone("zone-16" , 0))
    else 
        capc.targetVec2 = mist.utils.makeVec2(missionData.vec3Prim)
    end

    _targetPoint = {
		["alt"] = math.random(capc.minAltitude, capc.maxAltitude),
		["x"] = capc.targetVec2.x,
		["y"] = capc.targetVec2.y-40000,
		["action"] = "Turning Point",
		["alt_type"] = "BARO",
		["speed"] = 600,
		["form"] = "Turning Point",
		["type"] = "Turning Point",
		["task"] = {
			["id"] = 'ComboTask',
			["params"] = {
				["tasks"] = { 
                [1] = { 
                    id = 'Bombing', --If missionData.group ~= nil attack group instead
                    params = { 
                        point = capc.targetVec2, 
                        attackQty = 1,
                        expend = "All",
                        } 
                    }
                },
			},
		},
	}
    
    _groupData.route = {
        _takeoffPoint,
        _targetPoint,
    }
    mist.dynAdd(_groupData)
    
    local _freqTask = { 
        id = 'SetFrequency', 
        params = { 
          frequency = capc.frequency * 1000000, 
          modulation = 0, 
        } 
      }

    local group = Group.getByName(tostring("capc-"..capc.counter))
    local controller = group:getController()

    controller:setCommand(_freqTask)
    controller:setOption(1, 0)
    
    capc.objectives[capc.counter] = {"escortBlue", group, "active", _groupID}

    trigger.action.outText("Uzi 4 taking off from Basel El Assad, performing strike on primatery target.", 5, false)
    STTS.TextToSpeech("Uzi 4 taking off from Basel El Assad, performing strike on primatery target.", 300, "AM", "1.0", "SERVER", 2)

    if capc.debug == true then
        trigger.action.outText("escortBlue Spawned", 5, false)
    end
end

function capc.escortGreySpawn(_groupID)
    local _startpoint = capc.baseGrey[math.random(1, #capc.baseGrey)]

    local _groupData = mist.getGroupData(capc.escortGrey[math.random(1,#capc.escortGrey)])
    capc.counter = capc.counter + 1
    _groupData.clone = true
    _groupData.groupName = tostring("capc-"..capc.counter)

    _takeoffPoint = {
		['type'] = "TakeOff",
		['form'] = "From Runway",
		['action'] = "From Runway",
		['airdromeId'] = _startpoint,
		["task"] = {
            id = 'NoTask', 
            params = {}
	    },
    }
    
    local _vec2 = mist.utils.makeVec2(mist.utils.zoneToVec3(capc.redTarget[math.random(1, #capc.redTarget)]))
    
    _targetPoint = {
		["alt"] = math.random(capc.minAltitude, capc.maxAltitude),
		["x"] = _vec2.x,
		["y"] = _vec2.y,
		["action"] = "Turning Point",
		["alt_type"] = "BARO",
		["speed"] = 600,
		["form"] = "Turning Point",
		["type"] = "Turning Point",
		["task"] = {
            id = 'NoTask', 
            params = {}
	    },
	}
    
    _groupData.route = {
        _takeoffPoint,
        _targetPoint,
    }
    mist.dynAdd(_groupData)

    timer.scheduleFunction(capc.overlordUpdate, _group, timer.getTime() + 5 )

    local group = Group.getByName(tostring("capc-"..capc.counter))

    capc.objectives[capc.counter] = {"escortGrey", group, "active", _groupID}

    if capc.debug == true then
        trigger.action.outText("escortGrey Spawned", 5, false)
        env.info(dump(mist.getGroupRoute(group:getName())))
    end

    --mist.getUnitsInMovingZones(table unitNameTable ,table zoneUnitNames ,number radius , string zoneType )
    -- if blue cap flight within range, call intercept script
    -- completion = intercepted + distance away from targetvec2
end

function capc.escortRedSpawn(_groupID)
    local _bases = coalition.getAirbases(1)
    local _startpoint = mist.utils.makeVec2(_bases[math.random(1, #_bases)]:getPoint())
    local _groupData = {}
    _groupData.groupName = capc.escortRed[math.random(1,#capc.escortRed)]
    capc.counter = capc.counter + 1
    _groupData.newGroupName = "capc-"..capc.counter
    _groupData.point = mist.utils.makeVec3(_startpoint)
    _groupData.action = "respawn"

    local _takeoffPoint = {
		["alt"] = math.random(capc.minAltitude, capc.maxAltitude),
		["x"] = _startpoint.x,
		["y"] = _startpoint.y,
		["action"] = "Turning Point",
		["alt_type"] = "BARO",
		["speed"] = 600,
		["form"] = "Turning Point",
		["type"] = "Turning Point",
        ["name"] = "Starting point",
		["task"] = {
            id = 'NoTask', 
            params = {}
	    },
	}   
    
    local _target = mist.utils.makeVec2(mist.utils.zoneToVec3(capc.redTarget[math.random(1, #capc.redTarget)]))

    local _targetPoint = {
		["alt"] = math.random(capc.minAltitude, capc.maxAltitude),
		["x"] = _target.x,
		["y"] = _target.y+20000, -- instead get a ip between start pos and target
		["action"] = "Turning Point",
		["alt_type"] = "BARO",
		["speed"] = 600,
		["form"] = "Turning Point",
		["type"] = "Turning Point",
		["name"] = "Target point",
        ["task"] = {
			["id"] = 'ComboTask',
			["params"] = {
				["tasks"] = { 
                [1] = { 
                    id = 'Bombing',
                    params = { 
                        point = _target, 
                        attackQty = 1,
                        expend = "All",
                        } 
                    }
                },
			},
		},
	}

    _groupData.route = {
        _takeoffPoint,
        _targetPoint,
    }
    mist.teleportToPoint(_groupData)
    
    local _group = Group.getByName(_groupData.groupName)
    local controller = _group:getController()

    controller:setOption(1, 0)
    
    capc.objectives[capc.counter] = {"escortRed", _group, "active", _groupID}

    if math.random(1, capc.escortedChange) == 1 then
        _groupDataEscort = {}
        _groupDataEscort.groupName = capc.redCap[math.random(1,#capc.redCap)]
        _groupDataEscort.point = mist.utils.makeVec3(_startpoint)
        _groupDataEscort.action = "respawn"

        _escortRouteStart = {
            ["alt"] = math.random(capc.minAltitude, capc.maxAltitude),
            ["x"] = _startpoint.x,
            ["y"] = _startpoint.y,
            ["action"] = "Turning Point",
            ["alt_type"] = "BARO",
            ["speed"] = 600,
            ["form"] = "Turning Point",
            ["type"] = "Turning Point",
            ["name"] = "Escort point",
            ["task"] = {
                ["id"] = 'ComboTask',
                ["params"] = {
                    ["tasks"] = { 
                    [1] = {
                        id = 'Escort',
                        params = {
                            groupId = _group:getID(),
                            pos = {x = 100, y = 0, z = 100},
                            engagementDistMax = 55000,
                            lastWptIndexFlag = false,
                            targetTypes = {"AIRPLANE"}
                            }    
                        } 
                    },
                },
            },
        }
        _escortRouteEnd = {
            ["alt"] = math.random(capc.minAltitude, capc.maxAltitude),
            ["x"] = _target.x,
            ["y"] = _target.y+20000,
            ["action"] = "Turning Point",
            ["alt_type"] = "BARO",
            ["speed"] = 600,
            ["form"] = "Turning Point",
            ["type"] = "Turning Point",
            ["name"] = "Escort point",
            ["task"] = {
                ["id"] = 'ComboTask',
                ["params"] = {
                    ["tasks"] = { 
                    [1] = {
                        id = 'Escort',
                        params = {
                            groupId = _group:getID(),
                            pos = {x = 100, y = 0, z = 100},
                            engagementDistMax = 55000,
                            lastWptIndexFlag = false,
                            targetTypes = {"Air"}
                            }    
                        } 
                    },
                },
            },
        }

        _groupDataEscort.route = {_escortRouteStart, _escortRouteEnd}
        mist.teleportToPoint(_groupDataEscort)
    end

    timer.scheduleFunction(capc.overlordUpdate, _group, timer.getTime() + 5 )

    if capc.debug == true then
        trigger.action.outText("escortRed Spawned", 5, false)
    end
end

function capc.overlordUpdate(_group)
    local _pos = _group:getUnit(1):getPoint()
    local _zone = trigger.misc.getZone(capc.blueZone)
    local _distance = mist.utils.get2DDist(_zone.point, _pos)
    
    if _distance <= _zone.radius then
        local _bulls = coalition.getMainRefPoint(2) 
        local _altitude = (_pos.y * 3.28 )/1000 
        local _relVec3 = mist.vec.sub(_bulls, _pos)
        local _heading = math.atan2(_relVec3.z, _relVec3.x)
        local _message = "Intercept target in friendly airspace at BRA "..tostring(_heading)..", "..tostring(_distance*0.00539).."miles, flightlevel "..tostring(_altitude)..". ROE is hold fire until visual identification or agressive action."
        STTS.TextToSpeech(_message, 300, "AM", "1.0", "SERVER", 2)

        for i = 1, #capc.groups do
            local _groupID = Group.getByName(capc.groups[i]):getID()
            if capc.states[_groupID] == "active" or capc.states[_groupID] == "tasked" then
                trigger.action.outTextForGroup(_groupID, _message, 10, false)
            end
        end
        
        timer.scheduleFunction(capc.overlordUpdate, _group, timer.getTime() + capc.overlordTimer )
    else 
        timer.scheduleFunction(capc.overlordUpdate, _group, timer.getTime() + 5 )
    end
end

function capc.checkObjectives()
    for i = 1, capc.counter do
        local _table = capc.objectives[i]
        local _category = _table[1]
        local _group = _table[2]
        local _state = _table[3]
        local _groupID = _table[4] --GroupID of the tasked group
        local _size = _group:getInitialSize()
        
        for y = 1, _size do
            if _group:getUnit(y):getLife() <= 1 then
                _deadcounter = _deadCounter + 1
            end
        end
        
        if _deadcounter == _size and _state ~= "completed" then
            capc.objectives[i] = nil
            if _category == "escortBlue" then
                trigger.action.outText("Uzi 4 is going down!", 10, false)
                STTS.TextToSpeech("Uzi 4 is going down!", 300, "AM", "1.0", "SERVER", 2)
                timer.scheduleFunction(capc.genTask, _groupID, timer.getTime() + 5 )
            elseif _category == "escortRed" then
                trigger.action.outText("Splash bandits, continue patrol", 10, false)
                STTS.TextToSpeech("Splash bandits, continue patrol", 300, "AM", "1.0", "SERVER", 2)
                timer.scheduleFunction(capc.genTask, _groupID, timer.getTime() + 5 )
            elseif _category == "escortGrey" then
                trigger.action.outText("Splash civilian! hold fire hold fire!", 10, false)
                STTS.TextToSpeech("Splash civilian! hold fire hold fire!", 300, "AM", "1.0", "SERVER", 2)
                timer.scheduleFunction(capc.genTask, _groupID, timer.getTime() + 5 )
            end
        end
        
        if _state == "completed" and _category == "escortGrey" then
            trigger.action.outText("Escort has been completed, continue patrol", 10, false)
            STTS.TextToSpeech("Escort has been completed, continue patrol", 300, "AM", "1.0", "SERVER", 2)
            timer.scheduleFunction(capc.genTask, _groupID, timer.getTime() + 5 )
        end

        if capc.debug == true then
            local _message = "CAPC Objective: "..tostring(_group).." Type: ".._category.." State: ".._state
            trigger.action.outText(_message, 5, false)
        end
    end
    timer.scheduleFunction(capc.checkObjectives, nil, timer.getTime() + 5 )
end

function capc.addRadioMenus(event)
    if event.id == 20 then
        local _group = event.initiator:getGroup():getName()
        for i = 1, #capc.groups, 1 do
            if capc.groups[i] == _group then
                local _groupID = event.initiator:getGroup():getID()
                capc.radioCheckin = missionCommands.addCommandForGroup(_groupID, "CAP Check in", nil, capc.checkin, _groupID)
            end
        end
    end
end

do
    trigger.action.outText("CAPCheckin Init started", 5, false)
    
    mist.addEventHandler(capc.addRadioMenus)
    timer.scheduleFunction(capc.checkObjectives, {}, timer.getTime() + 5 )
end