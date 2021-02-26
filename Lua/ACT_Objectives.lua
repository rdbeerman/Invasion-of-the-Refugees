-- General Settings --
enableDebug = false
enableIadsDebug = false
debugHeader = "---INVASION mission--- "
markerScatter = 1000
compThres = 50

--[[
    difficultiy settings (default)
]]--

--static defenses
ewrNumberDefault = 3
samNumberDefault = 1
defenseNumberDefault = 4
shoradNumberDefault = 2
pointDefenseExists = false
--cap numbers
capLimitDefault = 1
lowIntervalDefault = 500
highIntervalDefault = 1000
probabilityDefault = 1
--hard mode factor
hardModeFactor = 1.3 --30% more enemies

-- Set templates --
-- Import map specific templates
objectiveLocList = act.getZones()
primObjectiveList = act.getPrimObjectives()
shipsList = act.getShips()
shipsZones = act.getShipsZones()
shipEngFrac = act.getShipEngFrac()

typeStructure = act.getStructures()
typeSpecial = act.getTypeSpecial()
typeSpecialSam = act.getTypeSpecialSam()

samList = act.getSams()
ewrList = act.getEwrs()
shoradList = act.getShorad()
defenseListSmall = act.getSmallDefenses()
pointDefenseList = act.getPointDefenses()
capRed = act.getRedCap ()
--helo stuff
blueGround = act.getBlueGround()
heloObjectives = act.getHeloObjectives()
--airbase stuff
airbaseZones = act.getAirbaseZones()
airbaseEWR = act.getAirbaseEwr()

--custom names & statics
-- Set objective Names for typeStructure --
primNames = {"Headquarters", "Outpost", "Fuel Depot", "Compound", "Presidio", "Armory"}
-- Set Helo objectives
heloObjectiveNames = {"Search and Rescue", "Construct SAM", "Attack camp"} --Add Cargo transport, troop transport, strike
heloStatics = {"CH-47D", "UH-60A", "Mi-8MTV2"}
-- Set Statics
staticList = {"Workshop A", "Farm A", "Farm B", "Comms tower M", "Chemical tank A", "Pump station", "Oil derrick"}

-- TODO --
    -- Function to decrease A2A Dispatcher after EWR/factory destroyed
    -- FARP as objective
    -- Combined Arms

-- Do not change --

primCompletedFlag = 99
primMarker = 98
secCompletion = {}
primObjectiveCounter = 0
primObjectiveType = 0 --used for setting it manually
objectiveCounter = 0
samId = 0
IADS = SkynetIADS:create('IADS-Network')
ewrGroups = {}
statics = {}
vec3Sam = {}
vec3SamType = {}
isAirfield = false
heloCounter = 0
waypointArray = {}
settingsArray = {"", "", "", ""}
difficultyFactor = 1
missionData = {}

function toggleIadsDebug ( trueOrFalse )
    local iadsDebug = IADS:getDebugSettings()
    iadsDebug.IADSStatus = trueOrFalse
    iadsDebug.samWentDark = trueOrFalse
    iadsDebug.contacts = trueOrFalse
    iadsDebug.radarWentLive = trueOrFalse
    iadsDebug.ewRadarNoConnection = false
    iadsDebug.samNoConnection = false
    iadsDebug.jammerProbability = false
    iadsDebug.addedEWRadar = false
    iadsDebug.hasNoPower = false
    iadsDebug.addedSAMSite = false
    iadsDebug.warnings = trueOrFalse
    iadsDebug.harmDefence = trueOrFalse
    iadsDebug.samSiteStatusEnvOutput = false
    iadsDebug.earlyWarningRadarStatusEnvOutput = false
end

for i = 1,#airbaseEWR,1 do
    IADS:addEarlyWarningRadar(airbaseEWR[i])
end

