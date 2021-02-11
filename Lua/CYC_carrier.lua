    --  Name:                           CYC_carrier
    --  Author:                         Tony
	-- assert(loadfile('C:\\Users\\username\\Saved Games\\DCS.openbeta\\Missions\\In dev\\t45\\Lua\\ACT_loadModules.lua'))()
    --  Dependencies:                   Mist.lua,
    --  Description:
    --      Carrier function that allows you to drive the carrier around the map via marks on the F10 map
	--		Also plays sound files to the units for deck and helps provide carrier info and recovery / launch times
    --  Usage:
    --      1. You need to load all of the sound files into the mission with the correct names to ensure they actually play
	-- 		2. You need to create the carrier and name it exactly as below, set freq, tacan and ICLS as below as well (or edit)
--[[List of outstanding work to do
   
	4. If carrier unit not alive, just print message saying carrier is unavaliable 
	10. Radio channel broadcast of Hornet 3500, Tomcat 5500, S3 -, E2, current time and when recovery time is expected
	11. Checking altitudes of units in the stack
]]--
-- Declaration
cvn = {}
cvn.carrierName = "CVN-71 Theodore Roosevelt" -- must match groupname in game
cvn.carrierFreq = "127.5 MHz"
cvn.carrierTacan = "71X"
cvn.carrierICLS = "Chan 2"
cvn.startUpTime = 900 -- DO NOT MAKE THIS LESS THAN 200 seconds. this is the time in seconds you want to give to people to start up the jets and be ready to launch in cyclic ops
cvn.landWindowTime = 900


lha = {}
lha.carrierName = "LHA-1 Tarawa" -- must match groupname in game

rke = {}
rke.carrierName = "Redkite" -- must match groupname in game
rke.radius = 1000


function notify(message, displayFor) --activiy notify function
    trigger.action.outText(message, displayFor)
end

