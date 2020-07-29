-- General Settings --
secObjectiveCount = 2
enableDebug = false
markerScatter = 1000
compThres = 60

-- Set templates --
primObjectiveList = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #001", "airbase #002"}
airbaseList = {"airbase #001", "airbase #002"}

secObjectiveList = {"secObjective #001", "secObjective #002", "secObjective #003", "secObjective #004", "secObjective #005", "secObjective #006"}
samList = {"SAM #001", "SAM #002", "SAM #003", "SAM #004", "SAM #005" }
ewrList = {"EWR #001", "EWR #002", "EWR #003"}
blueGround = {"blueGround #001"}

-- Set secObjective names, secObjectiveNames must match secObjectiveList --
primNames = {"Headquarters", "Outpost", "Fuel Depot", "Compound", "Presidio", "Armory"}
secObjectiveNames = {"Scud site", "Silkworm site", "Artillery battery", "Early Warning Radar", "FOB", "FOB"}

-- Set Special objectives, must match names in secObjectiveList --
groundBattles = {"secObjective #005", "secObjective #006"}

-- Set templates that need a EWR --
ewrTemplates = {"secObjective #004"}
-- Set Statics
staticList = {"Workshop A", "Farm A", "Farm B", "Comms tower M", "Chemical tank A", "Pump station", "Oil derrick"}

-- Set zones for possible spawning of objectives --
objectiveLocList = {"zone #001", "zone #002", "zone #003", "zone #004"}

-- Set IADS airbase EWR --
airbaseEWR = {"EWR Base #001", "EWR Base #002"}

-- Set airbase Zones, unmarker SAM sites will be places here --
airbaseZones = {"airbaseZone #001", "airbaseZone #002"}

-- TODO --
    -- Function to decrease A2A Dispatcher after EWR/factory destroyed
    -- Convoys/patrols
    -- Helicopter missions
    -- JTAC
    -- FARP as objective
    -- Combined Arms
    -- Escort objectives 

-- Do not change --

