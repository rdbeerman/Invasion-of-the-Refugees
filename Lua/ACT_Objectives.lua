-- General Settings --
enableDebug = false
markerScatter = 1000
compThres = 50

-- Set templates --
primObjectiveList = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #002", "primObjective #005", "primObjective #006", "primObjective #007"}

typeAirbase = {"airbase #002"}
typeStructure = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004"}
typeSpecial = {"primObjective #005", "primObjective #006", "primObjective #007" }

samList = {"SAM #001", "SAM #002", "SAM #003", "SAM #004" }
ewrList = {"EWR #001", "EWR #002", "EWR #003"}
defenseList = {"defense #001", "defense #002", "defense #003", "defense #004", "defense #005"}
defenseListSmall = { "defenseSmall #001", "defenseSmall #002" } --small defense for EWRs (APC, Manpad, AAA, Truck)

blueGround = {"blueGround #001"}

escortList = {"escort #001"}

-- Set objective Names for typeStructure --
primNames = {"Headquarters", "Outpost", "Fuel Depot", "Compound", "Presidio", "Armory"}

-- Set objective Names for typeSpecial, index must match
specialNames = {"SCUD Site", "Artillery Battery"}
-- Set Helo objectives
heloObjectives = {"heloObjective #001", "heloObjective #002", "heloObjective #003"}
heloObjectiveNames = {"Search and Rescue", "Construct SAM", "Attack camp"} --Add Cargo transport, troop transport, strike

heloStatics = {"CH-47D", "UH-60A", "Mi-8MTV2"}

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
    -- FARP as objective
    -- Combined Arms

-- Do not change --

secObjective = {} -- index is secObjectiveId, value name (use for mission flow)
primCompletedFlag = 99
primMarker = 98
secCompletion = {}
objectiveCounter = 0
samId = 0
IADS = SkynetIADS:create('IADS-Network')
ewrGroups = {}
statics = {}
vec3Sam = {}
isAirfield = false
heloCounter = 0

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

    for i = 1,#typeAirbase,1 do                 -- check if generated objective is a airbase
        if primObjective == typeAirbase[i] then
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

            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 1)
            end
            return
        end
    end
    
    
    for i = 1,#typeStructure,1 do               -- check if generated objective is a group of buildings
        if primObjective == typeStructure[i] then
            primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false) -- spawn Objective
            objectiveCounter = objectiveCounter + 1
            
            local group = Group.getByName(primObjective)
            local countryId = group:getUnit(1):getCountry()
            local countryName = country.name[countryId]

            vec3Prim = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter)) -- get primObjective location

            mist.flagFunc.group_alive_less_than {
                groupName = countryName.." gnd "..tostring(objectiveCounter),
                flag = primCompletedFlag,
                percent = compThres,
            }

            genStatics(vec3Prim, 2)             -- generates and spawns random statics
            primNaming()                        -- names objective based on spawned statics
            local markerName = "Objective: "..tostring(primName)
            markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)
            
            genSam(vec3Prim, false)             -- generate SAM site without marker near primObjective
            genEwr ( vec3Prim , math.random(2) )                 --generates EWR radars, second number is the amount of EWRs
            genDefense(vec3Prim)                -- generate defenses around primObjective

            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 1)
            end
            return
        end
    end

    for i = 1,#typeSpecial,1 do -- check if generated objective is a special objective with custom name
        if primObjective == typeSpecial[i] then
            primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false) -- spawn objective
            objectiveCounter = objectiveCounter + 1
            
            local group = Group.getByName(primObjective)
            local countryId = group:getUnit(1):getCountry()
            local countryName = country.name[countryId]
            
            vec3Prim = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter)) -- get primObjective location

            mist.flagFunc.group_alive_less_than {
                groupName = countryName.." gnd "..tostring(objectiveCounter),
                flag = primCompletedFlag,
                percent = compThres,
            }

            primName = specialNames[i] -- get objective name by using index in specialNames
            local markerName = "Objective: "..specialNames[i]
            markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)

            genSam(vec3Prim, false)
            genEwr ( vec3Prim , math.random(2) )
            genDefense(vec3Prim)
            

            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 1)
            end
            return
        end
    end
    