function genPrimObjective()
    primCompletion = false
    primObjectiveCounter = primObjectiveCounter + 1 --to check if a primary has been manually spawned, not pretty but should work
    objectiveLoc = objectiveLocList[math.random(#objectiveLocList)]

    if primObjectiveType == 0 then --if no prim objective has been specified, randomize it
        primObjectiveType = math.random(1, 3)
    end

    if primObjectiveType == 1 then --structure
        primObjective = typeStructure[math.random(#typeStructure)]
        genStructureTarget ()

        env.error(debugHeader.."Completed Objective stucture spawning.", false)
        if enableDebug == true then
            notify("structure target spawning", 5)
        end
    end

    if primObjectiveType == 2 then --vehicle
        primObjective = typeSpecial[math.random(#typeSpecial)]
        genVehicleTarget ()

        env.error(debugHeader.."Completed Objective vehicles spawning.", false)
        if enableDebug == true then
            notify("vehicle target spawning", 5)
        end
    end

    if primObjectiveType == 3 then --SAM (SA-10)
        primObjective = typeSpecialSam[math.random(#typeSpecialSam)]
        genSamTarget ()

        env.error(debugHeader.."Completed Objective SAM spawning.", false)
        if enableDebug == true then
            notify("SAM target spawning", 5)
        end
    end

    if primObjectiveType == 4 then --Ship
        primObjective = shipsList[math.random(1, #shipsList)]
        genShip(primObjective)

        env.error(debugHeader.."Completed Objective ship spawning.", false)
        if enableDebug == true then
            notify("Ship target spawning", 5)
        end
    end
end

function genStructureTarget ()
    for i = 1,#typeStructure,1 do               -- check if generated objective is a group of buildings
        if primObjective == typeStructure[i] then
            primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false) -- spawn Objective
            objectiveCounter = objectiveCounter + 1
            
            local group = Group.getByName(primObjective)
            local countryId = group:getUnit(1):getCountry()
            local countryName = country.name[countryId]

            vec3Prim = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter)) -- get primObjective location
            missionData.vec3Prim = vec3Prim
            missionData.type = "structure"
            missionData.group = group

            mist.flagFunc.group_alive_less_than {
                groupName = countryName.." gnd "..tostring(objectiveCounter),
                flag = primCompletedFlag,
                percent = compThres,
            }

            genStatics(vec3Prim, 2)             -- generates and spawns random statics
            primNaming()                        -- names objective based on spawned statics
            local markerName = "Objective: "..tostring(primName)
            markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)

            if pointDefenseExists == true then
                genPointDefense (vec3Prim, countryName.." gnd "..tostring(objectiveCounter), 1)
            end

            genSurroundings( vec3Prim , samNumber, ewrNumber, shoradNumber , defenseNumber ) --moved defenses to an extra function (postion, sam, ewr, short range defenses)

            env.error(debugHeader..primObjective.."@"..objectiveLoc, false)
            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 60)
            end
            return
        end
    end

end

function genVehicleTarget ()
    for i = 1,#typeSpecial,1 do -- check if generated objective is a special objective with custom name
        if primObjective == typeSpecial[i] then
            primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false) -- spawn objective
            objectiveCounter = objectiveCounter + 1
            
            local group = Group.getByName(primObjective)
            local countryId = group:getUnit(1):getCountry()
            local countryName = country.name[countryId]
            
            vec3Prim = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter)) -- get primObjective location
            missionData.vec3Prim = vec3Prim
            missionData.type = "vehicle"
            missionData.group = group

            mist.flagFunc.group_alive_less_than {
                groupName = countryName.." gnd "..tostring(objectiveCounter),
                flag = primCompletedFlag,
                percent = compThres,
            }

            local specialNames = act.getSpecialNames()

            primName = specialNames[i] -- get objective name by using index in specialNames
            local markerName = "Objective: "..specialNames[i]
            markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)

            if pointDefenseExists == true then
                genPointDefense (vec3Prim, countryName.." gnd "..tostring(objectiveCounter), 1)
            end

            genSurroundings( vec3Prim , samNumber, ewrNumber, shoradNumber ,  defenseNumber ) --position, sam, ewr, defenses

            env.error(debugHeader..primObjective.."@"..objectiveLoc, false)
            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 60)
            end
            return
        end
    end
end

