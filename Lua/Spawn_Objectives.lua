--Handles all objectives in War of PG/AB 2 missions

objectivesTable = {}                                --index is 1,2,3 for the generated objectives
objectivesLocation = {}                             --index is 1,2,3 for locations in vec3 for objectives
objectiveTypes = {}
objectivesCompleted = {false, false, false}         --index is 1,2,3 value true or false 
completed = 0                                       --counter of how many objectives are completed

unitDeadList1 = 0
unitDeadList2 = 0
unitDeadList3 = 0

bases = 17
convoys = 4
ships = 7
scuds = 7
totalobjectives = bases + convoys + ships + scuds

sar = 4
sam = 3
secMissionCount = 4 --change to sar+sam

function genMission(objectiveId)
    if objectiveId == 1 then
        baseId = math.random(1,bases)                     --ensures at least one base is spawned (objectiveId 1-bases
        objectivesTable[#objectivesTable+1]=baseId
    elseif objectiveId == 2 then                
        baseId =  math.random(bases + 1, totalobjectives) 
        duplicateCheck(baseId, objectiveId)
        objectivesTable[#objectivesTable+1]=baseId
    elseif objectiveId == 3 then
        baseId =  math.random(bases+convoys, totalobjectives)
        duplicateCheck(baseId, objectiveId)
        objectivesTable[#objectivesTable+1]=baseId
    end
    return baseId
end

function duplicateCheck(baseId, objectiveId)                     
    if baseId == objectivesTable[objectiveId - 1] then
           objectivesTable[objectiveId] = genMission(objectiveId)
    else
        return
    end
end

function genSecondaryMission()
    secMissionId = math.random(1, secMissionCount)

    if secMissionId >= 1 and secMissionId <= sar then
        --ctld.spawnGroupAtTrigger("blue", 2, "sar"..tostring(secMissionId), 500)
        local sarStatic = Group.getByName("sarStatic"..tostring(secMissionId))
        trigger.action.activateGroup(sarStatic)
        local vec3 = sarStatic:getUnit(1):getPosition().p
        trigger.action.markToAll(60+secMissionId, "SAR "..tostring(secMissionId), vec3, true)
        trigger.action.effectSmokeBig(vec3, 5, 1)
        
        local sarUnit = Group.getByName("sarUnit"..tostring(secMissionId))
        trigger.action.activateGroup(sarUnit)
        
        sarCompletion = false
        trigger.action.setUserFlag("80", 2 )
        --add checkobjectives support
        --beacons?
        --completion
        --notify("SAR Objective added.", 5)
    end
end

function activateGroup(baseId, objectiveId)
    local baseIdString = getObjectiveString(baseId, objectiveId)
    notify("Generated objective "..tostring(objectiveId).." as "..tostring(baseId), 1)

    if baseId >= 10 and baseId <= bases then                                    
        ewrBaseString = "ewrBase #0"..tostring(baseId)
        local ewrBase = Group.getByName(ewrBaseString)
        trigger.action.activateGroup(ewrBase)
    elseif baseId <= 10 then
        ewrBaseString =  "ewrBase #00"..tostring(baseId)
        local ewrBase = Group.getByName(ewrBaseString)
        trigger.action.activateGroup(ewrBase)

        --samBaseString = "SAM-base"..tostring(baseId)
        --local samBase = Group.getByName(samBaseString)
        --trigger.activateGroup(samBase)

    end

    local group = Group.getByName(baseIdString)
    
    trigger.action.activateGroup(group)

    local markId = baseId + 10                      --data for markers, offset to avoid overlap
    local vec3 = group:getUnit(1):getPosition().p
    local groupID = group:getID()

    objectivesLocation[objectiveId] = vec3
    
    if baseId <=bases then
        recce = Group.getByName("JTAC for Base "..tostring(baseId))
        trigger.action.activateGroup(recce)
        activateDesignate(baseId)

        samBaseString = "SAM-base"..tostring(baseId)
        local samBase = Group.getByName(samBaseString)
        trigger.activateGroup(samBase)

        notify("Sam Activated",1)
    end    


    markObjective(markId, baseId, vec3)             --marks objectives
    trigger.action.setUserFlag(tostring(100+objectiveId), 0)

    mist.flagFunc.group_alive_less_than {
        groupName = baseIdString,
        flag = 100 + objectiveId,
        percent = 40,
      }
end

function activateDesignate(baseId)
    ctld.JTACAutoLase('JTAC for Base '..tostring(baseId), 1688, false, "all", 3)
end

function checkCompleted()
    for i = 1,3,1 do
        if trigger.misc.getUserFlag(tostring(100+i)) == 1 and objectivesCompleted[i] == false then --add second to avoid
            notify(nameObjective(objectivesTable[i]).." has been destroyed.", 5)
            objectivesCompleted[i]=true
            completed = completed + 1
            removeMark(i)
            objectivesCompletedFunc()
            trigger.action.setUserFlag(tostring(100+i), 0)
        end 
    end
    --notify("checkCompleted", 1)
    
    if secMissionId >= 1 and secMissionId <= sar and sarCompletion == false then
        ctld.countDroppedGroupsInZone("sar"..tostring(secMissionId), 80, 81) --80, 81 are flags for count blue and red resp. 
        local count = trigger.misc.getUserFlag("80")
        if count < 1 then
            notify("Search and Rescue completed", 5)
            trigger.action.removeMark(60+secMissionId)
            sarCompletion = true
        end
    end

    timer.scheduleFunction(checkCompleted, {}, timer.getTime() + 1)
end

function markObjective(markId, baseId, vec3)
    if baseId <= bases then    
        trigger.action.markToAll(markId, nameObjective(baseId), vec3, true)
    elseif baseId >= bases + 1 and baseId <= bases+convoys then
        trigger.action.markToAll(markId, nameObjective(baseId).." start", vec3, true)
        
        local wp =  Group.getByName("wp"..tostring(baseId-bases))     

        local markWpId = baseId + 21
        local vec3Wp = wp:getUnit(1):getPosition().p
        local markWpName = "Convoy "..tostring(baseId - bases).." end"

        trigger.action.markToAll(markWpId, markWpName, vec3Wp, true)
    elseif baseId >= bases+convoys+1 and baseId <= bases+convoys+ships then
        trigger.action.markToAll(markId, nameObjective(baseId), vec3, true)
    elseif baseId >= bases+convoys+ships+1 then
        trigger.action.markToAll(markId, nameObjective(baseId), vec3, true)
    end
end

function removeMark(objectiveId)
    local markIdr = objectivesTable[objectiveId] + 10
    if objectivesTable[objectiveId] <= bases then --replace with gettype
        trigger.action.removeMark(markIdr)
    elseif baseId >= bases + 1 and baseId <= bases+convoys then
        trigger.action.removeMark(markIdr)
        trigger.action.removeMark(markIdr + 11)
    elseif baseId >= bases+convoys+1 and baseId <= bases+convoys+ships then
        trigger.action.removeMark(markIdr)
    elseif baseId >= bases+convoys+ships+1 then
        trigger.action.removeMark(markIdr)
    end
end

function getObjectiveString(baseId,objectiveId)
    if baseId <= bases then
        local type = "base"
        objectiveTypes[objectiveId] = type
        return type..tostring(baseId)
    elseif baseId >= bases+1 and baseId <= bases+convoys then
        local type = "convoy"
        objectiveTypes[objectiveId] = type
        return type..tostring(baseId - bases)
    elseif baseId >= bases+convoys+1 and baseId <= bases+convoys+ships then
        local type = "ship"..tostring(baseId - (bases+convoys))
        objectiveTypes[objectiveId] = type
        return type
    elseif baseId >= bases+convoys+ships+1 then
        local type = "scud"
        objectiveTypes[objectiveId] = type
        return type..tostring(baseId - (bases+convoys+ships))
    end
end

function nameObjective(baseId)
    if baseId <= bases then
        return "Base "..tostring(baseId)
    elseif baseId >= bases+1 and baseId <= bases+convoys then
        return "Convoy "..tostring(baseId - bases)
    elseif baseId >= bases+convoys+1 and baseId <= bases+convoys+ships then
        local subs = bases+convoys+1 + 6
            if baseId >= subs then
                return "Submarine "..tostring(baseId - (bases+convoys))
            else
                return "Ship "..tostring(baseId - (bases+convoys))
            end
    elseif baseId >= bases+convoys+ships+1 then
        return "Scud Launcher "..tostring(baseId - (bases+convoys+ships))
    end
end

function objectiveLocationMessage(baseId, axis)
    --notify("objectiveLocationMessage",1)
    local vec3 = objectivesLocation[baseId]
    local lat, lon, alt = coord.LOtoLL(vec3)
    --notify("converted",1)
    
    local latDeg = math.floor(lat)
	local latMin = roundNumber((lat - latDeg)*60, 2)
	
	local lonDeg = math.floor(lon)
	local lonMin = roundNumber((lon - lonDeg)*60, 2)

    local altFeet = alt * 3.28
    local altRound = roundNumber(altFeet)

    latString = tostring(latDeg).." "..tostring(latMin)
    lonString = tostring(lonDeg).." "..tostring(lonMin)
    altString = tostring(alt)

    local ll = { latString, lonString, altRound }

    return ll[axis]
end

function objectivesCompletedFunc()                    --tbd
    if completed  >= 3 then
        trigger.action.setUserFlag("90", 1)
        notify("All objectives have been completed, mission restarting in 10 minutes", 10)
    else
        return
    end
end

function notifyObjectives()
    messageObjectives = "Current primary objectives:"
    for i = 1,3,1 do
        if objectivesCompleted[i] == false then
            messageObjectives = messageObjectives.."\n- "..nameObjective(objectivesTable[i]).." at "..objectiveLocationMessage(i, 1).." N, "..objectiveLocationMessage(i, 2).." E, "..objectiveLocationMessage(i, 3).." ft."
        end 
    end
    if sarCompletion == false then
        messageObjectives = messageObjectives.."\n \n".."Secondary objective:\n- ".."Search and Rescue (SAR) "..tostring(secMissionId).."."
    end
    notify(messageObjectives, 20)
end

function notify(message, displayFor)
    trigger.action.outTextForCoalition(coalition.side.BLUE, message, displayFor)
end

function roundNumber(num, idp)                                              -- From http://lua-users.org/wiki/SimpleRound
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
  end

do                                                                          --main setup
    _SETTINGS:SetPlayerMenuOff()
    notify("starting init", 1)

    missionCommands.addCommand("Check current objectives", nil, notifyObjectives)

    --genSecondaryMission()
    
    mission1 = genMission(1)
    mission2 = genMission(2)
    mission3 = genMission(3)

    for i = 1, 17, 1 do
        activateGroup(i, i)   
    end 

    --activateGroup(objectivesTable[1], 1)
    --activateGroup(objectivesTable[2], 2)
    --activateGroup(objectivesTable[3], 3)
    notify("missions spawned", 1)

    timer.scheduleFunction(checkCompleted, {}, timer.getTime() + 1)

    notify("init complete", 1)
end