-- General Settings --
secObjectiveCount = 6
enableDebug = true
markerScatter = 500

-- Set templates --
primObjectiveList = {"primObjective #001", "primObjective #002", "primObjective #002"}
airbaseList = {"airbase #001", "airbase #002"}
secObjectiveList = {"secObjective #001", "secObjective #002", "secObjective #003", "secObjective #004", "secObjective #005", "secObjective #006"}
samList = {"SAM #001", "SAM #002", "SAM #003"}
ewrList = {"EWR #001", "EWR #002", "EWR #003"}
blueGround = {"blueGround #001"}

-- Set secObjective names, must match secObjectiveList --
secObjectiveNames = {"Scud site", "Silkworm site", "Artillery battery", "Early Warning Radar", "FOB", "FOB"}

-- Set Special objectives, must match names in secObjectiveList --
groundBattles = {"secObjective #005", "secObjective #006"}

-- Set templates that need a EWR --
ewrTemplates = {"secObjective #004"}
-- Set Statics
staticList = {"Workshop A", "Farm A", "Farm B", "Comms tower M", "Command Center", "Chemical tank A"}

-- Set zones for possible spawning of objectives --
objectiveLocList = {"zone #001", "zone #002", "zone #003", "zone #004"}

-- Set IADS airbase EWR --
airbaseEWR = {"EWR Base #001", "EWR Base #002"}

-- TODO --
    -- Airports as potential primary objectives
    -- Function to decrease A2A Dispatcher after EWR/factory destroyed
    -- Convoys/patrols
    -- Helicopter missions
    -- JTAC
    -- Mission flow (messages)
    -- Dispatcher takeofffromparking
    
    -- Briefing kneeboard 
    -- Statics

-- Do not change --

secObjective = {} -- index is secObjectiveId, value name (use for mission flow)
primCompletedFlag = 99
primMarker = 98
secCompletion = {}
objectiveCounter = 0
IADS = SkynetIADS:create('IADS-Network')
ewrGroups = {}

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

for i = 1,#airbaseEWR,1 do
    IADS:addEarlyWarningRadar(airbaseEWR[i])
end