function genSamTarget ()
    for i = 1,#typeSpecialSam,1 do -- check if generated objective is a special objective with custom name
        if primObjective == typeSpecialSam[i] then
            primObjectiveID = mist.cloneInZone(primObjective, objectiveLoc, false) -- spawn objective
            objectiveCounter = objectiveCounter + 1
            
            local group = Group.getByName(primObjective)
            local countryId = group:getUnit(1):getCountry()
            local countryName = country.name[countryId]
            
            vec3Prim = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter)) -- get primObjective location
            missionData.vec3Prim = vec3Prim
            missionData.type = "sam"
            missionData.group = group

            mist.flagFunc.group_alive_less_than {
                groupName = countryName.." gnd "..tostring(objectiveCounter),
                flag = primCompletedFlag,
                percent = compThres,
            }

            local specialSamNames = act.getSpecialSamNames()

            primName = specialSamNames[i] -- get objective name by using index in specialNames
            local markerName = "Objective: "..specialSamNames[i]
            markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)

            IADS:addSAMSite(countryName.." gnd "..tostring(objectiveCounter)) --add SA-10 to IADS
            improveSamAuto (countryName.." gnd "..tostring(objectiveCounter))
            
            if pointDefenseExists == true then
                genPointDefense (vec3Prim, countryName.." gnd "..tostring(objectiveCounter), 1)
            end

            genSurroundings( vec3Prim , samNumber, ewrNumber, shoradNumber ,  defenseNumber ) --position, sam, ewr, defenses

            env.error(debugHeader..primObjective.."@"..objectiveLoc, false)
            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 60)
            end
            return
        end
    end
end