function cvn.Waypoint(carrierSpeed,cvnVec3) -- turn Carrier to a waypoint function, get in correctly fomratted speeds in knots 
	notify("Carrier changing course and speed",5) --prints some crap out the carrier is changing
	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint() --gets a vec3 where the carrier actually is
	local path = {} --build the waypoint to, from for the unit
	path[#path + 1] = mist.ground.buildWP (_groupVec3, nil, carrierSpeed*0.58) -- from vec3 note speeds are *0.58 for a crude knots to ms
    path[#path + 1] = mist.ground.buildWP (cvnVec3, nil, carrierSpeed*0.58) -- to vec3
    mist.goRoute(cvn.carrierName, path) --push to carrier to make it react
	
	--announce turns if hard
		--if fast
		--if more than 30 degrees
		
	--angle between _groupVec3 and cvnVec3	
	
	--get first vector which is carrier position 
	--get second vector which is waypoint position vector
	--take the x from the x the y from the y 
	
	--maths the angle of the points
	diff = mist.vec.sub(cvnVec3,_groupVec3)
	y = cvnVec3.z - _groupVec3.z
	--y = _groupVec3.z - cvnVec3.z
	x = cvnVec3.x - _groupVec3.x
	--x = _groupVec3.x - cvnVec3.x
	local courseCVN = math.atan2((diff.z),(diff.x)) + math.pi 
	local courseCVNdeg = math.deg (courseCVN)
	local courseCVNdeg = courseCVNdeg 
	
	if courseCVNdeg < 0 then
		courseCVNdeg = courseCVNdeg + 360	
	end
	if courseCVNdeg <= 180 then
		courseCVNdeg = courseCVNdeg + 180
	else
		courseCVNdeg = courseCVNdeg - 180
	end
	if courseCVNdeg > 360 then
		courseCVNdeg = courseCVNdeg - 360
	end
	
	courseCVNdeg = math.floor(courseCVNdeg)
	
	--carrier heading	local carrHeadingRad = mist.getHeading(Unit.getByName(cvn.carrierName))
	local carrHeadingRad = mist.getHeading(Unit.getByName(cvn.carrierName))
	local carrHeadingRad = math.deg (carrHeadingRad) 
	local carrHeadingDeg = math.floor (carrHeadingRad)

	--work out which direction of turn and play appropriate sound to all on deck

	if (carrHeadingDeg - courseCVNdeg) < 180 then
		cvn.turnPort()
	else
		cvn.turnStarboard()
	end
end

function lha.Waypoint(carrierSpeed,cvnVec3) -- turn Carrier to a waypoint function, get in correctly fomratted speeds in knots 
	notify("Carrier changing course and speed",5) --prints some crap out the carrier is changing
	local _groupVec3 = Group.getByName(lha.carrierName):getUnit(1):getPoint() --gets a vec3 where the carrier actually is
	local path = {} --build the waypoint to, from for the unit
	path[#path + 1] = mist.ground.buildWP (_groupVec3, nil, carrierSpeed*0.58) -- from vec3 note speeds are *0.58 for a crude knots to ms
    path[#path + 1] = mist.ground.buildWP (cvnVec3, nil, carrierSpeed*0.58) -- to vec3
    mist.goRoute(lha.carrierName, path) --push to carrier to make it react

end

function rke.Waypoint(carrierSpeed,cvnVec3) -- turn Carrier to a waypoint function, get in correctly fomratted speeds in knots 
	notify("Escort changing course and speed",5) --prints some crap out the carrier is changing
	local _groupVec3 = Group.getByName(rke.carrierName):getUnit(1):getPoint() --gets a vec3 where the carrier actually is
	local path = {} --build the waypoint to, from for the unit
	path[#path + 1] = mist.ground.buildWP (_groupVec3, nil, carrierSpeed*0.58) -- from vec3 note speeds are *0.58 for a crude knots to ms
    path[#path + 1] = mist.ground.buildWP (cvnVec3, nil, carrierSpeed*0.58) -- to vec3
    mist.goRoute(rke.carrierName, path) --push to carrier to make it react

end

function rke.taskFire(vec2)                                                 --Add support for cooldown 
    local group = Group.getByName(rke.carrierName)                            --User provides rounds, ammo
    local controller = group:getController()

    local fireTask = { 
        id = 'FireAtPoint', 
        params = {
        point = vec2,
        radius = rke.radius,
        expendQty = 5,
        expendQtyEnabled = true, 
        }
    } 
    controller:setTask(fireTask)                                        
end

function cvn.WindCheck() -- works out most carrier relevant information
	--Name, Tacan, ILS, Radio
	notify(cvn.carrierName .. " " .. cvn.carrierFreq .. ", Tacan " ..  cvn.carrierTacan .. ", ICLS " .. cvn.carrierICLS,20)
	--Wind heading and speed
	--get the in game wind at the carrier
	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()
	local vec3mod = mist.utils.makeVec3GL (_groupVec3)
    vec3mod.y = vec3mod.y + 10
    local carrWindVec3 = {}
    local carrWindVec3 = atmosphere.getWind(vec3mod)
	--wind heading
	local windAngle = math.atan2(carrWindVec3.z,carrWindVec3.x) * 180 / math.pi
	if windAngle < 0 then
		windAngle = windAngle + 360	
	end
	if windAngle <= 180 then
		windAngle = windAngle + 180
	else
		windAngle = windAngle - 180
	end
	if windAngle > 360 then
		windAngle = windAngle - 360
	end
	windAngle = math.floor(windAngle)

	if windAngle < 10 then					--this block turns it into 001 - 360 format 
		windAngle = "00" .. windAngle
	elseif windAngle < 100 then
		windAngle = "0" .. windAngle
	else
		windAngle = "" .. windAngle
	end

	-- wind speed average	
	local windMagKnots = math.floor(mist.vec.mag(carrWindVec3)*1.95+.05)
	
	--turbulence
	--local carrWindGustVec3 = atmosphere.getWindWithTurbulence(vec3mod)
	--local windGustMagKnots = math.floor(mist.vec.mag(carrWindGustVec3)*1.95+.05)
	
	--temp and qnh
	local t, p = atmosphere.getTemperatureAndPressure(_groupVec3)
	t = ((t - 273.15) * 9/5) +32--kelvin to deg F
	t = math.floor(t)
	pIM = p/3386 -- pressure to inches mercury
	pIM = mist.utils.round(pIM,2)

	--print result, wind heading @ speed @ gusts
	
	notify("WND " .. windAngle .. " deg at " .. windMagKnots .. " kts, temp " .. t .. " F, QNH " .. pIM .. " inHg",20)	
	
	
--Carrier heading and speed 
	local carrHeadingRad = mist.getHeading(Unit.getByName(cvn.carrierName))
	local carrHeadingRad = math.deg (carrHeadingRad) 
	local carrHeadingDeg = math.floor (carrHeadingRad)
	if carrHeadingDeg < 10 then
		carrHeadingDeg = "00" .. carrHeadingDeg
	elseif carrHeadingDeg < 100 then
		carrHeadingDeg = "0" .. carrHeadingDeg
	else
		carrHeadingDeg = "" .. carrHeadingDeg
	end
	--carrier speed
	local carrVelVec3 = Group.getByName(cvn.carrierName):getUnit(1):getVelocity()
	local carrSpd = mist.vec.mag(carrVelVec3)
	carrSpd = math.floor((carrSpd)*1.95+.05)

notify("CRS " .. carrHeadingDeg  .. " deg at " .. carrSpd .. " kts"  ,20)	


--Wind Speed down the deck
	--get wind vector carrWindVec3
	
	--get carrier vector carrVelVec3
	
	--normalise carrier vector to wind vector
	local normCarrVec = mist.vec.getUnitVec(carrVelVec3)
	--get dot product of these two vectors
	local carrWindDP = mist.vec.dp(normCarrVec,carrWindVec3) -- this is the wind velocity down the carrier heading (but inverse due to stupid DCS wind so negative means wind over deck)
	local normWindVec = mist.vec.getUnitVec(carrWindVec3)
	--get dot product of these two vectors
	local windWindDP = mist.vec.dp(normWindVec,carrVelVec3) -- this is the other way around 

	local carrAngleWindkts = -(math.floor((carrWindDP)*1.95+.05))
	local windAngleWindkts = -(math.floor((windWindDP)*1.95+.05))
	
	
	
	--magnitude of this is speed in knots?
	--do i do this again for the carrier velocity component of it's speed, or do I just add / subtract 
	--angle of this is angle of wind over deck?
	
	--print 
	notify("Wind over deck " .. carrAngleWindkts + windAngleWindkts .. " kts" ,20)

end
--[[
-- how to make the sounds files
--Start em up
	--On the flight deck; aircrews are manning up for the 20
	--10 launch.
	--The temperature is 
	--twenty
	-- plus degrees 
	--the altimeter is 
	--2
	--9
	--7
	--2 .
	--It is time for all unnecessary personel to clear the cat walks and the flight deck. All flight deck personel; get into the complete proper flight deck uniform, helmets on and buckled, sleeves rolled down, goggles down, check chalks; tie downs ;and all lose gear about the deck. Check your pockets for fod! Check all rotor clearances and prop arcs for all the go aircraft for the
	--20
	--10 launch. Start them up!
--Launch
	-- "Green light for the bau and the waist stand clear of all catapults! catwalks! and shot lines! Time to shoot those early jets! Shoot them!"
	--“Heads up on the waist! Now launching aircraft from the bau and the wasit. Stand clear of catapults, catwalks and shot lines! while we launch the ongoing aircraft! shoot them!”
	--Launch complete, launch complete.
--Recovery
	-- “MAN ALL LAUNCH AND RECOVERY STATIONS. MAN ALL LAUNCH AND RECOVERY STATIONS.”
	-- Land Aircraft
	-- Flight deck crew, green light, clear the landing area catwalks and shot lines! first aircraft approaching the initial 4 miles.
	
--Landed 
		--Recover crew, recovery crew reseat the x wire 
		--Short shift the 3 wire

--General 
			--On the flight deck we've got problems with the hole I need everyone to stow equipment
			--Plane captain on 107, plane captain on 107. Okay everybody on the flight deck, listen to me. That's everyone you too yellow shirt. If you are pointing at an aicraft that has 1 0 7 on the side, not you 3 11 idiot. https://www.youtube.com/watch?v=XhX5QIkNbGk
			-- FOD in the LA, FOD in the LA, plane captain 104 get on that now.
			
			--99! overhead! low viz calls!. 
--Crash and fires
			--Klaxon sound for a few seconds. Fire Fire Fire, Fire on the flight deck, fire on the flight deck. All hands man your battlestations. 
	
-- chop off audio EQ above 2.5k and below 400
-- echo 0.09 delay and 0.15 decay
--reverb , room 342, delay 62 , reverb 37 , damp 2. tone low 85 tone high 61 wet -1 dry 4 stereo 0
--distortion -1.1
-- pink noise generation 0.01
--brown noise
-- https://www.ibm.com/demos/live/tts-demo/self-service/home american Kevin
]]--
function cvn.mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function cvn.startemup(soundID)
	timer.scheduleFunction(cvn.startCheckOne(),soundID, timer.getTime() + 1)
	timer.scheduleFunction(cvn.startCheckTwo(),soundID, timer.getTime() + 3.9)
	timer.scheduleFunction(cvn.startTempCheck(),soundID, timer.getTime() + 4.2)
	timer.scheduleFunction(cvn.startAltOne(),soundID, timer.getTime() + 7.5)
	timer.scheduleFunction(cvn.startAltTwo(),soundID, timer.getTime() + 7.8)
	timer.scheduleFunction(cvn.startAltThree(),soundID, timer.getTime() + 8.2)
	timer.scheduleFunction(cvn.startAltFour(),soundID, timer.getTime() + 8.5)
	timer.scheduleFunction(cvn.launchLongBlock(),soundID, timer.getTime() + 9.3)
	timer.scheduleFunction(cvn.startCheckThree(),soundID, timer.getTime() + 28)
	timer.scheduleFunction(cvn.startCheckFour(),soundID, timer.getTime() + 28.7)
	timer.scheduleFunction(cvn.startEnd,soundID, timer.getTime() + 29.1)

	local timeStart = (timer.getAbsTime() + cvn.startUpTime) --81189 -- 600 seconds per ten mins
	local hoursInSeconds = (math.floor(timeStart/3600))*3600 --this is how many hours we have for our start timer in seconds
	local timeStartText = mist.getClockString(timer.getAbsTime() + cvn.startUpTime)
	local timeS = cvn.mysplit(timeStartText, ':')
	
	if tonumber(timeS[2]) < 5 then
		 minutesInSeconds = 0
	elseif tonumber(timeS[2]) < 10 then
		 minutesInSeconds = 10*60
	elseif tonumber(timeS[2]) < 15 then
		 minutesInSeconds = 10*60
	elseif tonumber(timeS[2]) < 20 then
		 minutesInSeconds = 20*60
	elseif tonumber(timeS[2]) < 25 then
		 minutesInSeconds = 20*60
	elseif tonumber(timeS[2]) < 30 then
		 minutesInSeconds = 30*60
	elseif tonumber(timeS[2]) < 35 then
		minutesInSeconds = 30*60
	elseif tonumber(timeS[2]) < 40 then
		minutesInSeconds = 40*60
	elseif tonumber(timeS[2]) < 45 then
		minutesInSeconds = 40*60
	elseif tonumber(timeS[2]) < 50 then
		minutesInSeconds = 50*60
	elseif tonumber(timeS[2]) < 55 then
		minutesInSeconds = 50*60
	elseif tonumber(timeS[2]) < 60 then
		minutesInSeconds = 0
		hoursInSeconds = hoursInSeconds + 3600
	else
		minutesInSeconds = 0
		hoursInSeconds = hoursInSeconds + 3600
	end
	timer.scheduleFunction(cvn.launchAircraft,soundID,(hoursInSeconds+minutesInSeconds)-timer.getAbsTime())
end

function cvn.launchLongBlock()

	fnName = cvn.startMain
	return fnName
end

function cvn.startCheckOne()
	local timeStart = mist.getClockString(timer.getAbsTime() + cvn.startUpTime)
	local timeS = cvn.mysplit(timeStart, ':')
	
	
	
	if (tonumber(timeS[2]) < 60) and (tonumber(timeS[2]) > 55) then

		if timeS[1] == "00" then
			timeS[1] = "01"
		elseif timeS[1] == "01" then
			timeS[1] = "02"
		elseif timeS[1] == "02" then
			timeS[1] = "03"
		elseif timeS[1] == "03" then
			timeS[1] = "04"
		elseif timeS[1] == "04" then
			timeS[1] = "05"
		elseif timeS[1] == "05" then
			timeS[1] = "06"
		elseif timeS[1] == "06" then
			timeS[1] = "07"
		elseif timeS[1] == "07" then
			timeS[1] = "08"
		elseif timeS[1] == "08" then
			timeS[1] = "09"
		elseif timeS[1] == "09" then
			timeS[1] = "10"
		elseif timeS[1] == "10" then
			timeS[1] = "11"
		elseif timeS[1] == "11" then
			timeS[1] = "12"
		elseif timeS[1] == "12" then
			timeS[1] = "13"
		elseif timeS[1] == "13" then
			timeS[1] = "14"
		elseif timeS[1] == "14" then
			timeS[1] = "15"
		elseif timeS[1] == "15" then
			timeS[1] = "16"
		elseif timeS[1] == "16" then
			timeS[1] = "17"
		elseif timeS[1] == "17" then
			timeS[1] = "18"
		elseif timeS[1] == "18" then
			timeS[1] = "19"
		elseif timeS[1] == "19" then
			timeS[1] = "20"
		elseif timeS[1] == "20" then
			timeS[1] = "21"
		elseif timeS[1] == "21" then
			timeS[1] = "22"
		elseif timeS[1] == "22" then
			timeS[1] = "23"
		elseif timeS[1] == "23" then
			timeS[1] = "00"
		else
		end
	end
	
	if timeS[1] == "00" then
		fnName = cvn.launchZero
	elseif timeS[1] == "01" then
		fnName = cvn.launchOne
	elseif timeS[1] == "02" then
		fnName = cvn.launchTwo
	elseif timeS[1] == "03" then
		fnName = cvn.launchThree
	elseif timeS[1] == "04" then
		fnName = cvn.launchFour
	elseif timeS[1] == "05" then
		fnName = cvn.launchFive
	elseif timeS[1] == "06" then
		fnName = cvn.launchSix
	elseif timeS[1] == "07" then
		fnName = cvn.launchSeven
	elseif timeS[1] == "08" then
		fnName = cvn.launchEight
	elseif timeS[1] == "09" then
		fnName = cvn.launchNine
	elseif timeS[1] == "10" then
		fnName = cvn.launchTen
	elseif timeS[1] == "11" then
		fnName = cvn.launchEleven
	elseif timeS[1] == "12" then
		fnName = cvn.launchTwelve
	elseif timeS[1] == "13" then
		fnName = cvn.launchThirteen
	elseif timeS[1] == "14" then
		fnName = cvn.launchFourteen
	elseif timeS[1] == "15" then
		fnName = cvn.launchFifteen
	elseif timeS[1] == "16" then
		fnName = cvn.launchSixteen
	elseif timeS[1] == "17" then
		fnName = cvn.launchSeventeen
	elseif timeS[1] == "18" then
		fnName = cvn.launchEightteen
	elseif timeS[1] == "19" then
		fnName = cvn.launchNineteen
	elseif timeS[1] == "20" then
		fnName = cvn.launchTwenty
	elseif timeS[1] == "21" then
		fnName = cvn.launchTwentyOne
	elseif timeS[1] == "22" then
		fnName = cvn.launchTwentyTwo
	elseif timeS[1] == "23" then
		fnName = cvn.launchTwentyThree
	else
	end
	
	return fnName
end

function cvn.startCheckTwo()
	local timeStart = mist.getClockString(timer.getAbsTime() + cvn.startUpTime)
	local timeS = cvn.mysplit(timeStart, ':')
	
	if (tonumber(timeS[2]) < 60) and (tonumber(timeS[2]) > 55) then
		timeStart = mist.getClockString(timer.getAbsTime() + cvn.startUpTime+3600)
		local timeS = cvn.mysplit(timeStart, ':')
	end
	
	
	if tonumber(timeS[2]) < 5 then
		fnName = cvn.Hundred
	notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":00 launch" ,20)
	elseif tonumber(timeS[2]) < 10 then
		fnName = cvn.Ten
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":10 launch" ,20)
	elseif tonumber(timeS[2]) < 15 then
		fnName = cvn.Ten
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":10 launch" ,20)
	elseif tonumber(timeS[2]) < 20 then
		fnName = cvn.Twenty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":20 launch" ,20)
	elseif tonumber(timeS[2]) < 25 then
		fnName = cvn.Twenty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":20 launch" ,20)
	elseif tonumber(timeS[2]) < 30 then
		fnName = cvn.Thirty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":30 launch" ,20)
	elseif tonumber(timeS[2]) < 35 then
		fnName = cvn.Thirty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":30 launch" ,20)
	elseif tonumber(timeS[2]) < 40 then
		fnName = cvn.Forty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":40 launch" ,20)
	elseif tonumber(timeS[2]) < 45 then
		fnName = cvn.Forty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":40 launch" ,20)
	elseif tonumber(timeS[2]) < 50 then
		fnName = cvn.Fifty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":50 launch" ,20)
	elseif tonumber(timeS[2]) < 55 then
		fnName = cvn.Fifty
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":50 launch" ,20)
	elseif tonumber(timeS[2]) < 60 then
		fnName = cvn.Hundred
		notify("Start up all aircraft on carrier for the " .. timeS[1] .. ":00 launch" ,20)
	else
	end

	return fnName
