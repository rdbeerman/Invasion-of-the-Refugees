cc = {}

cc.carrierName = "CVN-71 Theodore Roosevelt"
cc.windDirection = 0
cc.intoWindDistance = 60000 -- Distance from carrier to new wp into wind in meters
cc.velOverDeck = 15         -- Desired wind velocity over deck in m/s
cc.velCruise = 15           -- normal cruise speed when not lined up with wind in m/s

function cc.getWind(vec3)
    local vec3mod = {}
    vec3mod = mist.utils.makeVec3GL ( vec3 )
    vec3mod.y = vec3mod.y + 10
    local windVec3 = {}
    windVec3 = atmosphere.getWind(vec3mod)

    return windVec3
end

function cc.turnIntoWind(groupName)
    local groupVec3 = Group.getByName(groupName):getUnit(1):getPoint()
    local windVec3 = cc.getWind(groupVec3)
    local windMag = mist.vec.mag(windVec3)
    local downWindVec2 = mist.vec.rotateVec2(mist.utils.makeVec2(windVec3), math.pi )
    local downWindVec3 = mist.utils.makeVec3GL(downWindVec2)

    local _intoWindVec3 = mist.utils.makeVec3GL ( 
        mist.vec.add( groupVec3, mist.vec.scalar_mult(downWindVec3, cc.intoWindDistance / windMag )  )
    )

    --TODO: check if on land

    --cc.smokeVec3(_intoWindVec3)
    --cc.smokeVec3(groupVec3)

    
    cc.moveToVec3(groupName, _intoWindVec3, windMag)
end

function cc.moveToVec3(groupName, vec3, windMag)
    local _groupVec3 = Group.getByName(groupName):getUnit(1):getPoint()
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    local _vel = cc.velOverDeck + windMag            -- Set velocity so speed over deck is desired val.
    
    --cc.smokeVec3(_groupVec3)
    --cc.smokeVec3(_vec3GL)
    
    local path = {}
	path[#path + 1] = mist.ground.buildWP (_groupVec3, nil, 5)
    path[#path + 1] = mist.ground.buildWP (_vec3GL, nil, 7)
    path[#path + 1] = mist.ground.buildWP (_groupVec3, nil, 10 )
    
    mist.goRoute(groupName, path)

    -- Notify player about carrier:
    local _duration = math.floor(( cc.intoWindDistance / _vel ) / 60 ) 
    cc.notify("Carrier steering into the wind for ".._duration.." minutes", 10)
    
    timer.scheduleFunction(cc.patrol, {}, timer.getTime() + _duration * 60)
end

function cc.patrol()
    mist.ground.patrol(cc.carrierName, 'doubleBack')
    cc.notify("The Carrier is returning to it's patrol route.", 10)
end

function cc.notify(message, displayFor)
    trigger.action.outText(message, displayFor)
end

function cc.smokeVec3 (vec3)
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

do
    cc.radioSubMenu = missionCommands.addSubMenu ("Carrier Commands")
    cc.radioTurnIntoWind = missionCommands.addCommand ("Steer carrier into wind", cc.radioSubMenu, cc.turnIntoWind, cc.carrierName)

    cc.notify ("carrierCourse init complete", 5)
end