function genShip(shipType)
    mist.cloneInZone(shipType, shipsZones)    
    --Give patrol tasks
    local group = Group.getByName(shipType)
    local countryId = group:getUnit(1):getCountry()
    local countryName = country.name[countryId]
    local controller = group:getController()
    
    controller:setOption(24, shipEngFrac)

    
    --local path = {} 
    --path[#path + 1] = mist.ground.buildWP(shipsZones[math.random(1, #shipsZone)], 'Diamond', 10) 
    --path[#path + 1] = mist.ground.buildWP(shipsZones[math.random(1, #shipsZone)], 'Diamond', 10) 
    --path[#path + 1] = mist.ground.buildWP(shipsZones[math.random(1, #shipsZone)], 'Diamond', 10) 
    --mist.goRoute(group, path)
    
    --add steerpoints
    mist.ground.patrol(group)
    missionData.vec3Prim = nil
    missionData.type = "ship"
    missionData.group = group

    local _carrierList = act.getShipCarrier()
    
    for i = 1, #_carrierList do
        if shipType == _carrierList[i] then
            local _carrierDefenseList = act.getCarrierDefense()
            local _carrierDefense = Group.getByName(_carrierDefenseList[math.random(1, #_carrierDefenseList)])
            _carrierDefense:activate()
        end
    end

    markObjective("Objective: enemy ship", countryName.." shp "..tostring(primObjectiveCounter), primMarker)
    mist.flagFunc.group_alive_less_than {
        groupName = countryName.." shp "..tostring(primObjectiveCounter),
        flag = primCompletedFlag,
        percent = compThres,
    }
end

function genSurroundings ( vec3, samAmount, ewrAmount, shoradAmount, defenseAmount ) --generates SAMs, EWRs and defenses
    for i = 1 , samAmount, 1 do
        genSam ( vec3 , true ) --generates a SAM site with a chance to detect SEAD missiles
    end

    if ewrAmount ~= 0 then
        genEwr ( vec3 , ewrAmount )
    end

    if defenseAmount ~= 0 then
        genDefense( vec3, defenseAmount ) --generates the short range defenses of an objective
    end

    if shoradAmount ~= 0 then
        genShorad ( vec3 , shoradAmount )
    end
end

function genDefense(vec3, amount)
    local theta = 360 / amount
    for i = 1 , amount , 1 do
        local offset = math.random (400, 500)
        local defensePosition = mist.vec.add(vec3, rotateVector( theta*i+math.random(0,20), offset ))
        genDefenseSmall(defensePosition)
    end
end

function genDefenseSmall(vec3) -- generates a defense group at point vec3 with set offset
    local offset = {
        x = -30,
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
    env.error(debugHeader.."Spawned small defense.", false)
end

function genEwr( vec3 , amount ) --generate N EWR sites away from the main objective and adds a bit of protection to them
    for i = 1 , amount , 1 do

        if i == 1 then --first EWR is very close to the objective
            ewrRadius = 1500
            ewrInnerRadius = 1000
        else
            ewrRadius = 35000
            ewrInnerRadius = 20000
        end

        local ewrExternal = ewrList[math.random(#ewrList)]
        mist.teleportToPoint {
            groupName = ewrExternal,
            point = vec3,
            action = "clone",
            disperse = false,
            radius = ewrRadius,
            innerRadius = ewrInnerRadius
        }
        objectiveCounter = objectiveCounter + 1
    
        local group = Group.getByName(ewrExternal) 
        local countryId = group:getUnit(1):getCountry()
        local countryName = country.name[countryId]
    
        ewrExternalGroup = Group.getByName(countryName.." gnd "..tostring(objectiveCounter))
        ewrExternalUnit = ewrExternalGroup:getUnit(1):getName()
    
        IADS:addEarlyWarningRadar(ewrExternalUnit) -- add EWR to IADS
        genDefenseSmall( mist.getLeadPos(ewrExternalGroup) )
    
        env.error(debugHeader.."Spawned EWR type: "..ewrExternal, false)
    end
end

function genSam(vec3, mark ) -- generates SAM site in random location around point vec3, boolean mark sets f10 marker
    sam = samList[math.random(#samList)]
    samId = samId + 1
    mist.teleportToPoint {
        groupName = sam,
        point = vec3,
        action = "clone",
        disperse = false,
        radius = 10000,
        innerRadius = 8000
    }
    
    local group = Group.getByName(sam)
    local countryId = group:getUnit(1):getCountry()
    local countryName = country.name[countryId]    
    objectiveCounter = objectiveCounter + 1
    local samGroupName = countryName.." gnd "..tostring(objectiveCounter)

    IADS:addSAMSite( samGroupName ) --group name
    improveSamAuto ( samGroupName )

    if mark == true then
        markObjective("SAM Site: " .. getSamType ( samGroupName ), samGroupName, 200 + samId)
        mist.flagFunc.group_alive_less_than {
            groupName = samGroupName,
            flag = 200 + samId,
            percent = compThres,
        }
    end
    vec3SamType[#vec3SamType + 1] = getSamType(countryName.." gnd "..tostring(objectiveCounter))
    vec3Sam[#vec3Sam + 1] = mist.getLeadPos(samGroupName)
    env.error(debugHeader.."Spawned SAM type: "..sam, false)
end

function genAirbaseSam( zone, mark )
    sam = samList[math.random(#samList)]
    samId = samId + 1
    local getZone = trigger.misc.getZone(zone)
    local vec3 = mist.getRandomPointInZone(zone)
    local size = getZone[2]
    
    mist.teleportToPoint {
        groupName = sam,
        point = vec3,
        action = "clone",
        disperse = false,
        radius = size,
        innerRadius = 2000
    }
    
    local group = Group.getByName(sam)
    local countryId = group:getUnit(1):getCountry()
    local countryName = country.name[countryId]
    
    objectiveCounter = objectiveCounter + 1
    IADS:addSAMSite(countryName.." gnd "..tostring(objectiveCounter)) --group name
    improveSamAuto ( countryName.." gnd "..tostring(objectiveCounter) )
    
    if mark == true then
        markObjective("SAM Site: " .. getSamType(countryName.." gnd "..tostring(objectiveCounter)), countryName.." gnd "..tostring(objectiveCounter), 200 + samId)

        mist.flagFunc.group_alive_less_than {
            groupName = countryName.." gnd "..tostring(objectiveCounter),
            flag = 200 + samId,
            percent = compThres,
        }
    end

    vec3SamType[#vec3SamType + 1] = getSamType(countryName.." gnd "..tostring(objectiveCounter))
    vec3Sam[#vec3Sam + 1] = mist.getLeadPos(countryName.." gnd "..tostring(objectiveCounter))
    
    env.error(debugHeader.."Spawned airbase SAM type: "..sam, false)
end

function genShorad ( vec3 , amount ) 
    local theta = 360 / amount
    for i = 1 , amount , 1 do
        local offset = math.random (5000, 10000)
        local shoradPosition = mist.vec.add(vec3, rotateVector( theta*i, offset ))
        local shoradExternal = shoradList[math.random(#shoradList)]
        mist.teleportToPoint {
            groupName = shoradExternal,
            point = shoradPosition,
            action = "clone",
            disperse = false,
            radius = 2500,
            innerRadius = 250
        }

        objectiveCounter = objectiveCounter + 1
        local group = Group.getByName(shoradExternal) 
        local countryId = group:getUnit(1):getCountry()
        local countryName = country.name[countryId]
        local shoradName = countryName.." gnd "..tostring(objectiveCounter)
        local shoradExternalGroup = Group.getByName(shoradName)

        IADS:addSAMSite(shoradName)
        genDefenseSmall( mist.getLeadPos(shoradExternalGroup) )

        env.error(debugHeader.."Spawned SHORAD type: "..shoradExternal, false)
    end
end

function genPointDefense (vec3 , defendedTarget , amount ) --seems to work, needs ingame testing
    local theta = 360 / amount
    local offset = 600

    for i = 1 , amount , 1 do
        local pointDefensePosition = mist.vec.add(vec3, rotateVector( theta*i, offset ))
        local pointDefense = pointDefenseList[math.random(#pointDefenseList)]
        mist.teleportToPoint {
            groupName = pointDefense,
            point = pointDefensePosition,
            action = "clone",
            disperse = false,
            radius = 100,
            innerRadius = 50
        }

        objectiveCounter = objectiveCounter + 1

        local group = Group.getByName(pointDefense) 
        local countryId = group:getUnit(1):getCountry()
        local countryName = country.name[countryId]
        local pointDefenseName = countryName.." gnd "..tostring(objectiveCounter)
        local pointDefenseExternalGroup = Group.getByName(pointDefenseName)

            if primObjectiveType == 3 then --changes the integration of the SA-15 depending on the type of primary objective
                IADS:getSAMSiteByGroupName(defendedTarget):addPointDefence(pointDefenseName) --adds a point defense to the defended target
                IADS:getSAMSiteByGroupName(defendedTarget):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
            else
                IADS:addSAMSite(pointDefenseName)
                improveSamAuto(pointDefenseName)
            end
        
        genDefenseSmall( mist.getLeadPos(pointDefenseExternalGroup) )
    end
end

function rotateVector ( degree, radius ) --input degree and radius, rotates the vector and returns a vec3 offset
    local offset = {
        x = radius,
        y = 0
    }
    local returnOffset = mist.utils.makeVec3( mist.vec.rotateVec2 ( offset, math.rad(degree) ) )
    return returnOffset
end

function getSamType (groupName)
    local samType = ""
    local group = Group.getByName(groupName)
    local unitType = group:getUnit(1):getTypeName() --outputs unit type name

    if enableDebug == true then
        trigger.action.outText(unitType, 60)
    end

    if string.find(unitType, "Kub") then --SA-6
        samType = "SA-6"
    elseif string.find(unitType, "rapier") then --Rapier
        samType = "Rapier"
    elseif string.find(unitType, "Hawk") then --Hawk
        samType = "Hawk"
    elseif string.find(unitType, "Buk") then --SA-11
        samType = "SA-11"
    elseif string.find(unitType, "SNR") then --SA-2
        samType = "SA-2"
    elseif string.find(unitType, "S-300PS") then --SA-10
        samType = "SA-10"
    elseif string.find(unitType, "Tor") then --SA-15
        samType = "SA-15"
    else --not found
        samType = "unknown"
    end

    return samType
end

function improveSamAuto (groupName) --inputs group name and tunes it automatically according to its type
    local samType = getSamType(groupName)
    if samType == "Rapier" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 20 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(100)
    elseif samType == "Hawk" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 40 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(85)
    elseif samType == "SA-2" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 20 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(85)
    elseif samType == "SA-6" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 40 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(90)
    elseif samType == "SA-11" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 60 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(90)
    elseif samType == "SA-10" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 100 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(95)
    elseif samType == "SA-15" then
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 100 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent(90)
    else
        IADS:getSAMSiteByGroupName(groupName):setHARMDetectionChance( 50 )
        IADS:getSAMSiteByGroupName(groupName):setGoLiveRangeInPercent( 100 )
    end
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

        env.error(debugHeader.."Spawned static type: "..building, false)
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

        env.error(debugHeader.."Spawned helo: SAR mission", false)
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
        env.error(debugHeader.."Spawned helo: SAM mission", false)
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

        env.error(debugHeader.."Spawned helo: Attack camp", false)
    end

    trigger.action.markToAll(299+heloCounter, heloObjectiveNames[random], vec3, true)
    --completion (count extractable groups in zone+heloCounter if = remove marker)
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
        notify("All strike flights, main objective has been destroyed.", 5)
        STTS.TextToSpeech("All strike flights, main objective has been destroyed.", 300, "AM", "1.0", "SERVER", 2)
        STTS.TextToSpeech("All strike flights, main objective has been destroyed.", 240, "AM", "1.0", "SERVER", 2)
        trigger.action.removeMark(primMarker)
        primCompletion = true
    end
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
end

function checkSamCompleted()
    for i = 1,samId,1 do
        if trigger.misc.getUserFlag(200+i) == 1 and secCompletion[i] == false then
            notify("SAM has been destroyed!", 5) --add support for naming, problems here
            STTS.TextToSpeech("Good effect on SAM site.", 300, "AM", "1.0", "SERVER", 2)

            trigger.action.removeMark(200+i)
            secCompletion[i] = true
        end
    end
    timer.scheduleFunction(checkSamCompleted, {}, timer.getTime() + 1)
end

function notifyObjective()
    if primCompletion == false then
        local message = "The primary objective is a "..primName.." that has been located in the area near: \n"
        message = message..notifyCoords(vec3Prim, 1).." N, "..notifyCoords(vec3Prim, 2).." E, "..notifyCoords(vec3Prim, 3).." ft.\n"
        message = message.."\n Beware, SAM sites have been spotted near: \n"

        for i = 1,#vec3Sam,1 do
            message = message.."- " .. vec3SamType[i] .. ": "..notifyCoords(vec3Sam[i], 1).." N, "..notifyCoords(vec3Sam[i], 2).."E, "..notifyCoords(vec3Sam[i],3).." ft.\n" 
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

function vec3toDMS(vec3)
    local _lat, _lon, _alt = coord.LOtoLL(vec3)
    return mist.tostringLL (_lat, _lon, 1, true)
end

--[[

    functions related to the F10 comms menu

]]

function autoStart()
    if primObjectiveCounter == 0 then
        manualStart()
    end
end

function manualStart() -- problem is here

    ewrNumber = math.ceil ( ewrNumberDefault * difficultyFactor )
    samNumber = 0
    shoradNumber = math.ceil ( shoradNumberDefault * difficultyFactor )
    defenseNumber = math.ceil ( defenseNumberDefault * difficultyFactor )

    lowInterval = math.ceil ( lowIntervalDefault / difficultyFactor )
    highInterval = math.ceil ( highIntervalDefault / difficultyFactor )

    if enableSams == 1 then --only set samNumber if not disabled
        samNumber = math.ceil ( samNumberDefault * difficultyFactor )
    end

    if difficultyFactor == hardModeFactor then --hard mode
        addAwacsToIads()
        addPointDefense()
    end

    for i = 1,#airbaseZones,1 do
        genAirbaseSam(airbaseZones[i], true )
    end
    
    genPrimObjective()
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
    timer.scheduleFunction(checkSamCompleted, {}, timer.getTime() + 1)
    IADS:getSAMSites():setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)
    IADS:activate()
    A2A_DISPATCHER()
    readSettings()

    missionCommands.removeItem(radioSubMenuStartCommands)
    notify("Mission started.", 15)
    STTS.TextToSpeech("Mission started.", 243, "AM", "1.0", "SERVER", 2)

end

function readSettings ()
    for i = 1, #settingsArray, 1 do
        notify ( settingsArray[i], 15)
    end
end

--debug radio settings

function radioEnableIadsDebug ()
    enableIadsDebug = true
    toggleIadsDebug( enableIadsDebug )
    radioMenuDisableIadsDebug = missionCommands.addCommand ("Disable IADS debug", radioSubMenuDebugCommands, radioDisableIadsDebug)
    missionCommands.removeItem (radioMenuEnableIadsDebug)
    notify ("IADS debug enabled", 15)
end

function radioDisableIadsDebug()
    enableIadsDebug = false
    toggleIadsDebug( false )
    radioMenuEnableIadsDebug = missionCommands.addCommand ("Enable IADS debug", radioSubMenuDebugCommands, radioEnableIadsDebug)
    missionCommands.removeItem (radioMenuDisableIadsDebug)
    notify ("IADS debug disabled", 15)
end

function radioEnableAirDispatcherDebug()
    enableDebug = true
    A2ADispatcherRED:SetTacticalDisplay( enableDebug )

    radioMenuDisableDispatcherDebug = missionCommands.addCommand ("Disable AA-Dispatcher debug", radioSubMenuDebugCommands, radioDisableAirDispatcherDebug)
    missionCommands.removeItem (radioMenuEnableDispatcherDebug)
    notify ("Air dispatcher debug enabled", 15)
end

function radioDisableAirDispatcherDebug()
    enableDebug = false
    A2ADispatcherRED:SetTacticalDisplay( enableDebug )

    radioMenuEnableDispatcherDebug = missionCommands.addCommand ("Enable AA-Dispatcher debug", radioSubMenuDebugCommands, radioEnableAirDispatcherDebug)
    missionCommands.removeItem (radioMenuDisableDispatcherDebug)
    notify ("Air dispatcher debug disabled", 15)
end

--other comms settings

function setDifficulty(mode)
    local difficultyNames = {"Normal", "Hard"}
    local difficultyFactors = {1 ,hardModeFactor}
    difficultyFactor = difficultyFactors[mode]

    if mode == 2 then --hard mode
        settingsArray[2] = "difficulty: " .. difficultyNames[mode]
    else --normal mode
        settingsArray[2] = "difficulty: " .. difficultyNames[mode]
    end

    notify(difficultyNames[mode] .. " mode selected", 5)

    env.error(debugHeader.."selected SAM difficulty: "..difficultyNames[mode], false)
end

function disableEnemyCap ()
    notify("CAP disabled", 5)
    capLimit = 0
    settingsArray[3] = "CAP disabled"
    radioMenuEnableCap = missionCommands.addCommand ( "enable enemy CAP", radioSubMenuStartCommands, enableEnemyCap)
    missionCommands.removeItem (radioMenuDisableCap)

    env.error(debugHeader.."Disabled CAP", false)
end

function enableEnemyCap ()
    notify("CAP enabled", 5)
    capLimit = capLimitDefault
    settingsArray[3] = "CAP enabled"
    radioMenuDisableCap = missionCommands.addCommand ( "Disable enemy CAP", radioSubMenuStartCommands, disableEnemyCap)
    missionCommands.removeItem (radioMenuEnableCap)

    env.error(debugHeader.."Enabled CAP", false)
end

function disableEnemySam ()
    notify("SAM disabled", 5)
    settingsArray[4] = "SAM disabled"
    enableSams = 0

    radioMenuEnableSam = missionCommands.addCommand ( "Enable enemy SAM", radioSubMenuStartCommands, enableEnemySam)
    missionCommands.removeItem (radioMenuDisableSam)
    
    env.error(debugHeader.."SAM disabled", false)
end


function enableEnemySam ()
    notify ("SAM enabled", 5)
    settingsArray[4] = "SAM enabled"
    enableSams = 1

    radioMenuDisableSam = missionCommands.addCommand ( "Disable enemy SAM", radioSubMenuStartCommands, disableEnemySam)
    missionCommands.removeItem (radioMenuEnableSam)

    env.error(debugHeader.."SAM enabled", false)
end


function setTargetRandom ()
    local random = math.random(1, 3)
    notify ("selected random target", 5)
    if random == 1 then
        setTargetBuilding()
    end
    if random == 2 then
        setTargetSpecial()
    end
    if random == 3 then
        setTargetSpecialSam()
    end
end

function setTargetBuilding ()
    notify("selected building target", 5)
    primObjectiveType = 1
    settingsArray[1] = "Building target"
end

function setTargetSpecial ()
    notify("selected vehicles target", 5)
    primObjectiveType = 2
    settingsArray[1] = "Vehicle target"
end

function setTargetSpecialSam ()
    notify("selected SAM target", 5)
    primObjectiveType = 3
    settingsArray[1] = "SAM target"
end

function setTargetShip ()
    notify("selected building ship", 5)
    primObjectiveType = 4
    settingsArray[1] = "Ship target"
end

function addPointDefense ()
    notify("added point defense to primary target", 5)
    pointDefenseExists = true
end

function addAwacsToIads ()
    IADS:addEarlyWarningRadar("AWACS Red #001")
    notify ("AWACS added to IADS", 5)
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

    A2ADispatcherRED:SetSquadron( "CAP_RED_1", act.capAirbases[1], capRed )
    A2ADispatcherRED:SetSquadron( "CAP_RED_2", act.capAirbases[2], capRed )

    --Define Squadron properties
    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_1", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_1", 2 )

    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_2", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_2", 2 )

    --Define CAP Squadron execution
    A2ADispatcherRED:SetSquadronCap( "CAP_RED_1", BorderRED,  6000, 8000, 600, 900, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_1", capLimit, lowInterval, highInterval, probability) --old settings were 450, 550

    A2ADispatcherRED:SetSquadronCap( "CAP_RED_2", BorderRED,  3000, 9000, 400, 800, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_2", capLimit, lowInterval, highInterval, probability) --old settings were 450, 550

    --Debug
    A2ADispatcherRED:SetTacticalDisplay( enableDebug )

    --Define Defaults
    --A2ADispatcherRED:SetDefaultTakeOffFromRunway()
    A2ADispatcherRED:SetDefaultLandingAtRunway()
end

function notifyCustomWaypoints()
    notify (#waypointArray, 5)
    for i = 1, #waypointArray do
        notify ("Waypoint " .. i .. ": " .. waypointArray[i]["position"], 15)
    end
end

-- MAIN SETUP --
do

    local eventHandler = world.onEvent
    world.onEvent = function(event)
        if event.id == 26 then --player edited a marker
            if string.find (event.text, "waypoint") then
                local _wyptNum = tonumber(string.match(event.text, '%d')) 
                local _pos = vec3toDMS(event.pos)

                waypointArray[_wyptNum] = {
                    ["text"] = event.text,
                    ["wyptNumber"] = _wyptNum,
                    ["vec3"] = event.pos,
                    ["position"] = _pos,
                    ["idx"] = event.idx
                }
            end
        end
        if event.id == 27 then --marker removed
            for i = 1, #waypointArray do
                if waypointArray[i]["idx"] == event.idx then
                    waypointArray[i] = {}
                end
            end
        end
        return eventHandler(event)
    end

    _SETTINGS:SetPlayerMenuOff()
    notify("Starting init", 5)

    --[[

        adds the F-10 radio commands for the mission
    ]]


    --submenus
    invasionCommandsRoot = missionCommands.addSubMenu ("Invasion Commands") --invasion commands submenu
    radioSubMenuStartCommands = missionCommands.addSubMenu ("Start Commands", invasionCommandsRoot) --nested submenu for start commands
    radioSubMenuDebugCommands = missionCommands.addSubMenu ("Debug Commands", invasionCommandsRoot)

    --invasion command submenu
    radioMenuReadSettings = missionCommands.addCommand ("Display selected settings", invasionCommandsRoot, readSettings)
    radioMenuObjectiveInfo = missionCommands.addCommand("Objective info", invasionCommandsRoot, notifyObjective)
    --radioMenuWaypointInfo = missionCommands.addCommand("Waypoint info", invasionCommandsRoot, notifyCustomWaypoints)
    radioMenuStartHelicopterMission = missionCommands.addCommand("Start Helicopter mission", invasionCommandsRoot, genHeloObjective)

    --deubg command submenu
    radioMenuEnableIadsDebug = missionCommands.addCommand ("Enable IADS Debug", radioSubMenuDebugCommands, radioEnableIadsDebug)
    radioMenuEnableDispatcherDebug = missionCommands.addCommand ("Enable AA-Dispatcher Debug", radioSubMenuDebugCommands, radioEnableAirDispatcherDebug)

    --start commands submenu
    radioMenuManualStart = missionCommands.addCommand("Apply settings and start", radioSubMenuStartCommands , manualStart)
    --target type settings
    radioMenuTargetRandom = missionCommands.addCommand ("Set target type: Random", radioSubMenuStartCommands, setTargetRandom)
    radioMenuTargetBuilding = missionCommands.addCommand ("Set target type: Building", radioSubMenuStartCommands, setTargetBuilding)
    radioMenuTargetSpecial = missionCommands.addCommand ("Set target type: Vehicle group", radioSubMenuStartCommands, setTargetSpecial)
    radioMenuTargetSpecialSam = missionCommands.addCommand ("Set target type: SAM", radioSubMenuStartCommands, setTargetSpecialSam)
    radioMenuTargetSpecialSam = missionCommands.addCommand ("Set target type: Ship", radioSubMenuStartCommands, setTargetShip)
    --difficulty settings
    radioMenuNormalMode = missionCommands.addCommand ("Set difficulty: Normal", radioSubMenuStartCommands, setDifficulty, 1)
    radioMenuHardMode = missionCommands.addCommand ("Set difficulty: Hard", radioSubMenuStartCommands, setDifficulty, 2)
    radioMenuEnableCap = missionCommands.addCommand ( "Enable enemy CAP", radioSubMenuStartCommands, enableEnemyCap)
    radioMenuEnableSam = missionCommands.addCommand ( "Enable enemy SAM", radioSubMenuStartCommands, enableEnemySam)

    --default settings
    probability = probabilityDefault
    enableEnemyCap()
    enableEnemySam()
    setDifficulty(1)
    setTargetRandom()

    timer.scheduleFunction(autoStart, {}, timer.getTime() + 600) --autostart of the mission after 10 minutes, if no manual start was selected

    notify("init completed", 5)

end