end

function cvn.startCheckThree()
	local timeStart = mist.getClockString(timer.getAbsTime() + cvn.startUpTime)
	local timeS = cvn.mysplit(timeStart, ':')
	
	if (tonumber(timeS[2]) < 60) and (tonumber(timeS[2]) > 55) then
		if timeS[1] == "00" then
			timeS[1] = "01"
		elseif timeS[1] == "01" then
			timeS[1] = "02"
		elseif timeS[1] == "02" then
			timeS[1] = "03"
		elseif timeS[1] == "03" then
			timeS[1] = "04"
		elseif timeS[1] == "04" then
			timeS[1] = "05"
		elseif timeS[1] == "05" then
			timeS[1] = "06"
		elseif timeS[1] == "06" then
			timeS[1] = "07"
		elseif timeS[1] == "07" then
			timeS[1] = "08"
		elseif timeS[1] == "08" then
			timeS[1] = "09"
		elseif timeS[1] == "09" then
			timeS[1] = "10"
		elseif timeS[1] == "10" then
			timeS[1] = "11"
		elseif timeS[1] == "11" then
			timeS[1] = "12"
		elseif timeS[1] == "12" then
			timeS[1] = "13"
		elseif timeS[1] == "13" then
			timeS[1] = "14"
		elseif timeS[1] == "14" then
			timeS[1] = "15"
		elseif timeS[1] == "15" then
			timeS[1] = "16"
		elseif timeS[1] == "16" then
			timeS[1] = "17"
		elseif timeS[1] == "17" then
			timeS[1] = "18"
		elseif timeS[1] == "18" then
			timeS[1] = "19"
		elseif timeS[1] == "19" then
			timeS[1] = "20"
		elseif timeS[1] == "20" then
			timeS[1] = "21"
		elseif timeS[1] == "21" then
			timeS[1] = "22"
		elseif timeS[1] == "22" then
			timeS[1] = "23"
		elseif timeS[1] == "23" then
			timeS[1] = "00"
		else
		end
	end
	
	
	
	if timeS[1] == "00" then
		fnName = cvn.zero
	elseif timeS[1] == "01" then
		fnName = cvn.one
	elseif timeS[1] == "02" then
		fnName = cvn.two
	elseif timeS[1] == "03" then
		fnName = cvn.three
	elseif timeS[1] == "04" then
		fnName = cvn.four
	elseif timeS[1] == "05" then
		fnName = cvn.five
	elseif timeS[1] == "06" then
		fnName = cvn.six
	elseif timeS[1] == "07" then
		fnName = cvn.seven
	elseif timeS[1] == "08" then
		fnName = cvn.eight
	elseif timeS[1] == "09" then
		fnName = cvn.nine
	elseif timeS[1] == "10" then
		fnName = cvn.ten
	elseif timeS[1] == "11" then
		fnName = cvn.eleven
	elseif timeS[1] == "12" then
		fnName = cvn.twelve
	elseif timeS[1] == "13" then
		fnName = cvn.thirteen
	elseif timeS[1] == "14" then
		fnName = cvn.fourteen
	elseif timeS[1] == "15" then
		fnName = cvn.fifteen
	elseif timeS[1] == "16" then
		fnName = cvn.sixteen
	elseif timeS[1] == "17" then
		fnName = cvn.seventeen
	elseif timeS[1] == "18" then
		fnName = cvn.eightteen
	elseif timeS[1] == "19" then
		fnName = cvn.nineteen
	elseif timeS[1] == "20" then
		fnName = cvn.twenty
	elseif timeS[1] == "21" then
		fnName = cvn.twentyOne
	elseif timeS[1] == "22" then
		fnName = cvn.twentyTwo
	elseif timeS[1] == "23" then
		fnName = cvn.twentyThree
	else
	end
	
	return fnName
