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
lowIntervalDefault = 900
highIntervalDefault = 1000
probabilityDefault = 1
capSpawnLimit = nil
--hard mode factor
hardModeFactor = 1.2 --20% more enemies

-- Set templates --
-- Import map specific templates
objectiveLocList = act.getZones()
primObjectiveList = act.getPrimObjectives()
precisionObjectives = act.getPrecisionObjectives()
precisionSAMzones = act.getPrecisionSAMzones()
precisionGroups = act.getPrecisionGroups()
precisionNames = act.getPrecisionNames()

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
--convoy stuff
convoyRedList = act.getConvoyRed()
checkpointsBlue = act.getCheckpointsBlue()
convoyRedAttackZone = act.getconvoyRedEndZone()

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
restartFlag = 97
primMarker = 98
carrierMarkerId = 1100
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
settingsArray = {"", "", "", ""}
difficultyFactor = 1
missionData = {}

--Colors: (RGB/A)
objColor = {1, 0, 0, 0.9}
objColorfill = {1, 0, 0, 0.3}

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
        primObjectiveType = math.random(1, 5)
    end

    if primObjectiveType == 1 then --structure
        primObjective = typeStructure[math.random(#typeStructure)]
        genStructureTarget ()

        env.error(debugHeader.."Completed Objective stucture spawning.", false)
        if enableDebug == true then
            notify("structure target spawning", 5)
        end
    end

    if primObjectiveType == 2 then --vehicle / search and destroy
        primObjective = typeSpecial[math.random(#typeSpecial)]
        genSearchAndDestroyTarget ()

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

    if primObjectiveType == 4 then --convoy

        local _convoyName = convoySetup(2) --needs testing if more than 1
        env.error(debugHeader.."Spawned convoy: ".._convoyName, false)
        vec3Prim = Group.getByName(_convoyName):getUnit(1):getPoint()

        mist.flagFunc.group_alive_less_than {
            groupName = _convoyName,
            flag = primCompletedFlag,
            percent = compThres,
        }
        
        --TODO: rework notification for this objectiveType
        notify("convoy target spawning", 5)
    end

    if primObjectiveType == 5 then --Precision Strike
        local i = math.random(1, #precisionObjectives)
        primObjective = precisionObjectives[i]
        vec3Prim = mist.utils.makeVec3GL(mist.utils.zoneToVec3(primObjective))
        
        env.error(debugHeader.."Spawning Objective Precision no: "..i , false)
        mist.flagFunc.mapobjs_dead_zones{  
            zones = {primObjective},  
            flag = primCompletedFlag, 
            req_num = 1 
          }  

        local _group = Group.getByName(precisionGroups[i])
        _group:activate()
        env.error(debugHeader.."Group activated" , false)

        local _zoneName = precisionSAMzones[i]
        local _vec3SAM = mist.utils.zoneToVec3(_zoneName)
        genSam(_vec3SAM, true, trigger.misc.getZone(_zoneName).radius, 0)
        
        primName = precisionNames[i]
        local _markerName = "Objective: "..primName
        markObjectiveZone(_markerName , primObjective, primMarker, 0)

        notify("Precision strike spawning", 5)
    end

    if primObjectiveType == 6 then --Ship
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

function genSearchAndDestroyTarget () --search and destroy
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
            
            --markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)

            markSearchArea (countryName.." gnd "..tostring(objectiveCounter))

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
    --path[#path + 1] = mist.ground.buildWP(shipsZones[math.random(1, #shipsZone)], nil, 10) 
    --path[#path + 1] = mist.ground.buildWP(shipsZones[math.random(1, #shipsZone)], nil, 10) 
    --path[#path + 1] = mist.ground.buildWP(shipsZones[math.random(1, #shipsZone)], nil, 10) 
    --mist.goRoute(group:getName(), path)
    
    --add steerpoints
    --mist.ground.patrol(group)
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
        local offset = math.random (600, 800)
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

function genSam(vec3, mark, _radius, _innerRadius) -- generates SAM site in random location around point vec3, boolean mark sets f10 marker
    if _radius == nil then
        _radius = 10000
    end
    if _innerRadius == nil then
        _innerRadius = 8000
    end
    sam = samList[math.random(#samList)]
    samId = samId + 1
    mist.teleportToPoint {
        groupName = sam,
        point = vec3,
        action = "clone",
        disperse = false,
        radius = _radius,
        innerRadius = _innerRadius
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
    elseif string.find(unitType, "S-125") then --SA-2
        samType = "SA-3"
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
    for amount = 1, amount, 1 do
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
        
        --mist.teleportToPoint {
        --    groupName = blueGround[math.random(#blueGround)],
        --    point = mist.vec.add(vec3, offset),
        --    action = "clone",
        --    disperse = false,
        --}
        --objectiveCounter = objectiveCounter + 1

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
    trigger.action.circleToAll(-1 , 1202 , vec3 , 1000 , objColor , objColorfill , 2 , true)
    trigger.action.textToAll(-1 , 1203 , vec3 , objColor , {0, 0, 0, 0} , 20 , true , markerName )
end

function markObjectiveZone(markerName, zoneName, markerFlag, scatter) -- marks objective on F10 map, each markerFlag must be unique
    local vec3Random = {
        x = math.random(-scatter,scatter),
        y = math.random(-scatter,scatter),
        z = math.random(-scatter,scatter)
    }
    local vec3 = mist.vec.add(mist.utils.zoneToVec3(zoneName), vec3Random)
    trigger.action.markToAll(markerFlag, markerName, vec3, true)
    trigger.action.circleToAll(-1 , 1202 , vec3 , 1000 , objColor , objColorfill , 2 , true)
    trigger.action.textToAll(-1 , 1203 , vec3 , objColor , objColorfill , 20 , true , markerName )
end

function markHomeplate()
    local _vec3 = mist.utils.zoneToVec3("redTarget-1")
    trigger.action.circleToAll(-1 , 1200 , _vec3 , 1000 , {0, 0, 1, 1} , {0, 0, 1, 0.3} , 2 , true)
    trigger.action.textToAll(-1 , 1201 , _vec3 , {0, 0, 1, 1} , {0, 0, 0, 0} , 20 , true , "home plate" )
end

function markTankerTrack()

end

function markSearchArea(groupName)
    local _grpVec3 = Group.getByName(groupName):getUnit(1):getPoint()
    local _offsetX1 = math.random(0 - markerScatter, 0)
    local _offsetX2 = _offsetX1 + 2 * markerScatter
    local _offsetZ1 = math.random(0 - markerScatter, 0)
    local _offsetZ2 = _offsetZ1 + 2 * markerScatter

    local _nw = {
        x = _grpVec3.x + _offsetX2,
        y = _grpVec3.y,
        z = _grpVec3.z + _offsetZ1,
    }
    local _ne = {
        x = _grpVec3.x + _offsetX2,
        y = _grpVec3.y,
        z = _grpVec3.z + _offsetZ2,
    }
    local _se = {
        x = _grpVec3.x + _offsetX1,
        y = _grpVec3.y,
        z = _grpVec3.z + _offsetZ2,
    }
    local _sw = {
        x = _grpVec3.x + _offsetX1,
        y = _grpVec3.y,
        z = _grpVec3.z + _offsetZ1,
    }
    trigger.action.markToAll(301, "Search area: NW", _nw, false)
    trigger.action.markToAll(302, "Search area: NE", _ne, false)
    trigger.action.markToAll(303, "Search area: SE", _se, false)
    trigger.action.markToAll(304, "Search area: SW", _sw, false)

    trigger.action.quadToAll(-1 , 1202 , _nw , _ne , _se , _sw , objColor , objColorfill , 2 , true, "search area")
    trigger.action.textToAll(-1 , 1203 , _nw , objColor , {0, 0, 0, 0} , 20 , true , "SEARCH AREA" )

    vec3Prim = _nw --quick and easy fix to make it less trivial to find

    local _outString = "" --for new notifyObjective
    return _outString
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

function notifyObjective()  --needs changing for new objective types
    if primCompletion == false then
        if primObjectiveType == 5 then         
            message = "The primary objective is a "..primName.." at: \n"
        else 
            message = "The primary objective is a "..primName.." that has been located in the area near: \n"
        end
        message = message..notifyCoords(vec3Prim, 1).." N, "..notifyCoords(vec3Prim, 2).." E, "..notifyCoords(vec3Prim, 3).." ft.\n"
        message = message.."\n Beware, SAM sites have been spotted near: \n"

        for i = 1,#vec3Sam,1 do
            message = message.."- " .. vec3SamType[i] .. ": "..notifyCoords(vec3Sam[i], 1).." N, "..notifyCoords(vec3Sam[i], 2).."E, "..notifyCoords(vec3Sam[i],3).." ft.\n" 
        end
        
        notify(message, 45)
    else
        notify("Primary objective has been completed, RTB.", 60)
    end
end

function markCarrierPos() --using the same id again doesn't work for some reason
    if Group.getByName ("CVN-71 Theodore Roosevelt") then
        trigger.action.removeMark(carrierMarkerId)
        carrierMarkerId = carrierMarkerId + 1
        trigger.action.markToAll(carrierMarkerId, "CVN-71 Theodore Roosevelt", Group.getByName ("CVN-71 Theodore Roosevelt"):getUnit(1):getPoint(), false)
        mist.scheduleFunction(markCarrierPos , {} ,timer.getTime() + 300 )
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
        genAirbaseSam(airbaseZones[i], false ) --airbase sam markers are mainly confusing
    end
    
    env.error(debugHeader.."1" , false)
    genPrimObjective()
    env.error(debugHeader.."2" , false)
    timer.scheduleFunction(checkPrimCompleted, {}, timer.getTime() + 1)
    env.error(debugHeader.."3" , false)
    timer.scheduleFunction(checkSamCompleted, {}, timer.getTime() + 1)
    env.error(debugHeader.."4" , false)
    IADS:getSAMSites():setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)
    env.error(debugHeader.."5" , false)
    IADS:activate()
    env.error(debugHeader.."6" , false)
    A2A_DISPATCHER()
    env.error(debugHeader.."7" , false)
    readSettings()
    env.error(debugHeader.."8" , false)

    missionCommands.removeItem(radioSubMenuStartCommands)
    radioMenuReadSettings = missionCommands.addCommand ("Display selected settings", invasionCommandsRoot, readSettings)
    notify("Mission started.", 15)
    STTS.TextToSpeech("Mission started.", 243, "AM", "1.0", "SERVER", 2)
    env.error(debugHeader.."Mission started" , false)
end

function readSettings ()
    for i = 1, #settingsArray, 1 do
        notify ( settingsArray[i], 15)
    end
end

--other comms settings

function setDifficulty(mode)
    local difficultyNames = {"Normal", "Hard"}
    local difficultyFactors = {1 ,hardModeFactor}
    difficultyFactor = difficultyFactors[mode]

    if mode == 2 then --hard mode
        settingsArray[2] = "difficulty: " .. difficultyNames[mode]
        capSpawnLimit = nil
    else --normal mode
        settingsArray[2] = "difficulty: " .. difficultyNames[mode]
        capSpawnLimit = 4
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
    
    env.error(debugHeader.."SAM disabled", false)
end


function enableEnemySam ()
    notify ("SAM enabled", 5)
    settingsArray[4] = "SAM enabled"
    enableSams = 1

    env.error(debugHeader.."SAM enabled", false)
end

--target types

function setTarget(type)
    if type == "random" then

    end

    if type == "building" then
        notify("selected building target", 5)
        primObjectiveType = 1
        markerScatter = 0
        enableEnemySam()
        settingsArray[1] = "Building target"
        
    elseif type == "search" then
        notify("selected search and destroy target", 5)
        primObjectiveType = 2
        markerScatter = 15000
        disableEnemySam()
        settingsArray[1] = "search and destroy target"
        
    elseif type == "sam" then
        notify("selected SAM target", 5)
        primObjectiveType = 3
        markerScatter = 0
        disableEnemySam() --sa10 is enough trouble as it is
        settingsArray[1] = "SAM target"

    elseif type == "ship" then
        notify("selected ship target", 5)
        primObjectiveType = 6
        markerScatter = 1000
        enableEnemySam() --no idea if necessary, but just to be safe
        settingsArray[1] = "Ship target"

    elseif type == "convoy" then
        notify("selected convoy target", 5)
        primObjectiveType = 4 --needs to be done
        markerScatter = 0
        disableEnemySam()
        settingsArray[1] = "Convoy target"

    elseif type == "mapObjective" then
        notify("selected Precision Strike", 5)
        primObjectiveType = 5
        markerScatter = 0
        enableEnemySam()
        settingsArray[1] = "Precision Strike"
    end
end

function setTargetRandom ()
    local random = math.random(1, 2)
    notify ("selected random target", 5)
    if random == 1 then
        setTargetBuilding()
    end
    if random == 2 then
        setTargetSearchAndDestroy()
    end
end

function setTargetBuilding ()
    notify("selected building target", 5)
    primObjectiveType = 1
    markerScatter = 0
    enableEnemySam()
    settingsArray[1] = "Building target"
end

function setTargetSearchAndDestroy ()
    notify("selected search and destroy target", 5)
    primObjectiveType = 2
    markerScatter = 15000
    disableEnemySam()
    settingsArray[1] = "search and destroy target"
end

function setTargetSpecialSam ()
    notify("selected SAM target", 5)
    primObjectiveType = 3
    markerScatter = 0
    disableEnemySam() --sa10 is enough trouble as it is
    settingsArray[1] = "SAM target"
end

function setTargetShip ()
    notify("selected ship target", 5)
    primObjectiveType = 6
    markerScatter = 1000
    enableEnemySam() --no idea if necessary, but just to be safe
    settingsArray[1] = "Ship target"
end

function setTargetConvoy ()
    notify("selected convoy target", 5)
    primObjectiveType = 4 --needs to be done
    markerScatter = 0
    enableEnemySam()
    settingsArray[1] = "Convoy target"
end

function setPrecisionStrike ()
    notify("selected Precision Strike", 5)
    primObjectiveType = 5
    markerScatter = 0
    enableEnemySam()
    settingsArray[1] = "Precision Strike"
end
--more Options

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
    DetectionSetGroupRED:FilterPrefixes( { "EWR Base", "AWACS Red 1", "AWACS Red 2", "AWACS Red 3"} )
    DetectionSetGroupRED:FilterStart()

    IADS:addMooseSetGroup(DetectionSetGroupRED)
    DetectionRED = DETECTION_AREAS:New( DetectionSetGroupRED, 30000 )

    --Init Dispatcher
    A2ADispatcherRED = AI_A2A_DISPATCHER:New( DetectionRED, 30000 )

    --Define Border
    BorderRED = ZONE_POLYGON:New( "BORDER Red", GROUP:FindByName( "BORDER Red" ) )
    A2ADispatcherRED:SetBorderZone( BorderRED )

    -- Define CAP Zones
    CAPZoneNorth = ZONE_POLYGON:New( "CAP Zone North", GROUP:FindByName( "CAP Zone North" ) )
    CAPZoneMiddle = ZONE_POLYGON:New( "CAP Zone Middle", GROUP:FindByName( "CAP Zone Middle" ) )
    CAPZoneSouth = ZONE_POLYGON:New( "CAP Zone South", GROUP:FindByName( "CAP Zone South" ) )

    --Define EngageRadius
    A2ADispatcherRED:SetEngageRadius( 130000 )

    --Define Squadrons

    A2ADispatcherRED:SetSquadron( "CAP_RED_1", act.capAirbases[1], capRed, capSpawnLimit )
    A2ADispatcherRED:SetSquadron( "CAP_RED_2", act.capAirbases[2], capRed, capSpawnLimit )
    A2ADispatcherRED:SetSquadron( "CAP_RED_3", act.capAirbases[3], capRed, capSpawnLimit )

    --Define Squadron properties
    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_1", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_1", 2 )

    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_2", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_2", 2 )

    A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_3", 1 )
    A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_3", 2 )

    --Define CAP Squadron execution
    A2ADispatcherRED:SetSquadronCap( "CAP_RED_1", CAPZoneNorth,  6000, 8000, 600, 900, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_1", capLimit, lowInterval, highInterval, probability) --old settings were 450, 550

    A2ADispatcherRED:SetSquadronCap( "CAP_RED_2", CAPZoneMiddle,  3000, 9000, 400, 800, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_2", capLimit, lowInterval, highInterval, probability) --old settings were 450, 550

    A2ADispatcherRED:SetSquadronCap( "CAP_RED_3", CAPZoneSouth,  3000, 9000, 400, 800, 600, 900, "BARO")
    A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_3", capLimit, lowInterval, highInterval, probability) --old settings were 450, 550

    --Debug
    A2ADispatcherRED:SetTacticalDisplay( enableDebug )

    --Define Defaults
    --A2ADispatcherRED:SetDefaultTakeOffFromRunway() --commented out for now
    A2ADispatcherRED:SetDefaultLandingAtRunway()
end

function convoySetup(number)
    local _vars = {
        speed = 15, --m/s
        minDist = 50000, --m
        maxDist = 75000, --m
    }
    local convoyGroupName = nil

    convoy.setup("convoy", convoyRedAttackZone , convoyRedList, objectiveLocList, checkpointsBlue, _vars)

    --convoy.setup("convoy", convoyRedAttackZone , convoyRedList, objectiveLocList, checkpointsBlue, _vars)
    for i = 1, number, 1 do
        convoyGroupName = convoy.start()
    end
    return convoyGroupName
end

function restartMission ()
    trigger.action.setUserFlag(restartFlag, 1)
    notify("THE SERVER IS RESTARTING IN 3 MINUTES", 179)
end

-- MAIN SETUP --
do

    _SETTINGS:SetPlayerMenuOff()
    notify("Starting init", 5)
    env.error("--- IOTR Init Starting" , false)

    --[[

        adds the F-10 radio commands for the mission
    ]]


    --submenus
    radioSubMenuStartCommands = missionCommands.addSubMenu ("Start Commands") --nested submenu for start commands
    invasionCommandsRoot = missionCommands.addSubMenu ("Invasion Commands") --invasion commands submenu

    --invasion command submenu
    radioMenuObjectiveInfo = missionCommands.addCommand("Objective info", invasionCommandsRoot, notifyObjective)
    radioMenuStartHelicopterMission = missionCommands.addCommand("Start Helicopter mission", invasionCommandsRoot, genHeloObjective)

    radioMenuRestart1 = missionCommands.addSubMenu ("restart Mission", invasionCommandsRoot)
    radioMenuRestart2 = missionCommands.addSubMenu ("are you sure?", radioMenuRestart1)
    radioMenuRestart3 = missionCommands.addSubMenu ("are you really sure?", radioMenuRestart2)
    radioMenuRestart4 = missionCommands.addCommand ("restart!", radioMenuRestart3, restartMission)

    --start commands submenu
    radioMenuManualStart = missionCommands.addCommand("Apply settings and start", radioSubMenuStartCommands , manualStart)
    --target type settings
    radioMenuTargetRandom = missionCommands.addCommand ("Set target type: Random", radioSubMenuStartCommands, setTargetRandom)
    radioMenuTargetBuilding = missionCommands.addCommand ("Set target type: Building", radioSubMenuStartCommands, setTargetBuilding)
    radioMenuTargetMapObject = missionCommands.addCommand ("Set target type: Precision Strike", radioSubMenuStartCommands, setPrecisionStrike)
    radioMenuTargetSpecial = missionCommands.addCommand ("Set target type: Search and Destroy", radioSubMenuStartCommands, setTargetSearchAndDestroy)
    --radioMenuTargetSpecialSam = missionCommands.addCommand ("Set target type: SAM", radioSubMenuStartCommands, setTargetSpecialSam)
    radioMenuTargetSpecialShip = missionCommands.addCommand ("Set target type: Ship", radioSubMenuStartCommands, setTargetShip)
    radioMenuTargetConvoy = missionCommands.addCommand ("Set target type: Convoy", radioSubMenuStartCommands, setTargetConvoy)
    --difficulty settings
    radioMenuNormalMode = missionCommands.addCommand ("Set difficulty: Normal", radioSubMenuStartCommands, setDifficulty, 1)
    radioMenuHardMode = missionCommands.addCommand ("Set difficulty: Hard", radioSubMenuStartCommands, setDifficulty, 2)
    radioMenuEnableCap = missionCommands.addCommand ( "Enable enemy CAP", radioSubMenuStartCommands, enableEnemyCap)

    --default settings
    trigger.action.markToAll(carrierMarkerId, "CVN-71 Theodore Roosevelt", Group.getByName ("CVN-71 Theodore Roosevelt"):getUnit(1):getPoint(), false)
    --markHomeplate() --looks kinda bad
    mist.scheduleFunction(markCarrierPos, {}, timer.getTime() + 15)
    probability = probabilityDefault
    enableEnemyCap()
    setDifficulty(1)
    setTargetRandom()

    --endtesting
    
    timer.scheduleFunction(autoStart, {}, timer.getTime() + 900) --autostart of the mission after 10 minutes, if no manual start was selected
    notify("IOTR init completed", 5)
    env.error("--- IOTR Init completed" , false)
end