function genPrimObjective()
    primCompletion = false

    primObjective = primObjectiveList[math.random(#primObjectiveList)]
    objectiveLoc = objectiveLocList[math.random(#objectiveLocList)]

    primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false)
    objectiveCounter = objectiveCounter + 1
    vec3Prim = mist.getLeadPos('IRAN gnd '..tostring(objectiveCounter))
    markObjective("Primary Objective" , 'IRAN gnd '..tostring(objectiveCounter), primMarker)

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
    ewrGroups[#ewrGroups + 1] = ewrGroup
    local ewrUnit = ewrGroup:getUnit(1):getName()
    IADS:addEarlyWarningRadar(ewrUnit)

    mist.flagFunc.group_alive_less_than {
        groupName = 'IRAN gnd '..tostring(objectiveCounter),
        flag = primCompletedFlag,
        percent = 40,
    }

    if enableDebug == true then
        notify(primObjective.."@"..objectiveLoc, 1)
    end 
end

function genSecObjective(secObjectiveId)
    secCompletion[secObjectiveId] = false
    
    local randomNo = math.random(#secObjectiveList)
    secObjective[secObjectiveId] = secObjectiveList[randomNo]
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
    markObjective(secObjectiveNames[randomNo] , 'IRAN gnd '..tostring(objectiveCounter), objectiveCounter)

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
            ewrGroups[#ewrGroups + 1] = ewrGroup
            local ewrUnit = ewrGroup:getUnit(1):getName()
            IADS:addEarlyWarningRadar(ewrUnit)

            mist.flagFunc.group_alive_less_than {
                groupName = 'IRAN gnd '..tostring(objectiveCounter),
                flag = 100 + secObjectiveId,
                percent = 40,
            }
        else
            mist.flagFunc.group_alive_less_than {
                groupName = 'IRAN gnd '..tostring(objectiveCounter),
                flag = 100 + secObjectiveId,
                percent = 40,
            }
        end
    end
    
    for i = 1,#groundBattles,1 do
        if secObjective[secObjectiveId] == groundBattles[i] then
            local vec3 = mist.getLeadPos("IRAN gnd "..tostring(objectiveCounter))
            local vec3off = {
                x = 700,
                y = 700,
                z = 0
            }
            mist.teleportToPoint{
                groupName = blueGround[math.random(#blueGround)],
                point = mist.vec.add(vec3, vec3off),
                action = "clone", 
            }
            objectiveCounter = objectiveCounter + 1
            
            local SetImmortal = { 
                id = 'SetImmortal', 
                params = { 
                  value = true 
                } 
            }

            local controller = Group.getByName("USA gnd "..objectiveCounter):getController()
            controller:setCommand(SetImmortal)

            mist.flagFunc.group_alive_less_than {
                groupName = 'IRAN gnd '..tostring(objectiveCounter),
                flag = 100 + secObjectiveId,
                percent = 40,
            }
        end
    end
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

    mist.flagFunc.group_alive_less_than {
        groupName = 'IRAN gnd '..tostring(objectiveCounter),
        flag = 200,
        percent = 40,
    }
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

function markObjective(markerName, groupName, secObjectiveId)
    local vec3Random = {
        x = math.random(-markerScatter,markerScatter),
        y = math.random(-markerScatter,markerScatter),
        z = math.random(-markerScatter,markerScatter)
    }
    local vec3 = mist.vec.add(mist.getLeadPos(groupName), vec3Random)
    trigger.action.markToAll(secObjectiveId, markerName, vec3, true)
end

function checkPrimCompleted() --Needs work
    if trigger.misc.getUserFlag(primCompletedFlag) == 1 and primCompletion == false then
        notify("Primary objective has been completed!", 5)
        trigger.action.removeMark(primMarker)
    end
end

function checkSecCompleted()
    for i = 1,secObjectiveCount,1 do
        if trigger.misc.getUserFlag(100+i) == 1 and secCompletion[i] == false then
            notify("Secondary objective has been completed!"..tostring(i), 5) --add support for naming, problems here
            trigger.action.removeMark(i)
        end
    end
end

function notify(message, displayFor)
    trigger.action.outTextForCoalition(coalition.side.BLUE, message, displayFor)
end

function A2A_DISPATCHER()
    
    --Define Detecting network
    DetectionSetGroupRED = SET_GROUP:New()
    DetectionSetGroupRED:FilterPrefixes( { "EWR Base", "AWACS Red #001"} )
    DetectionSetGroupRED:FilterStart()

    IADS:addMooseSetGroup(DetectionSetGroupRED)
    DetectionRED = DETECTION_AREAS:New( DetectionSetGroupRED, 5000 )

    --Init Dispatcher
    A2ADispatcherRED = AI_A2A_DISPATCHER:New( DetectionRED, 30000 )

    --Define Border
    BorderRED = ZONE_POLYGON:New( "BORDER Red", GROUP:FindByName( "BORDER Red" ) )
    A2ADispatcherRED:SetBorderZone( BorderRED )

    --Define EngageRadius
    A2ADispatcherRED:SetEngageRadius( 150000 )

    --Define Squadrons

    A2ADispatcherRED:SetSquadron( "CAP_RED_1", AIRBASE.PersianGulf.Kerman_Airport, {"CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010"} )
    A2ADispatcherRED:SetSquadron( "CAP_RED_2", AIRBASE.PersianGulf.Shiraz_International_Airport, {"CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010"} )

    --Define Squadron properties
    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_1", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_1", 2 )

    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_2", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_2", 2 )

    --Define CAP Squadron execution
    A2ADispatcherRED:SetSquadronCap( "CAP_RED_1", BorderRED,  6000, 8000, 600, 900, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_1", 2, 500, 600, 1)

    A2ADispatcherRED:SetSquadronCap( "CAP_RED_2", BorderRED,  3000, 9000, 400, 800, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_2", 1, 500, 600, 1)

    --Debug
    A2ADispatcherRED:SetTacticalDisplay( true )

    --Define Defaults
    A2ADispatcherRED:SetDefaultTakeOffInAir()
    A2ADispatcherRED:SetDefaultLandingAtRunway()
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
    
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
    --timer.scheduleFunction(checkSecCompleted, {}, timer.getTime() + 1)

    IADS:activate()
    A2A_DISPATCHER()

    notify("Completed init", 1)
end