end

function cvn.startCheckFour()
	local timeStart = mist.getClockString(timer.getAbsTime() + cvn.startUpTime)
	local timeS = cvn.mysplit(timeStart, ':')
	
	if tonumber(timeS[2]) < 5 then
		fnName = cvn.Hundred
	elseif tonumber(timeS[2]) < 10 then
		fnName = cvn.Ten
	elseif tonumber(timeS[2]) < 15 then
		fnName = cvn.Ten
	elseif tonumber(timeS[2]) < 20 then
		fnName = cvn.Twenty
	elseif tonumber(timeS[2]) < 25 then
		fnName = cvn.Twenty
	elseif tonumber(timeS[2]) < 30 then
		fnName = cvn.Thirty
	elseif tonumber(timeS[2]) < 35 then
		fnName = cvn.Thirty
	elseif tonumber(timeS[2]) < 40 then
		fnName = cvn.Forty
	elseif tonumber(timeS[2]) < 45 then
		fnName = cvn.Forty
	elseif tonumber(timeS[2]) < 50 then
		fnName = cvn.Fifty
	elseif tonumber(timeS[2]) < 55 then
		fnName = cvn.Fifty
	elseif tonumber(timeS[2]) < 60 then
		fnName = cvn.Hundred
	else
	end

	return fnName