secObjective = {} -- index is secObjectiveId, value name (use for mission flow)
primCompletedFlag = 99
primMarker = 98
secCompletion = {}
objectiveCounter = 0
IADS = SkynetIADS:create('IADS-Network')
ewrGroups = {}
statics = {}
vec3Sam = {}
isAirfield = false

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

    for i = 1,#airbaseList,1 do
        if primObjective == airbaseList[i] then
            isAirfield = true

            local airbase = Group.getByName(primObjective)
            trigger.action.activateGroup(airbase)

            primName = "Airbase"
            vec3Prim = mist.getLeadPos(primObjective)
            markObjective("Objective: Airbase", primObjective, primMarker)

            mist.flagFunc.group_alive_less_than {
                groupName = primObjective,
                flag = primCompletedFlag,
                percent = compThres,
            }
        end
    end
    
    if isAirfield == false then
        primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false)
        objectiveCounter = objectiveCounter + 1
        vec3Prim = mist.getLeadPos('IRAN gnd '..tostring(objectiveCounter))

        mist.teleportToPoint {
            groupName = ewrList[math.random(#ewrList)],
            point = vec3Prim,
            action = "clone",
            disperse = false,
            radius = 700,
            innerRadius = 200
        }

        genStatics(vec3Prim, 2)
        genSam(vec3Prim, false)
        primNaming()
        local markerName = "Objective: "..tostring(primName)
        markObjective(markerName , 'IRAN gnd '..tostring(objectiveCounter), primMarker)
        

        objectiveCounter = objectiveCounter + 1
        local ewrGroup = Group.getByName('IRAN gnd '..tostring(objectiveCounter))
        ewrGroups[#ewrGroups + 1] = ewrGroup
        local ewrUnit = ewrGroup:getUnit(1):getName()
        IADS:addEarlyWarningRadar(ewrUnit)
        
        mist.flagFunc.group_alive_less_than {
            groupName = 'IRAN gnd '..tostring(objectiveCounter),
            flag = primCompletedFlag,
            percent = compThres,
        }
    end

    if enableDebug == true then
        notify(primObjective.."@"..objectiveLoc, 1)
    end 
end

function genSecObjective(secObjectiveId, mark)
    secCompletion[secObjectiveId] = false
    
    local randomNo = math.random(#secObjectiveList)
    secObjective[secObjectiveId] = secObjectiveList[randomNo]
    vec3Sec = mist.vec.add(vec3Prim, vec3Offset)
     
    mist.teleportToPoint {
        groupName = secObjective[secObjectiveId],
        point = vec3Sec,
        action = "clone",
        disperse = false,
        radius = 18000,
        innerRadius = 0,
    }
    
    objectiveCounter = objectiveCounter + 1
    if mark == true then
        markObjective(secObjectiveNames[randomNo] , 'IRAN gnd '..tostring(objectiveCounter), secObjectiveId)
    end
    
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
                percent = compThres,
            }
        else -- this only works with one ewr template
            mist.flagFunc.group_alive_less_than {
                groupName = 'IRAN gnd '..tostring(objectiveCounter),
                flag = 100 + secObjectiveId,
                percent = compThres,
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
        end
    end
end

function genSam(vec3, mark)
    sam = samList[math.random(#samList)]
    mist.teleportToPoint {
        groupName = sam,
        point = vec3,
        action = "clone",
        disperse = false,
        radius = 3000,
        innerRadius = 500
    }
    objectiveCounter = objectiveCounter + 1
    IADS:addSAMSite('IRAN gnd '..tostring(objectiveCounter))
    
    if mark == true then
        markObjective("SAM Site", 'IRAN gnd '..tostring(objectiveCounter), 100 + objectiveCounter)
    end

    vec3Sam[#vec3Sam + 1] = mist.getLeadPos('IRAN gnd '..tostring(objectiveCounter))

    mist.flagFunc.group_alive_less_than {
        groupName = 'IRAN gnd '..tostring(objectiveCounter),
        flag = 200,
        percent = compThres,
    }
end

function genStatics(vec3, amount)
    local vec2 = mist.utils.makeVec2(vec3) 
    for amount = 1, 3, 1 do
        local building = staticList[math.random(#staticList)]
        statics[#statics+1] = building
        if enableDebug == true then
            notify("Staticbuilder: "..tostring(building), 10)
        end
        mist.dynAddStatic {
            type = building, 
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

function primNaming() 
    for i = 1,6,1 do
        if statics[i] == "Workshop A" then
            local names = {"Factory", "Power plant"}
            primName = names[math.random(#names)]
            return
        else 
            primName = primNames[math.random(#primNames)]
        end
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

function notifyCoords(vec3, axis)
    local lat, lon, alt = coord.LOtoLL(vec3)

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

function checkPrimCompleted() -- Add support for statics
    if trigger.misc.getUserFlag(primCompletedFlag) == 1 and primCompletion == false then
        notify("Primary objective has been completed!", 5)
        trigger.action.removeMark(primMarker)
        primCompletion = true
    end
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
end

function checkSecCompleted()
    for i = 1,secObjectiveCount,1 do
        if trigger.misc.getUserFlag(100+i) == 1 and secCompletion[i] == false then
            notify("Secondary objective has been completed!", 5) --add support for naming, problems here
            trigger.action.removeMark(i)
            secCompletion[i] = true
        end
    end
    timer.scheduleFunction(checkSecCompleted, {}, timer.getTime() + 1)
end

function notifyObjective()
    if primCompletion == false then
        local message = "The primary objective is a Iranian "..primName.." that has been located in the area near: \n"
        message = message..notifyCoords(vec3Prim, 1).." N, "..notifyCoords(vec3Prim, 2).." E, "..notifyCoords(vec3Prim, 3).." ft.\n"
        message = message.."\n Beware, SAM sites have been spotted near: \n"

        for i = 1,#vec3Sam,1 do
            message = message.."- "..notifyCoords(vec3Sam[i], 1).." N, "..notifyCoords(vec3Sam[i], 2).."E, "..notifyCoords(vec3Sam[i],3).." ft.\n"
        end
        
        notify(message, 45)
    else
        notify("Primary objective has been completed, RTB.", 45)
    end
end

function notify(message, displayFor)
    trigger.action.outTextForCoalition(coalition.side.BLUE, message, displayFor)
end

function roundNumber(num, idp)                                              -- From http://lua-users.org/wiki/SimpleRound
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
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
    A2ADispatcherRED:SetEngageRadius( 180000 )

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
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_1", 1, 450, 550, 1)

    A2ADispatcherRED:SetSquadronCap( "CAP_RED_2", BorderRED,  3000, 9000, 400, 800, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_2", 1, 450, 550, 1)

    --Debug
    A2ADispatcherRED:SetTacticalDisplay( enableDebug )

    --Define Defaults
    A2ADispatcherRED:SetDefaultTakeoffFromParkingHot()
    A2ADispatcherRED:SetDefaultLandingAtRunway()
end

-- MAIN SETUP --
do
    notify("Starting init", 1)
    _SETTINGS:SetPlayerMenuOff()
    missionCommands.addCommand("Objective info", nil, notifyObjective)

    for i = 1,#airbaseZones,1 do
        genSam(mist.utils.zoneToVec3(airbaseZones[i]), true)
    end
    
    genPrimObjective()
    
    for i = 1,secObjectiveCount,1 do
        genSecObjective(i, false)
    end
    
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
    timer.scheduleFunction(checkSecCompleted, {}, timer.getTime() + 1)

    notify("Completed init", 1)

    IADS:activate()
    A2A_DISPATCHER()
end


