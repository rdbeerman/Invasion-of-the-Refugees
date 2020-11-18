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
shoradNumberDefault = 2
pointDefenseExists = false
--cap numbers
capLimitDefault = 1
lowIntervalDefault = 500
highIntervalDefault = 1000
probabilityDefault = 1
--easy mode factor
easyModeFactor = 0.5 --50% less enemies
--hard mode factor
hardModeFactor = 1.5 --50% more enemies

-- Set templates --
-- Import map specific templates
objectiveLocList = act.getZones()
primObjectiveList = act.getPrimObjectives()

typeStructure = act.getStructures()
typeSpecial = act.getTypeSpecial()
typeSpecialSam = act.getTypeSpecialSam()

samList = act.getSams()
ewrList = act.getEwrs()
shoradList = act.getShorad()
defenseList = act.getDefenses()
defenseListSmall = act.getSmallDefenses()
pointDefenseList = act.getPointDefenses()
capRed = act.getRedCap ()
--helo stuff
blueGround = act.getBlueGround()
heloObjectives = act.getHeloObjectives()
escortList = act.getEscort()
--airbase stuff
airbaseZones = act.getAirbaseZones()
typeAirbase = act.getAirbaseStructures()
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

settingsArray = {"", "", "", ""}

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
        primObjectiveType = math.random(2, 4)
    end

    if primObjectiveType == 1 then --airfield
        primObjective = typeStructure[math.random(#typeStructure)] --wrong needs fixing before implementation
        genAirbaseTarget ()

        env.error(debugHeader.."Completed Objective airbase spawning.", false)
        
        if enableDebug == true then
            notify("airbase target spawning", 5)
        end
    end

    if primObjectiveType == 2 then --structure
        primObjective = typeStructure[math.random(#typeStructure)]
        genStructureTarget ()

        env.error(debugHeader.."Completed Objective stucture spawning.", false)
        if enableDebug == true then
            notify("structure target spawning", 5)
        end
    end

    if primObjectiveType == 3 then --vehicle
        primObjective = typeSpecial[math.random(#typeSpecial)]
        genVehicleTarget ()

        env.error(debugHeader.."Completed Objective vehicles spawning.", false)
        if enableDebug == true then
            notify("vehicle target spawning", 5)
        end
    end

    if primObjectiveType == 4 then --SAM (SA-10)
        primObjective = typeSpecialSam[math.random(#typeSpecialSam)]
        genSamTarget ()

        env.error(debugHeader.."Completed Objective SAM spawning.", false)
        if enableDebug == true then
            notify("SAM target spawning", 5)
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

            genSurroundings( vec3Prim , samNumber, ewrNumber, shoradNumber , true ) --moved defenses to an extra function (postion, sam, ewr, short range defenses)

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

            genSurroundings( vec3Prim , samNumber, ewrNumber, shoradNumber ,  true ) --position, sam, ewr, defenses

            env.error(debugHeader..primObjective.."@"..objectiveLoc, false)
            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 60)
            end
            return
        end
    end
end

function genSamTarget () --not integrated into IADS so far. Should also work as an EWR
    for i = 1,#typeSpecialSam,1 do -- check if generated objective is a special objective with custom name
        if primObjective == typeSpecialSam[i] then
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

            local specialSamNames = act.getSpecialSamNames()

            primName = specialSamNames[i] -- get objective name by using index in specialNames
            local markerName = "Objective: "..specialSamNames[i]
            markObjective(markerName , countryName.." gnd "..tostring(objectiveCounter), primMarker)

            IADS:addSAMSite(countryName.." gnd "..tostring(objectiveCounter)) --add SA-10 to IADS
            improveSamAuto (countryName.." gnd "..tostring(objectiveCounter))
            
            if pointDefenseExists == true then
                genPointDefense (vec3Prim, countryName.." gnd "..tostring(objectiveCounter), 1)
            end

            genSurroundings( vec3Prim , samNumber, ewrNumber, shoradNumber ,  true ) --position, sam, ewr, defenses

            env.error(debugHeader..primObjective.."@"..objectiveLoc, false)
            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 60)
            end
            return
        end
    end
end

function genAirbaseTarget () --not used right now --idea: use it to place fuel tanks, if fuel tanks get destroyed, the airbase has reduced spawnrate

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

            env.error(debugHeader..primObjective.."@"..objectiveLoc, false)
            if enableDebug == true then
                notify(primObjective.."@"..objectiveLoc, 60)
            end
            return
        end
    end

end

function genSurroundings ( vec3, samQuantity, ewrQuantity, satellitesQuantity, defenses ) --generates SAMs, EWRs and defenses

    for i = 1 , samQuantity, 1 do
        genSam ( vec3 , true ) --generates a SAM site with a chance to detect SEAD missiles
    end

    if ewrQuantity ~= 0 then
        genEwr ( vec3 , ewrQuantity )
    end

    if defenses == true then
        genDefense( vec3 ) --generates the short range defenses of an objective
    end

    if satellitesQuantity ~= 0 then
        genShorad ( vec3 , satellitesQuantity )
    end
end

function genDefense(vec3) -- generates a defense group at point vec3 with set offset
    local offset = {
        x = -250, --changed from -2000 after decreasing the diameter of the template
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
    env.error(debugHeader.."Spawned defense.", false)
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

        if i == 1 then
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
    local offset = 6000

    for i = 1 , amount , 1 do

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

            if primObjectiveType == 4 then --changes the integration of the SA-15 depending on the type of primary objective
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

function genEscort() -- function for spawning escort group using F10 Menu
    local escortName = escortList[math.random(#escortList)]
    local escort = Group.getByName(escortName)
    trigger.action.activateGroup(escort)
    notify("A B52H is preparing for takeoff from Bandar Abbas Intl to perform a runway attack on Kerman Airport.", 5)

    env.error(debugHeader.."Spawned escort mission", false)
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

--[[

    manual start and difficulty selection before the mission starts (first 120 seconds)

]]

function autoStart()
    if primObjectiveCounter == 0 then
        manualStart()
    end
end

function manualStart() -- problem is here
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
    notify("Mission started!", 15)
end

--[[

Settings Array:
[1] target type
[2] difficulty setting
[3] CAP state (on or off)

]]

function readSettings ()
    for i = 1, #settingsArray, 1 do
        notify ( settingsArray[i], 15)
    end
end

--debug radio settings

function radioEnableIadsDebug ()
    enableIadsDebug = true
    toggleIadsDebug( enableIadsDebug )
    radioMenuDisableIadsDebug = missionCommands.addCommand ("Disable IADS debug (full)", radioSubMenuDebugCommands, radioDisableIadsDebug)
    missionCommands.removeItem (radioMenuEnableIadsDebug)
    notify ("IADS debug enabled", 15)
end

function radioDisableIadsDebug()
    enableIadsDebug = false
    toggleIadsDebug( false )
    radioMenuEnableIadsDebug = missionCommands.addCommand ("Enable IADS debug (full)", radioSubMenuDebugCommands, radioEnableIadsDebug)
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
    
--difficulty settings

function setDifficultySam(mode)
    difficultyNames = {"Easy", "Medium", "Hard"}
    difficultyFactors = {easyModeFactor, 1 ,hardModeFactor}
    local factor = difficultyFactors[mode]

    notify("selected SAM difficulty: "..difficultyNames[mode], 5)

    ewrNumber = math.ceil ( ewrNumberDefault * factor )
    samNumber = math.ceil ( samNumberDefault * factor )
    shoradNumber = math.ceil ( shoradNumberDefault * factor )

    settingsArray[2] = "SAM difficulty: " .. difficultyNames[mode]
    env.error(debugHeader.."selected SAM difficulty: "..difficultyNames[mode], false)
end

function setDifficultyCap(mode)
    difficultyNames = {"Easy", "Medium", "Hard"}
    difficultyFactors = {easyModeFactor, 1 ,hardModeFactor}
    local factor = difficultyFactors[mode]

    notify("selected CAP difficulty: "..difficultyNames[mode], 5)

    lowInterval = math.ceil ( lowIntervalDefault / factor )
    highInterval = math.ceil ( highIntervalDefault / factor )
    settingsArray[3] =  "CAP difficulty: " .. difficultyNames[mode]

    env.error(debugHeader.."selected CAP difficulty: "..difficultyNames[mode], false)
end

function setDisableEnemyCap ()
    notify("CAP disabled", 5)
    capLimit = 0
    settingsArray[4] = "CAP disabled"
    radioMenuEnableCap = missionCommands.addCommand ( "enable enemy CAP", radioSubMenuStartCommands, setEnableEnemyCap)
    missionCommands.removeItem (radioMenuDisableCap)

    env.error(debugHeader.."Disabled CAP", false)
end

function setEnableEnemyCap ()
    notify("CAP enabled", 5)
    capLimit = capLimitDefault
    settingsArray[4] = "CAP enabled"
    radioMenuDisableCap = missionCommands.addCommand ( "Disable enemy CAP", radioSubMenuStartCommands, setDisableEnemyCap)
    missionCommands.removeItem (radioMenuEnableCap)

    env.error(debugHeader.."Enabled CAP", false)
end

function addAwacsToIads ()
    IADS:addEarlyWarningRadar("AWACS Red #001")
    notify ("AWACS added to IADS", 5)
end

function setTargetRandom ()
    local random = math.random(2, 4)
    notify ("selected random target", 5)
    if random == 2 then
        setTargetBuilding()
    end
    if random == 3 then
        setTargetSpecial()
    end
    if random == 4 then
        setTargetSpecialSam()
    end
end

function setTargetBuilding ()
    notify("selected building target", 5)
    primObjectiveType = 2
    settingsArray[1] = "Building target"
end

function setTargetSpecial ()
    notify("selected vehicles target", 5)
    primObjectiveType = 3
    settingsArray[1] = "Vehicle target"
end

function setTargetSpecialSam ()
    notify("selected SAM target", 5)
    primObjectiveType = 4
    settingsArray[1] = "SAM target"
end

function setAddPointDefense ()
    notify("added point defense to primary target", 5)
    pointDefenseExists = true --ugly testing solution
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

-- MAIN SETUP --
do

    _SETTINGS:SetPlayerMenuOff()
    notify("Starting init", 5)

    --[[
        adds the F-10 radio commands for the mission

        todo: add a lot of additional options to set every spawn parameter, because why not. Should be nested "guided" menus similar to Lcode in JF
    ]]
    --submenus
    invasionCommandsRoot = missionCommands.addSubMenu ("Invasion Commands") --invasion commands submenu
    radioSubMenuStartCommands = missionCommands.addSubMenu ("Start Commands", invasionCommandsRoot) --nested submenu for start commands

    --invasion command submenu
    radioMenuReadSettings = missionCommands.addCommand ("Display selected settings", invasionCommandsRoot, readSettings)
    radioMenuObjectiveInfo = missionCommands.addCommand("Objective info", invasionCommandsRoot, notifyObjective)
    radioMenuStartEscortMission = missionCommands.addCommand("Start Escort mission", invasionCommandsRoot, genEscort)
    radioMenuStartHelicopterMission = missionCommands.addCommand("Start Helicopter mission", invasionCommandsRoot, genHeloObjective)

    --deubg command submenu
    radioMenuEnableIadsDebug = missionCommands.addCommand ("Enable IADS Debug (full)", radioSubMenuDebugCommands, radioEnableIadsDebug)
    radioMenuEnableDispatcherDebug = missionCommands.addCommand ("Enable AA-Dispatcher Debug", radioSubMenuDebugCommands, radioEnableAirDispatcherDebug)

    --start commands submenu
    radioMenuManualStart = missionCommands.addCommand("Apply settings and start", radioSubMenuStartCommands , manualStart)
    --target type settings
    radioSubMenuTargetType = missionCommands.addSubMenu ("Set target type:", radioSubMenuStartCommands)

    radioMenuTargetRandom = missionCommands.addCommand ("Set target type: Random", radioSubMenuTargetType, setTargetRandom)
    radioMenuTargetBuilding = missionCommands.addCommand ("Set target type: Building", radioSubMenuTargetType, setTargetBuilding)
    radioMenuTargetSpecial = missionCommands.addCommand ("Set target type: Vehicle group", radioSubMenuTargetType, setTargetSpecial)
    radioMenuTargetSpecialSam = missionCommands.addCommand ("Set target type: SAM", radioSubMenuTargetType, setTargetSpecialSam)
    radioMenuAddPointDefense = missionCommands.addCommand ("Add point defense to primary objective", radioSubMenuTargetType, setAddPointDefense)
    --difficulty settings
    --sam
    radioSubMenuSamDifficulty = missionCommands.addSubMenu ("Set SAM difficulty:", radioSubMenuStartCommands)

    radioMenuEasyModeSam = missionCommands.addCommand ("Set SAM difficulty: Easy", radioSubMenuSamDifficulty, setDifficultySam, 1)
    radioMenuNormalModeSam = missionCommands.addCommand ("Set SAM difficulty: Medium", radioSubMenuSamDifficulty, setDifficultySam, 2)
    radioMenuHardModeSam = missionCommands.addCommand ("Set SAM difficulty: Hard", radioSubMenuSamDifficulty, setDifficultySam, 3)
    --cap
    radioSubMenuCapDifficulty = missionCommands.addSubMenu ("Set CAP difficulty:", radioSubMenuStartCommands)

    radioMenuEasyModeCap = missionCommands.addCommand ("Set CAP difficulty: Easy", radioSubMenuCapDifficulty, setDifficultyCap, 1)
    radioMenuNormalModeCap = missionCommands.addCommand ("Set CAP difficulty: Medium", radioSubMenuCapDifficulty, setDifficultyCap, 2)
    radioMenuHardModeCap = missionCommands.addCommand ("Set CAP difficulty: Hard", radioSubMenuCapDifficulty, setDifficultyCap, 3)
    --cap settings
    radioMenuEnableCap = missionCommands.addCommand ( "Enable enemy CAP", radioSubMenuStartCommands, setEnableEnemyCap)
    radioMenuAddAwacsToIads = missionCommands.addCommand ( "Add AWACS to IADS", radioSubMenuStartCommands, addAwacsToIads)
    
    radioSubMenuDebugCommands = missionCommands.addSubMenu ("Debug Commands", invasionCommandsRoot)

    --default settings
    probability = probabilityDefault
    setEnableEnemyCap()
    setDifficultySam(2)
    setDifficultyCap(1)
    setTargetRandom()

    timer.scheduleFunction(autoStart, {}, timer.getTime() + 600) --autostart of the mission after 10 minutes, if no manual start was selected

    notify("init completed", 5)
    
end