end

function cvn.startTempCheck()
	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()
	local t, p = atmosphere.getTemperatureAndPressure(_groupVec3)
	temp = ((t - 273.15) * 9/5) +32--kelvin to deg F
	if temp < 10 then
		fnName = cvn.tempZero
	elseif temp < 20 then
		fnName = cvn.tempTen
	elseif temp < 30 then
		fnName = cvn.tempTwenty
	elseif temp < 40 then
		fnName = cvn.tempThirty
	elseif temp < 50 then
		fnName = cvn.tempForty
	elseif temp < 60 then
		fnName = cvn.tempFifty
	elseif temp < 70 then
		fnName = cvn.tempSixty
	elseif temp < 80 then
		fnName = cvn.tempSeventy
	elseif temp < 90 then
		fnName = cvn.tempEighty
	elseif temp < 100 then
		fnName = cvn.tempNinety
	elseif temp < 110 then
		fnName = cvn.tempOneHundred
	elseif temp < 120 then
		fnName = cvn.tempOneTen
	elseif temp < 130 then
		fnName = cvn.tempOneTwenty
	elseif temp < 140 then
		fnName = cvn.tempOneThirty
	elseif temp < 150 then
		fnName = cvn.tempOneForty
	else
		fnName = cvn.tempEighty
	end
	return fnName
end

function cvn.startAltOne()
	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()
	local t, p = atmosphere.getTemperatureAndPressure(_groupVec3)
	local pIM = p/3386 -- pressure to inches mercury
	pIM = mist.utils.round(pIM,2)*100
	local a = math.floor(pIM/10000)*10000
	local b = math.floor((pIM - a)/1000)
	
	if b == 0 then
		fnName = cvn.zero
	elseif b == 1 then
		fnName = cvn.one
	elseif b == 2 then
		fnName = cvn.two
	elseif b == 3 then
		fnName = cvn.three
	elseif b == 4 then
		fnName = cvn.four
	elseif b == 5 then
		fnName = cvn.five
	elseif b == 6 then
		fnName = cvn.six
	elseif b == 7 then
		fnName = cvn.seven
	elseif b == 8 then
		fnName = cvn.eight
	else
		fnName = cvn.niner
	end

	return fnName
end

function cvn.startAltTwo()
	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()
	local t, p = atmosphere.getTemperatureAndPressure(_groupVec3)
	local pIM = p/3386 -- pressure to inches mercury
	pIM = mist.utils.round(pIM,2)*100 --2896
	local a = math.floor(pIM/1000)*1000 -- 2000
	local b = math.floor((pIM - a)/100)
	
	if b == 0 then
		fnName = cvn.zero
	elseif b == 1 then
		fnName = cvn.one
	elseif b == 2 then
		fnName = cvn.two
	elseif b == 3 then
		fnName = cvn.three
	elseif b == 4 then
		fnName = cvn.four
	elseif b == 5 then
		fnName = cvn.five
	elseif b == 6 then
		fnName = cvn.six
	elseif b == 7 then
		fnName = cvn.seven
	elseif b == 8 then
		fnName = cvn.eight
	else
		fnName = cvn.niner
	end

	return fnName
end