end

function genDefense(vec3) -- generates a defense group at point vec3 with set offset
    local offset = {
        x = -500, --changed from -2000 after decreasing the diameter of the template
        y = 0,
        z = 0
    }

    mist.teleportToPoint {
        groupName = defenseList[math.random(#defenseList)],
        point = mist.vec.add(vec3, offset),
        action = "clone",
        disperse = false,
    }

    objectiveCounter = objectiveCounter + 1
end

function genDefenseSmall(vec3) -- generates a defense group at point vec3 with set offset
    local offset = {
        x = -30, --changed from -2000 after decreasing the diameter of the template
        y = 0,
        z = 0
    }

    mist.teleportToPoint {
        groupName = defenseListSmall[math.random(#defenseListSmall)],
        point = mist.vec.add(vec3, offset),
        action = "clone",
        disperse = false,
    }

    objectiveCounter = objectiveCounter + 1
end

function genEwr(vec3, quantity ) --generate N EWR sites away from the main objective and adds a bit of protection to them

    for i = 1 , quantity  , 1 do

        local offset = {
            x = 0, 
            y = 0,
            z = 0
        }

        local ewrExternal = ewrList[math.random(#ewrList)]
        mist.teleportToPoint {
            groupName = ewrExternal,
            point = vec3,
            action = "clone",
            disperse = false,
            radius = 35000,
            innerRadius = 20000
        }
        objectiveCounter = objectiveCounter + 1

        local group = Group.getByName(ewrExternal) 
        local countryId = group:getUnit(1):getCountry()
        local countryName = country.name[countryId]

        ewrExternalGroup = Group.getByName(countryName.." gnd "..tostring(objectiveCounter))
        ewrExternalUnit = ewrExternalGroup:getUnit(1):getName()

        IADS:addEarlyWarningRadar(ewrExternalUnit) -- add EWR to IADS
        genDefenseSmall( mist.getLeadPos(ewrExternalGroup) )

    end

end

function genSam(vec3, mark) -- generates SAM site in random location around point vec3, boolean mark sets f10 marker
    sam = samList[math.random(#samList)]
    samId = samId + 1
    mist.teleportToPoint {
        groupName = sam,
        point = vec3,
        action = "clone",
        disperse = false,
        radius = 7000,
        innerRadius = 2000
    }
    
    local group = Group.getByName(sam)
    local countryId = group:getUnit(1):getCountry()
    local countryName = country.name[countryId]
    
    objectiveCounter = objectiveCounter + 1
    IADS:addSAMSite(countryName.." gnd "..tostring(objectiveCounter))
    
    if mark == true then
        markObjective("SAM Site", countryName.." gnd "..tostring(objectiveCounter), 200 + samId)

        mist.flagFunc.group_alive_less_than {
            groupName = countryName.." gnd "..tostring(objectiveCounter),
            flag = 200 + samId,
            percent = compThres,
        }
    end

    vec3Sam[#vec3Sam + 1] = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter))    
end

function genStatics(vec3, amount) -- generates statics around point vec3
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
            heading = 0,
        }
    end
end

function genHeloObjective() -- function for generating random helo mission using F10 Menu
    local vec3FARP = mist.getLeadPos("FARP AA")
    local random = math.random(#heloObjectives)
    local objective = heloObjectives[random]
    local vec2 = mist.getRandPointInCircle(vec3FARP, 45000, 2000)
    local vec3 = mist.utils.makeVec3(vec2)
    heloCounter = heloCounter + 1

    if heloObjectiveNames[random] == "Search and Rescue" then
        local freq = 40 + heloCounter
        trigger.action.radioTransmission("l10n/DEFAULT/beacon.ogg", vec3, radio.modulation.FM, true, freq*1000000, 1000 )
        
        local static = heloStatics[math.random(#heloStatics)] -- Pick static helicopter to spawn
        mist.dynAddStatic {
            type = static, 
            country = "USA", 
            category = "Helicopters", 
            x = vec2.x + 20, 
            y = vec2.y  , 
            heading = 0,
        }

        ctld.spawnGroupAtPoint("blue", 5, vec3, 0)
        notify("SAR Beacon online at "..tostring(freq).." MHz FM.", 5) -- TODO: add to obj message
    elseif heloObjectiveNames[random] == "Construct SAM" then
        local freq = 40 + heloCounter
        trigger.action.radioTransmission("l10n/DEFAULT/beacon.ogg", vec3, radio.modulation.FM, true, freq*1000000, 1000 )
        notify("A SAM site needs to bo built at a friendly FOB with beacon "..tostring(freq).."MHz FM.", 5)

        mist.teleportToPoint {
            groupName = objective,
            point = vec3,
            action = "clone",
            disperse = false,
        }

        objectiveCounter = objectiveCounter + 1
    elseif heloObjectiveNames[random] == "Attack camp" then
        local freq = 40 + heloCounter
        trigger.action.radioTransmission("l10n/DEFAULT/beacon.ogg", vec3, radio.modulation.FM, true, freq*1000000, 1000 )
        notify("A Iranian camp has been located, friendly troops with beacon "..tostring(freq).."MHz FM are attacking it.", 5)

        local offset = {
            x = 500,
            y = 0,
            z = 0
        }

        mist.teleportToPoint {
            groupName = objective,
            point = vec3,
            action = "clone",
            disperse = false,
        }
        objectiveCounter = objectiveCounter + 1
        
        mist.teleportToPoint {
            groupName = blueGround[math.random(#blueGround)],
            point = mist.vec.add(vec3, offset),
            action = "clone",
            disperse = false,
        }
        objectiveCounter = objectiveCounter + 1

    end

    trigger.action.markToAll(299+heloCounter, heloObjectiveNames[random], vec3, true)
    --completion (count extractable groups in zone+heloCounter if = remove marker)
end

function genEscort() -- function for spawning escort group using F10 Menu
    local escortName = escortList[math.random(#escortList)]
    local escort = Group.getByName(escortName)
    trigger.action.activateGroup(escort)
    notify("A B52H is preparing for takeoff from Bandar Abbas Intl to perform a runway attack on Kerman Airport.", 5)
end

function primNaming() -- names primObjective based on spawned statics
    for i = 1,6,1 do
        if statics[i] == "Workshop A" then  -- if the statics include a factory building..
            local names = {"Factory", "Power plant"}
            primName = names[math.random(#names)]   -- name primObjective either "Factory" or "Power plant"
            return
        else 
            primName = primNames[math.random(#primNames)]
        end
    end
end

function markObjective(markerName, groupName, markerFlag) -- marks objective on F10 map, each markerFlag must be unique
    local vec3Random = {
        x = math.random(-markerScatter,markerScatter),
        y = math.random(-markerScatter,markerScatter),
        z = math.random(-markerScatter,markerScatter)
    }
    local vec3 = mist.vec.add(mist.getLeadPos(groupName), vec3Random)
    trigger.action.markToAll(markerFlag, markerName, vec3, true)
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

function checkPrimCompleted() -- TODO: Add support for statics
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

function checkSamCompleted()
    for i = 1,samId,1 do
        if trigger.misc.getUserFlag(200+i) == 1 and secCompletion[i] == false then
            notify("SAM has been destroyed!", 5) --add support for naming, problems here
            trigger.action.removeMark(200+i)
            secCompletion[i] = true
        end
    end
    timer.scheduleFunction(checkSamCompleted, {}, timer.getTime() + 1)
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
    trigger.action.outText(message, displayFor)
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
    _SETTINGS:SetPlayerMenuOff()
    notify("Starting init", 1)
    missionCommands.addCommand("Objective info", nil, notifyObjective)
    missionCommands.addCommand("Start Escort mission", nil, genEscort)
    missionCommands.addCommand("Start Helicopter mission", nil, genHeloObjective)

    for i = 1,#airbaseZones,1 do
        genSam(mist.utils.zoneToVec3(airbaseZones[i]), true)
    end
    
    genPrimObjective()
    
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
    timer.scheduleFunction(checkSecCompleted, {}, timer.getTime() + 1)
    timer.scheduleFunction(checkSamCompleted, {}, timer.getTime() + 1)

    notify("Completed init", 1)

    IADS:activate()
    A2A_DISPATCHER()
end


