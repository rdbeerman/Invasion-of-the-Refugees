-- General Settings --
secObjectiveCount = 6
enableDebug = true
markerScatter = 500

-- Set template objectives --
primObjectiveList = {"primObjective #001", "primObjective #002", "primObjective #002"}
secObjectiveList = {"secObjective #001", "secObjective #002", "secObjective #003", "secObjective #004"}
samList = {"SAM #001", "SAM #002", "SAM #003"}
ewrList = {"EWR #001", "EWR #002", "EWR #003"}

-- Set templates that need a EWR --
ewrTemplates = {"secObjective #004"}
-- Set Statics
staticList = {"Workshop A", "Farm A", "Farm B", "Comms tower M", "Command Center", "Chemical tank A"}

-- Set zones for possible spawning of objectives --
objectiveLocList = {"zone #001", "zone #002", "zone #003", "zone #004"}

-- TODO --
    -- Build prim/secObjectiveList by filtering form prim/secObjective (using MOOSE filterbyprefix?)
    -- Concequences of secObjectives
    -- Consider second vec3Offset for 'supporting' secObjectives
    -- Function to decrease A2A Dispatcher after EWR/factory destroyed
    -- Add sams to A2A Dispatcher
    -- Objective Naming
    -- Convoys
    -- Helicopter missions
    -- Completion
-- Do not change --

secObjective = {}
objectiveCounter = 0
IADS = SkynetIADS:create('IADS-Network')

vec3Offset = {
    x = -13000,
    y = 0,
    z = 0
}

if enableDebug == true then
    local iadsDebug = IADS:getDebugSettings()
    iadsDebug.IADSStatus = true
    iadsDebug.samWentDark = true
    iadsDebug.contacts = true
    iadsDebug.radarWentLive = true
    iadsDebug.ewRadarNoConnection = true
    iadsDebug.samNoConnection = true
    iadsDebug.jammerProbability = true
    iadsDebug.addedEWRadar = true
    iadsDebug.hasNoPower = true
    iadsDebug.addedSAMSite = true
    iadsDebug.warnings = true
    iadsDebug.harmDefence = true
    iadsDebug.samSiteStatusEnvOutput = true
    iadsDebug.earlyWarningRadarStatusEnvOutput = true
end

function genPrimObjective()
    objectiveCompleted = false

    primObjective = primObjectiveList[math.random(#primObjectiveList)]
    objectiveLoc = objectiveLocList[math.random(#objectiveLocList)]

    primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false)
    objectiveCounter = objectiveCounter + 1
    vec3Prim = mist.getLeadPos('IRAN gnd '..tostring(objectiveCounter))
    markObjective("Primary Objective" , 'IRAN gnd '..tostring(objectiveCounter), objectiveCounter)

    mist.teleportToPoint {
        groupName = ewrList[math.random(#ewrList)],
        point = vec3Prim,
        action = "clone",
        disperse = false,
        radius = 700,
        innerRadius = 200
    }

    genStatics(vec3Prim, 2)

    objectiveCounter = objectiveCounter + 1
    local ewrGroup = Group.getByName('IRAN gnd '..tostring(objectiveCounter))
    local ewrUnit = ewrGroup:getUnit(1):getName()
    IADS:addEarlyWarningRadar(ewrUnit)

    if enableDebug == true then
        notify(primObjective.."@"..objectiveLoc, 1)
    end 
end

function genSecObjective(secObjectiveId)
    secObjective[secObjectiveId] = secObjectiveList[math.random(#secObjectiveList)]
    vec3Sec = mist.vec.add(vec3Prim, vec3Offset)
    
    mist.teleportToPoint {
        groupName = secObjective[secObjectiveId],
        point = vec3Sec,
        action = "clone",
        disperse = false,
        radius = 12000,
        innerRadius = 0,
    }
    objectiveCounter = objectiveCounter + 1
    for i = 1,#ewrTemplates,1 do
        if secObjective[secObjectiveId] == ewrTemplates[i] then
            local vec3 = mist.getLeadPos("IRAN gnd "..tostring(objectiveCounter))
            local vec3off = {
                x = 40,
                y = 0,
                z = 0
            }
            mist.teleportToPoint{
                groupName = ewrList[math.random(#ewrList)],
                point = mist.vec.add(vec3, vec3off),
                action = "clone", 
            }
            objectiveCounter = objectiveCounter + 1
            local ewrGroup = Group.getByName('IRAN gnd '..tostring(objectiveCounter))
            local ewrUnit = ewrGroup:getUnit(1):getName()
            IADS:addEarlyWarningRadar(ewrUnit)
        end
    end
    
    markObjective("Secondary Objective" , 'IRAN gnd '..tostring(objectiveCounter), objectiveCounter)
end

function genSam()
    sam = samList[math.random(#samList)]
    mist.teleportToPoint {
        groupName = sam,
        point = vec3Prim,
        action = "clone",
        disperse = false,
        radius = 3000,
        innerRadius = 500
    }
    objectiveCounter = objectiveCounter + 1
    IADS:addSAMSite('IRAN gnd '..tostring(objectiveCounter))
    markObjective("SAM Site", 'IRAN gnd '..tostring(objectiveCounter), objectiveCounter)
end

function genStatics(vec3, amount)
    local vec2 = mist.utils.makeVec2(vec3) 
    for amount = 1, 3, 1 do
        mist.dynAddStatic {
            type = staticList[math.random(#staticList)], 
            country = "Iran", 
            category = "Fortifications", 
            x = vec2.x + 50 * amount, 
            y = vec2.y + 50 ,
            --groupName/name = string groupName/name, 
            --groupId = number groupId,  
            heading = 0,
        }
    end
end

function notify(message, displayFor)
    trigger.action.outTextForCoalition(coalition.side.BLUE, message, displayFor)
end

function markObjective(markerName, groupName, objectiveCounter)
    local vec3Random = {
        x = math.random(-markerScatter,markerScatter),
        y = math.random(-markerScatter,markerScatter),
        z = math.random(-markerScatter,markerScatter)
    }
    local vec3 = mist.vec.add(mist.getLeadPos(groupName), vec3Random)
    trigger.action.markToAll(objectiveCounter, markerName, vec3, true)
end

-- MAIN SETUP --
do
    notify("Starting init", 1)
    _SETTINGS:SetPlayerMenuOff()
    genPrimObjective()
    genSam()
    for i = 1,secObjectiveCount,1 do
        genSecObjective(i)
    end
    
    --timer.scheduleFunction(checkCompleted, {}, timer.getTime() + 1)
    IADS:activate()
    notify("Completed init", 1)
end