function cvn.startAltThree()
	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()
	local t, p = atmosphere.getTemperatureAndPressure(_groupVec3)
	local pIM = p/3386 -- pressure to inches mercury
	pIM = mist.utils.round(pIM,2)*100 --2896
	local a = math.floor(pIM/1000)*1000 --2000 
	local b = math.floor((pIM - a)/100) --
	local c = math.floor((pIM -a - (b*100))/10)
	b=c
	if b == 0 then
		fnName = cvn.zero
	elseif b == 1 then
		fnName = cvn.one
	elseif b == 2 then
		fnName = cvn.two
	elseif b == 3 then
		fnName = cvn.three
	elseif b == 4 then
		fnName = cvn.four
	elseif b == 5 then
		fnName = cvn.five
	elseif b == 6 then
		fnName = cvn.six
	elseif b == 7 then
		fnName = cvn.seven
	elseif b == 8 then
		fnName = cvn.eight
	else
		fnName = cvn.niner
	end

	return fnName
end

function cvn.startAltFour()

	local _groupVec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()
	local t, p = atmosphere.getTemperatureAndPressure(_groupVec3)
	local pIM = p/3386 -- pressure to inches mercury
	pIM = mist.utils.round(pIM,2)*100 --2896
	local a = math.floor(pIM/1000)*1000 --2000 
	local b = math.floor((pIM - a)/100) --
	local c = math.floor((pIM -a - (b*100))/10)
	local d = math.floor(pIM - a - (b*100) - (c*10)) 
	b=d
	if b == 0 then
		fnName = cvn.zero
	elseif b == 1 then
		fnName = cvn.one
	elseif b == 2 then
		fnName = cvn.two
	elseif b == 3 then
		fnName = cvn.three
	elseif b == 4 then
		fnName = cvn.four
	elseif b == 5 then
		fnName = cvn.five
	elseif b == 6 then
		fnName = cvn.six
	elseif b == 7 then
		fnName = cvn.seven
	elseif b == 8 then
		fnName = cvn.eight
	else
		fnName = cvn.niner
	end

	return fnName
end

function cvn.recoveryMessage()
	local currentTimeAbs = mist.getClockString(timer.getAbsTime())
	local nowTime = cvn.mysplit(currentTimeAbs, ':')
	local currentTime = mist.getClockString(timer.getAbsTime()+cvn.landWindowTime)
	local times = cvn.mysplit(currentTime, ':')
	trigger.action.radioTransmission("l10n/DEFAULT/tankstates.ogg", trigger.misc.getZone("radio").point, radio.modulation.AM, false, 127500000, 200, "radio1")
	notify("Next recovery window starts at " .. times[1] .. ":" .. times[2],120)
	notify("Current time " .. nowTime[1] .. ":" .. nowTime[2],20)
end

function cvn.setrecoverycycle(soundID)
	notify("Prepare to recover aircraft" ,20)
	timer.scheduleFunction(cvn.recoverman,soundID, timer.getTime() + 60)
	timer.scheduleFunction(cvn.recoverinitial,soundID, timer.getTime() + 780)
	timer.scheduleFunction(cvn.recoverland,soundID, timer.getTime() + 830)
end

--start em up main block

function cvn.startMain(unitID)
		trigger.action.outSoundForGroup(unitID, "start-main.ogg")
end

function cvn.launchAircraft(unitID)
		trigger.action.outSoundForGroup(unitID, "launch.ogg")
end

--start launch aircraft bow and wasit

function cvn.startEnd(unitID)
		trigger.action.outSoundForGroup(unitID, "start-end.ogg")
end

--this block is the sound functions for the tens
function cvn.Zero(unitID)
		trigger.action.outSoundForGroup(unitID, "0.ogg")
end
function cvn.Ten(unitID)
		trigger.action.outSoundForGroup(unitID, "10.ogg")
end
function cvn.Twenty(unitID)
		trigger.action.outSoundForGroup(unitID, "20.ogg")
end
function cvn.Thirty(unitID)
		trigger.action.outSoundForGroup(unitID, "30.ogg")
end
function cvn.Forty(unitID)
		trigger.action.outSoundForGroup(unitID, "40.ogg")
end
function cvn.Fifty(unitID)
		trigger.action.outSoundForGroup(unitID, "50.ogg")
end
function cvn.Sixty(unitID)
		trigger.action.outSoundForGroup(unitID, "60.ogg")
end
function cvn.Seventy(unitID)
		trigger.action.outSoundForGroup(unitID, "70.ogg")
end
function cvn.Eighty(unitID)
		trigger.action.outSoundForGroup(unitID, "80.ogg")
end
function cvn.Ninety(unitID)
		trigger.action.outSoundForGroup(unitID, "90.ogg")
end
function cvn.OneHundred(unitID)
		trigger.action.outSoundForGroup(unitID, "100.ogg")
end
function cvn.Hundred(unitID)
		trigger.action.outSoundForGroup(unitID, "hundred.ogg")
end

--this block is the sound functions for start them up
function cvn.launchZero(unitID)
		trigger.action.outSoundForGroup(unitID, "launch0.ogg")
end
function cvn.launchOne(unitID)
		trigger.action.outSoundForGroup(unitID, "launch1.ogg")
end
function cvn.launchTwo(unitID)
		trigger.action.outSoundForGroup(unitID, "launch2.ogg")
end
function cvn.launchThree(unitID)
		trigger.action.outSoundForGroup(unitID, "launch3.ogg")
end
function cvn.launchFour(unitID)
		trigger.action.outSoundForGroup(unitID, "launch4.ogg")
end
function cvn.launchFive(unitID)
		trigger.action.outSoundForGroup(unitID, "launch5.ogg")
end
function cvn.launchSix(unitID)
		trigger.action.outSoundForGroup(unitID, "launch6.ogg")
end
function cvn.launchSeven(unitID)
		trigger.action.outSoundForGroup(unitID, "launch7.ogg")
end
function cvn.launchEight(unitID)
		trigger.action.outSoundForGroup(unitID, "launch8.ogg")
end
function cvn.launchNine(unitID)
		trigger.action.outSoundForGroup(unitID, "launch9.ogg")
end
function cvn.launchTen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch10.ogg")
end
function cvn.launchEleven(unitID)
		trigger.action.outSoundForGroup(unitID, "launch11.ogg")
end
function cvn.launchTwelve(unitID)
		trigger.action.outSoundForGroup(unitID, "launch12.ogg")
end
function cvn.launchThirteen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch13.ogg")
end
function cvn.launchFourteen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch14.ogg")
end
function cvn.launchFifteen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch15.ogg")
end
function cvn.launchSixteen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch16.ogg")
end
function cvn.launchSeventeen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch17.ogg")
end
function cvn.launchEightteen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch18.ogg")
end
function cvn.launchNineteen(unitID)
		trigger.action.outSoundForGroup(unitID, "launch19.ogg")
end
function cvn.launchTwenty(unitID)
		trigger.action.outSoundForGroup(unitID, "launch20.ogg")
end
function cvn.launchTwentyOne(unitID)
		trigger.action.outSoundForGroup(unitID, "launch21.ogg")
end
function cvn.launchTwentyTwo(unitID)
		trigger.action.outSoundForGroup(unitID, "launch22.ogg")
end
function cvn.launchTwentyThree(unitID)
		trigger.action.outSoundForGroup(unitID, "launch23.ogg")
end

----this section is for temperatures during start me up


function cvn.tempZero(unitID)
	trigger.action.outSoundForGroup(unitID, "0f.ogg")
end
function cvn.tempTen(unitID)
	trigger.action.outSoundForGroup(unitID, "10f.ogg")
end
function cvn.tempTwenty(unitID)
	trigger.action.outSoundForGroup(unitID, "20f.ogg")
end
function cvn.tempThirty(unitID)
	trigger.action.outSoundForGroup(unitID, "30f.ogg")
end
function cvn.tempForty(unitID)
	trigger.action.outSoundForGroup(unitID, "40f.ogg")
end
function cvn.tempFifty(unitID)
	trigger.action.outSoundForGroup(unitID, "50f.ogg")
end
function cvn.tempSixty(unitID)
	trigger.action.outSoundForGroup(unitID, "60f.ogg")
end
function cvn.tempSeventy(unitID)
	trigger.action.outSoundForGroup(unitID, "70f.ogg")
end
function cvn.tempEighty(unitID)
	trigger.action.outSoundForGroup(unitID, "80f.ogg")
end
function cvn.tempNinety(unitID)
	trigger.action.outSoundForGroup(unitID, "90f.ogg")
end
function cvn.tempOneHundred(unitID)
	trigger.action.outSoundForGroup(unitID, "100f.ogg")
end
function cvn.tempOneTen(unitID)
	trigger.action.outSoundForGroup(unitID, "110f.ogg")
end
function cvn.tempOneTwenty(unitID)
	trigger.action.outSoundForGroup(unitID, "120f.ogg")
end
function cvn.tempOneThirty(unitID)
	trigger.action.outSoundForGroup(unitID, "130f.ogg")
end
function cvn.tempOneForty(unitID)
	trigger.action.outSoundForGroup(unitID, "140f.ogg")
end

--this is for number measurements 
function cvn.zero(unitID)
	trigger.action.outSoundForGroup(unitID, "0.ogg")
end
function cvn.one(unitID)
	trigger.action.outSoundForGroup(unitID, "1.ogg")
end
function cvn.two(unitID)
	trigger.action.outSoundForGroup(unitID, "2.ogg")
end
function cvn.three(unitID)
	trigger.action.outSoundForGroup(unitID, "3.ogg")
end
function cvn.four(unitID)
	trigger.action.outSoundForGroup(unitID, "4.ogg")
end
function cvn.five(unitID)
	trigger.action.outSoundForGroup(unitID, "5.ogg")
end
function cvn.six(unitID)
	trigger.action.outSoundForGroup(unitID, "6.ogg")
end
function cvn.seven(unitID)
	trigger.action.outSoundForGroup(unitID, "7.ogg")
end
function cvn.eight(unitID)
	trigger.action.outSoundForGroup(unitID, "8.ogg")
end
function cvn.nine(unitID)
	trigger.action.outSoundForGroup(unitID, "9.ogg")
end
function cvn.niner(unitID)
	trigger.action.outSoundForGroup(unitID, "9er.ogg")
end
function cvn.ten(unitID)
	trigger.action.outSoundForGroup(unitID, "10.ogg")
end
function cvn.eleven(unitID)
	trigger.action.outSoundForGroup(unitID, "11.ogg")
end
function cvn.twelve(unitID)
	trigger.action.outSoundForGroup(unitID, "12.ogg")
end
function cvn.thirteen(unitID)
	trigger.action.outSoundForGroup(unitID, "13.ogg")
end
function cvn.fourteen(unitID)
	trigger.action.outSoundForGroup(unitID, "14.ogg")
end
function cvn.fifteen(unitID)
	trigger.action.outSoundForGroup(unitID, "15.ogg")
end
function cvn.sixteen(unitID)
	trigger.action.outSoundForGroup(unitID, "16.ogg")
end
function cvn.seventeen(unitID)
	trigger.action.outSoundForGroup(unitID, "17.ogg")
end
function cvn.eightteen(unitID)
	trigger.action.outSoundForGroup(unitID, "18.ogg")
end
function cvn.nineteen(unitID)
	trigger.action.outSoundForGroup(unitID, "19.ogg")
end
function cvn.twenty(unitID)
	trigger.action.outSoundForGroup(unitID, "20.ogg")
end
function cvn.twentyOne(unitID)
	trigger.action.outSoundForGroup(unitID, "21.ogg")
end
function cvn.twentyTwo(unitID)
	trigger.action.outSoundForGroup(unitID, "22.ogg")
end
function cvn.twentyThree(unitID)
	trigger.action.outSoundForGroup(unitID, "23.ogg")
end

--this block is for the recovery sound files 

function cvn.recoverman(unitID)
		trigger.action.outSoundForGroup(unitID, "recover-man-rec-launch.ogg")
end

function cvn.recoverland(unitID)
		trigger.action.outSoundForGroup(unitID, "recover-land.ogg")
end

function cvn.recoverinitial(unitID)
		trigger.action.outSoundForGroup(unitID, "recover-initial.ogg")
end

function cvn.lowvis(unitID)
		trigger.action.outSoundForGroup(unitID, "low-vis.ogg")
end

--this block is for carrier turns and ambience
function cvn.port(unitID)
		trigger.action.outSoundForGroup(unitID, "port.ogg")
end

function cvn.starboard(unitID)
		trigger.action.outSoundForGroup(unitID, "starboard.ogg")
end

function cvn.fire(unitID)
		trigger.action.outSoundForGroup(unitID, "fire.ogg")
end

function cvn.klaxon(unitID)
		trigger.action.outSoundForGroup(unitID, "klaxon.ogg")
end

function cvn.gogglesSound(unitID)
		trigger.action.outSoundForGroup(unitID, "goggles.ogg")
end

function cvn.lowvis(unitID)
		trigger.action.outSoundForGroup(unitID, "low-vis.ogg")
end

-------end of the sound files 

function cvn.turnPort ()
	cvn.unitsInZone = mist.getUnitsInMovingZones(mist.makeUnitTable({'[blue][plane]'}),mist.makeUnitTable({'[g]CVN-71 Theodore Roosevelt'}),150,'sphere')
	 
	 for i = 1, #cvn.unitsInZone do
        _unit = cvn.unitsInZone[i]
        _group = _unit:getGroup()

        if _group == nil then
            break
        end
	soundID = _group:getID()
	timer.scheduleFunction(cvn.port,soundID, timer.getTime() + 1)
	end
	 
end
function cvn.turnStarboard ()
	cvn.unitsInZone = mist.getUnitsInMovingZones(mist.makeUnitTable({'[blue][plane]'}),mist.makeUnitTable({'[g]CVN-71 Theodore Roosevelt'}),150,'sphere')
	 
	 for i = 1, #cvn.unitsInZone do
        _unit = cvn.unitsInZone[i]
        _group = _unit:getGroup()

        if _group == nil then
            break
        end
	soundID = _group:getID()
	timer.scheduleFunction(cvn.starboard,soundID, timer.getTime() + 1)
	end
	 
end

--this section is for the things that can actually be called up via the f10 menu options, which get everyone currently on the deck in the zone and then fires off stuff to all of them in a loop so they all hear the same shit

function cvn.start ()
	cvn.unitsInZone = mist.getUnitsInMovingZones(mist.makeUnitTable({'[blue][plane]'}),mist.makeUnitTable({'[g]CVN-71 Theodore Roosevelt'}),150,'sphere')
	 
	 for i = 1, #cvn.unitsInZone do
        _unit = cvn.unitsInZone[i]
        _group = _unit:getGroup()

        if _group == nil then
            break
        end
	soundID = _group:getID()	
	timer.scheduleFunction(cvn.startemup,soundID, timer.getTime() + 1)
	end
	 
end

function cvn.recoverPlanes ()
	cvn.unitsInZone = mist.getUnitsInMovingZones(mist.makeUnitTable({'[blue][plane]'}),mist.makeUnitTable({'[g]CVN-71 Theodore Roosevelt'}),150,'sphere')
	cvn.recoveryMessage() 
	 for i = 1, #cvn.unitsInZone do
        _unit = cvn.unitsInZone[i]
        _group = _unit:getGroup()

        if _group == nil then
            break
        end
	soundID = _group:getID()
	timer.scheduleFunction(cvn.setrecoverycycle,soundID, timer.getTime() + 10)
	end
	 
end

function cvn.googles ()
	cvn.unitsInZone = mist.getUnitsInMovingZones(mist.makeUnitTable({'[blue][plane]'}),mist.makeUnitTable({'[g]CVN-71 Theodore Roosevelt'}),150,'sphere')
	 for i = 1, #cvn.unitsInZone do
        _unit = cvn.unitsInZone[i]
        _group = _unit:getGroup()

        if _group == nil then
            break
        end
	soundID = _group:getID()
	timer.scheduleFunction(cvn.gogglesSound,soundID, timer.getTime() + 1)
	end
	 
end
--this block is the sound functions for easter eggs
function roundNumber(num, idp)                                              -- From http://lua-users.org/wiki/SimpleRound
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

cvn.LLtool = {}
cvn.LLtool.LLstrings = function(pos) -- pos is a Vec3
local LLposN, LLposE = coord.LOtoLL(pos)
local LLposfixN, LLposdegN = math.modf(LLposN)
LLposdegN = LLposdegN * 60
local LLposdegN2, LLposdegN3 = math.modf(LLposdegN)
LLposdegN3 = LLposdegN3 * 60
local LLposfixE, LLposdegE = math.modf(LLposE)
LLposdegE = LLposdegE * 60
local LLposdegE2, LLposdegE3 = math.modf(LLposdegE)
LLposdegE3 = LLposdegE3 * 60
local LLposNstring = string.format('%.2i° %.2i\' %.3d\"', LLposfixN, LLposdegN2, LLposdegN3)
local LLposEstring = string.format('%.3i° %.2i\' %.3d\"', LLposfixE, LLposdegE2, LLposdegE3)
return LLposNstring, LLposEstring
/2222
end

function cvn.location()
	
   local vec3 = Group.getByName(cvn.carrierName):getUnit(1):getPoint()	
   LLposNstring, LLposEstring = cvn.LLtool.LLstrings(vec3)    
   notify('Carrier position N ' .. LLposNstring .. '   E ' .. LLposEstring, 20)

end

do
    radioSubMenu = missionCommands.addSubMenu ("Carrier Commands")
    radioWindOverDeckCheck = missionCommands.addCommand ("CVN Status Info", radioSubMenu, cvn.WindCheck)
	radioWindOverDeckCheck = missionCommands.addCommand ("CVN Position Info", radioSubMenu, cvn.location)
	radioWindOverDeckCheck = missionCommands.addCommand ("Start em up", radioSubMenu, cvn.start)
	radioWindOverDeckCheck = missionCommands.addCommand ("Start recovery cycle", radioSubMenu, cvn.recoverPlanes)
	
end

