    --  Name:                           CYC_zeus.lua
    --  Author:                         Tony
	-- assert(loadfile('C:\\Users\\hindsas\\Saved Games\\DCS.openbeta\\Missions\\Vietstan92\\Lua\\CYC_sickAItrainer.lua'))()
    --  Dependencies:                   Mist.lua, CYC_do.lua
    --  Description:
    --      Creates firefights on the ground between units on the ground and enemy to replicate modern firefights, adds in jtac style 9 line (simplified) to hit units until the fight is over, enemy withdraws etc
    --  Usage:
    --      1. 
	
--[[List of outstanding work to do

-- 1. 
	2. aircraft
	3. liveries
	4. everything to dyn add table
	5. units get named specifically b or r 1,2,3 etc
	6. a list of tables that store which units exist and means the numbers dont get too hight
	7. unit specific notify
	11. set coniditon of unit
	12. enable combined arms? spawnable player can drive
	13. KC 135 Tanker
	14. moveable helicopters - land 

]]--
gnd = {}
gnd.delimiter = "." -- this is the thing we use to delimit commands
radio = {}
gnd.laserTable = {}
gnd.laserCounter = 1
gnd.thisStore = ""
gnd.unitCounterBlue = 1
gnd.factionNameBlue = "bg"
gnd.unitCounterRed = 1
gnd.factionNameRed = "rg"

function gnd.mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

----------------
----------------
--This section is the new completed functions, which work with any unit and delimiter

----------------
----------------
do
    redIADS = SkynetIADS:create('Red')
	redIADS:activate()
end


function gnd.unitSpawner (text,pointVec3Gl) 
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
	
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------	
-----------------START OF BLUE REGULAR FORCES-------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

	if unitInfo[1] == "btank" then
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
				
		local unitType = "M-1 Abrams"
		local liv = "desert"
		countryType = "USA"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "M-1 Abrams"
			countryType = "USA"
		elseif unitInfo[3] == "2" then
			unitType = "Challenger2"
			countryType = "CJTF Red"
		elseif unitInfo[3] == "3" then
			unitType = "Leclerc"
			countryType = "CJTF Red"		
		elseif unitInfo[3] == "4" then
			unitType = "Leopard-2"
			countryType = "CJTF Red"
		elseif unitInfo[3] == "5" then
			unitType = "Merkava_Mk4"
			countryType = "CJTF Red"	
		elseif unitInfo[3] == "6" then
			unitType = "M-60"
			countryType = "CJTF Red"
		else

		end
		
		
								mist.dynAdd(
							{
								country = countryType,
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
			
			
			
	elseif unitInfo[1] == "bapc" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "AAV7"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "AAV7"
		elseif unitInfo[3] == "2" then
			unitType = "M1126 Stryker ICV"
		elseif unitInfo[3] == "3" then
			unitType = "M-113"		
		elseif unitInfo[3] == "4" then
			unitType = "M-113"		
			liv = "desert_MED"
		elseif unitInfo[3] == "5" then
			unitType = "M1134 Stryker ATGM"		
		elseif unitInfo[3] == "6" then
			unitType = "LAV-25"		
		elseif unitInfo[3] == "7" then
			unitType = "M-2 Bradley"		
		elseif unitInfo[3] == "8" then
			unitType = "M1128 Stryker MGS"		
		elseif unitInfo[3] == "9" then
			unitType = "TPZ"
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
			
	elseif unitInfo[1] == "bcar" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "M1043 HMMWV Armament"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "M1043 HMMWV Armament"
		elseif unitInfo[3] == "2" then
			unitType = "M1045 HMMWV TOW"
		elseif unitInfo[3] == "3" then
			unitType = "Hummer"		
		elseif unitInfo[3] == "4" then
			unitType = "M 818"		
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
	
	elseif unitInfo[1] == "bconvoy" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "M1043 HMMWV Armament"
		local liv = "desert"
		
		if unitInfo[3] == nil then
		mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "M 818",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "M 818",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterBlue = gnd.unitCounterBlue + 1

		
		
		elseif unitInfo[3] == "1" then
			mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "M 818",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "M 818",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterBlue = gnd.unitCounterBlue + 1

		
		
		elseif unitInfo[3] == "2" then
			mist.dynAdd(
							{
								country = 'CJTF Red',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "M1126 Stryker ICV",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "M1134 Stryker ATGM",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "M1043 HMMWV Armament",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "M1126 Stryker ICV",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterBlue = gnd.unitCounterBlue + 1

		
		
		elseif unitInfo[3] == "3" then
			mist.dynAdd(
							{
								country = 'CJTF Red',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "MCV-80",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "MCV-80",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "MCV-80",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "Leclerc",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "M6 Linebacker",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "M-2 Bradley",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterBlue = gnd.unitCounterBlue + 1

		
			
		elseif unitInfo[3] == "4" then
			mist.dynAdd(
							{
								country = 'CJTF Red',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "M-1 Abrams",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "M-1 Abrams",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "M-1 Abrams",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "M-1 Abrams",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "M6 Linebacker",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "M-1 Abrams",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterBlue = gnd.unitCounterBlue + 1

		end
						
	elseif unitInfo[1] == "bciv" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Land_Rover_109_S3"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "Land_Rover_109_S3"
		elseif unitInfo[3] == "2" then
			unitType = "Ural ATsP-6"
		elseif unitInfo[3] == "3" then
			unitType = "M978 HEMTT Tanker"
		elseif unitInfo[3] == "4" then
			unitType = "VAZ Car"		
		elseif unitInfo[3] == "5" then
			unitType = "MAZ-6303"	
		elseif unitInfo[3] == "6" then
			unitType = "ZIL-4331"	
		elseif unitInfo[3] == "7" then
			unitType = "Trolley bus"					
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'CJTF Red',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1

	elseif unitInfo[1] == "baaa" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Vulcan"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "Vulcan"
		elseif unitInfo[3] == "2" then
			unitType = "M1097 Avenger"
		elseif unitInfo[3] == "3" then
			unitType = "M6 Linebacker"
		elseif unitInfo[3] == "4" then
			unitType = "Stinger comm"	
		elseif unitInfo[3] == "5" then
			unitType = "Ural-375 ZU-23"			
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
			

	elseif unitInfo[1] == "binf" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Soldier M249"
		local liv = "desert"
		if unitInfo[3] == nil then
																			mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x+21,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1	
		elseif unitInfo[3] == "1" then
							mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "2" then
										mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},

								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "3" then
													mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},

								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "4" then
						mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},

								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "5" then
																			mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x+21,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1			
		else

		end
		
		

			
	elseif unitInfo[1] == "barty" then
	
		local unitName = gnd.factionNameBlue .. gnd.unitCounterBlue
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "M-109"
		local liv = "desert"
		if unitInfo[3] == nil then
					unitType = "M-109"
											mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "1" then
			unitType = "M-109"
											mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "2" then
			unitType = "2B11 mortar"
											mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1
		elseif unitInfo[3] == "3" then
			unitType = "M-109"
											mist.dynAdd(
							{
								country = 'USA',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+20,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+40,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +80,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterBlue = gnd.unitCounterBlue + 1	
		else

		end
		
		
-----------------END OF BLUE REGULAR FORCES---------------
----------------------------------------------------------
----------------------------------------------------------	
-----------------START OF RED REGULAR FORCES--------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
				
	elseif unitInfo[1] == "rtank" then
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
				
		local unitType = "T-72B"
		local liv = "desert"
		countryType = "CJTF Blue"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "T-72B"
			countryType = "CJTF Blue"
		elseif unitInfo[3] == "2" then
			unitType = "T-80UD"
			countryType = "CJTF Blue"
		elseif unitInfo[3] == "3" then
			unitType = "T-90"
			countryType = "CJTF Blue"		
		elseif unitInfo[3] == "4" then
			unitType = "T-55"
			countryType = "CJTF Blue"
		elseif unitInfo[3] == "5" then
			unitType = "ZTZ96B"
			countryType = "CJTF Blue"	
		else

		end
		
		
								mist.dynAdd(
							{
								country = countryType,
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
			
			
			
	elseif unitInfo[1] == "rapc" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "BTR-82A"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "BTR-82A"
		elseif unitInfo[3] == "2" then
			unitType = "Cobra"
		elseif unitInfo[3] == "3" then
			unitType = "MTLB"		
		elseif unitInfo[3] == "4" then
			unitType = "BRDM-2"		
			liv = "desert_MED"
		elseif unitInfo[3] == "5" then
			unitType = "BMP-2"		
		elseif unitInfo[3] == "6" then
			unitType = "BMP-1"		
		elseif unitInfo[3] == "7" then
			unitType = "Blitz_36-6700A"		
		elseif unitInfo[3] == "8" then
			unitType = "ATZ-10"		
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
			
	elseif unitInfo[1] == "rcar" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Land_Rover_109_S3"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "Ural ATsP-6"
		elseif unitInfo[3] == "2" then
			unitType = "GAZ-3307"
		elseif unitInfo[3] == "3" then
			unitType = "Ural-375"		
		elseif unitInfo[3] == "4" then
			unitType = "MAZ-6303"		
		elseif unitInfo[3] == "5" then
			unitType = "LAZ Bus"
		elseif unitInfo[3] == "6" then
			unitType = "Ural-4320Ts"
		elseif unitInfo[3] == "7" then
			unitType = "VAZ Car"
		elseif unitInfo[3] == "8" then
			unitType = "ZIL-4331"
		elseif unitInfo[3] == "9" then
			unitType = "Trolley bus"
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
	
	elseif unitInfo[1] == "rconvoy" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Cobra"
		local liv = "desert"
		
		if unitInfo[3] == nil then
		mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "Ural-4320T",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "Ural-4320T",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
		
			gnd.unitCounterRed = gnd.unitCounterRed + 1
	
		elseif unitInfo[3] == "1" then
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "Ural-4320T",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "Ural-4320T",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterRed = gnd.unitCounterRed + 1

		
		
		elseif unitInfo[3] == "2" then
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "BRDM-2",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "BRDM-2",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "Cobra",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "BRDM-2",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "BRDM-2",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterRed = gnd.unitCounterRed + 1

		
		
		elseif unitInfo[3] == "3" then
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "BMP-1",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "BMP-1",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "BMP-1",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "T-72B",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "ZSU-23-4 Shilka",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "BMP-2",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterRed = gnd.unitCounterRed + 1

		
			
		elseif unitInfo[3] == "4" then
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = "T-72B",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x +30,
										y = pointVec3Gl.z,
										type = "T-72B",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = "T-72B",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +90,
										y = pointVec3Gl.z,
										type = "T-72B",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +120,
										y = pointVec3Gl.z,
										type = "ZSU-23-4 Shilka",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[6] = 
									{
										x = pointVec3Gl.x +150,
										y = pointVec3Gl.z,
										type = "T-72B",
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)

			gnd.unitCounterRed = gnd.unitCounterRed + 1

		end
						
	elseif unitInfo[1] == "rciv" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Land_Rover_109_S3"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "Land_Rover_109_S3"
		elseif unitInfo[3] == "2" then
			unitType = "Ural ATsP-6"
		elseif unitInfo[3] == "3" then
			unitType = "M978 HEMTT Tanker"
		elseif unitInfo[3] == "4" then
			unitType = "VAZ Car"		
		elseif unitInfo[3] == "5" then
			unitType = "MAZ-6303"	
		elseif unitInfo[3] == "6" then
			unitType = "ZIL-4331"	
		elseif unitInfo[3] == "7" then
			unitType = "Trolley bus"					
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'CJTF Red',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1

	elseif unitInfo[1] == "raaa" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Ural-375 ZU-23"
		local liv = "desert"
		if unitInfo[3] == nil then
		elseif unitInfo[3] == "1" then
			unitType = "Ural-375 ZU-23"
		elseif unitInfo[3] == "2" then
			unitType = "ZU-23 Emplacement Closed"
		elseif unitInfo[3] == "3" then
			unitType = "ZSU-23-4 Shilka"
		elseif unitInfo[3] == "4" then
			unitType = "SA-18 Igla manpad"	
		elseif unitInfo[3] == "5" then
			unitType = "Ural-375 ZU-23"	
		elseif unitInfo[3] == "6" then
			unitType = "ZSU_57_2"	
		elseif unitInfo[3] == "7" then
			unitType = "bofors40"	
			
		else

		end
		
		
								mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
			
	elseif unitInfo[1] == "rflak" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "flak18"
		local liv = "desert"
		if unitInfo[3] == nil then
																			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x+24,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1	
		end
	elseif unitInfo[1] == "rinf" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "Soldier M249"
		local liv = "desert"
		if unitInfo[3] == nil then
																			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x+21,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1	
		elseif unitInfo[3] == "1" then
							mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "2" then
										mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},

								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "3" then
													mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},

								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "4" then
						mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},

								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "5" then
																			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+6,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+12,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x+18,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x+21,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1			
		else

		end
		
		

			
	elseif unitInfo[1] == "rarty" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "SAU Gvozdika"
		local liv = "desert"
		if unitInfo[3] == nil then
					unitType = "SAU Gvozdika"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "1" then
			unitType = "SAU Gvozdika"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "2" then
			unitType = "2B11 mortar"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "3" then
			unitType = "SAU Gvozdika"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+20,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+40,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +80,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1	
		elseif unitInfo[3] == "4" then
			unitType = "SpGH_Dana"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[2] = 
									{
										x = pointVec3Gl.x+20,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[3] = 
									{
										x = pointVec3Gl.x+40,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[4] = 
									{
										x = pointVec3Gl.x +60,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
									[5] = 
									{
										x = pointVec3Gl.x +80,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1	
		else

		end
				
				
-----------------END OF RED REGULAR FORCES----------------
----------------------------------------------------------
----------------------------------------------------------	
-----------------START OF SAM SITES ----------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------	
	
	elseif unitInfo[1] == "rsam" then
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "1L13 EWR"
		local liv = "desert"
		if unitInfo[3] == nil then
			unitType = "1L13 EWR"
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = "EW " .. unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
						)
			redIADS:addEarlyWarningRadarsByPrefix('EW')
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "1" then
			unitType = "1L13 EWR"
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = "EW " .. unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
						)
			redIADS:addEarlyWarningRadarsByPrefix('EW')
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "2" then
			unitType = ".Command Center"
			mist.dynAddStatic(
							{
								country = 'CJTF Blue',
								category = 'Fortifications',
								name = "CMD " .. unitName,
								type = unitType,
								x = pointVec3Gl.x,
							    y = pointVec3Gl.z,
								heading = heading,
							} -- end of function
						)
			local commandCenter = StaticObject.getByName("CMD " .. unitName)
			redIADS = SkynetIADS:create("CMD " .. unitName)
			redIADS:addCommandCenter(commandCenter)
			redIADS:addSAMSitesByPrefix('SAM')
			redIADS:addEarlyWarningRadarsByPrefix('EW')
			redIADS:activate()
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "3" then
			unitType = "55G6 EWR"
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
						)
			redIADS:addEarlyWarningRadarsByPrefix('EW')
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "4" then
			unitType = "p-19 s-125 sr"
			mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'vehicle',
								name = "EW " .. unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
						)
			redIADS:addEarlyWarningRadarsByPrefix('EW')
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "sa10" then           -------------------------SA 10
					local unitName = gnd.factionNameRed .. gnd.unitCounterRed
						mist.dynAdd(
							{
								country = 'RUSSIA',
								category = 'vehicle',
								name = "SAM " .. unitName,
								units = 
								{
									[1] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 40B6M tr",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 4.7123889803847,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [1]
									[2] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 40B6MD sr",
                                        ["y"] = pointVec3Gl.z + 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [2]
                                    [3] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 54K6 cp",
                                        ["y"] = pointVec3Gl.z + 100,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [3]
                                    [4] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 64H6E sr",
                                        ["y"] = pointVec3Gl.z - 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["name"] = "DictKey_UnitName_28",
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [4]
                                    [5] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 5P85C ln",
                                        ["y"] = pointVec3Gl.z +200 ,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [5]
                                    [6] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 5P85D ln",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.3161255787892,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [6]
                                    [7] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 5P85D ln",
                                        ["y"] = pointVec3Gl.z ,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 2.9670597283904,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [7]
                                    [8] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Excellent",
                                        ["type"] = "S-300PS 5P85C ln",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x -200,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [8]
                                    [9] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 5P85D ln",
                                        ["y"] = pointVec3Gl.z +200,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 6.1086523819802,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [9]
                                    [10] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S-300PS 5P85D ln",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x -200 ,
                                        ["heading"] = 0.17453292519943,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [10]
                                    [11] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-4320T",
                                        ["y"] = pointVec3Gl.z +500,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [11]
								}, -- end of units
							} -- end of function
							)
		redIADS:addSAMSite("SAM " ..unitName)			
		redIADS:getSAMSiteByGroupName("SAM " .. unitName):setHARMDetectionChance( 100 )
        redIADS:getSAMSiteByGroupName("SAM " .. unitName):setGoLiveRangeInPercent(95)
		gnd.unitCounterRed = gnd.unitCounterRed + 1
		 
		elseif unitInfo[3] == "sa2" then                         ---------------- SA 2 Site                                                                        -SA2
					local unitName = gnd.factionNameRed .. gnd.unitCounterRed
						mist.dynAdd(
							{
								country = 'RUSSIA',
								category = 'vehicle',
								name = "SAM " .. unitName,
								units = 
								{
									[1] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SNR_75V",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 4.7123889803847,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [1]
									[2] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S_75M_Volhov",
                                        ["y"] = pointVec3Gl.z + 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [2]
                                    [3] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S_75M_Volhov",
                                        ["y"] = pointVec3Gl.z + 100,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [3]
                                    [4] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S_75M_Volhov",
                                        ["y"] = pointVec3Gl.z - 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [4]
                                    [5] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S_75M_Volhov",
                                        ["y"] = pointVec3Gl.z +200 ,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [5]
                                    [6] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "S_75M_Volhov",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.3161255787892,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [6]
                                    [7] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SKP-11",
                                        ["y"] = pointVec3Gl.z ,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 2.9670597283904,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [7]
                                    [8] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Excellent",
                                        ["type"] = "SKP-11",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x -200,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [8]
                                    [9] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "p-19 s-125 sr",
                                        ["y"] = pointVec3Gl.z +200,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 6.1086523819802,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [9]
                                    [10] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-4320 APA-5D",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x -200,
                                        ["heading"] = 0.17453292519943,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [10]
                                    [11] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "ATMZ-5",
                                        ["y"] = pointVec3Gl.z +550,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [11]
									[12] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-4320T",
                                        ["y"] = pointVec3Gl.z +580,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [12]
									[13] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-4320T",
                                        ["y"] = pointVec3Gl.z +600,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [13]
									[14] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "ATMZ-5",
                                        ["y"] = pointVec3Gl.z +500,
                                        ["x"] = pointVec3Gl.x + 20,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [14]									
								}, -- end of units
							} -- end of function
							)
		redIADS:addSAMSite("SAM " ..unitName)			
		redIADS:getSAMSiteByGroupName("SAM " .. unitName):setHARMDetectionChance( 100 )
        redIADS:getSAMSiteByGroupName("SAM " .. unitName):setGoLiveRangeInPercent(95)
		gnd.unitCounterRed = gnd.unitCounterRed + 1
		
				elseif unitInfo[3] == "sa3" then                         ---------------- SA 3 Site                                                                        -SA2
					local unitName = gnd.factionNameRed .. gnd.unitCounterRed
						mist.dynAdd(
							{
								country = 'RUSSIA',
								category = 'vehicle',
								name = "SAM " .. unitName,
								units = 
								{
									[1] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "snr s-125 tr",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 4.7123889803847,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [1]
									[2] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "5p73 s-125 ln",
                                        ["y"] = pointVec3Gl.z + 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [2]
                                    [3] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "5p73 s-125 ln",
                                        ["y"] = pointVec3Gl.z + 100,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [3]
                                    [4] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "5p73 s-125 ln",
                                        ["y"] = pointVec3Gl.z - 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [4]
                                    [5] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "5p73 s-125 ln",
                                        ["y"] = pointVec3Gl.z +200 ,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [5]
                                    [6] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "p-19 s-125 sr",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.3161255787892,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [6]
                                    [7] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SKP-11",
                                        ["y"] = pointVec3Gl.z ,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 2.9670597283904,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [7]
                                    [8] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Excellent",
                                        ["type"] = "ZiL-131 APA-80",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x -200,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [8]
                                    [9] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "GAZ-66",
                                        ["y"] = pointVec3Gl.z +200,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 6.1086523819802,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [9]
                                    [10] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "GAZ-66",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x -200 ,
                                        ["heading"] = 0.17453292519943,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [10]
                                    [11] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "GAZ-66",
                                        ["y"] = pointVec3Gl.z +550,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [11]
									[12] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "ZiL-131 APA-80",
                                        ["y"] = pointVec3Gl.z +580,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [12]																	
								}, -- end of units
							} -- end of function
							)
		redIADS:addSAMSite("SAM " ..unitName)			
		redIADS:getSAMSiteByGroupName("SAM " .. unitName):setHARMDetectionChance( 100 )
        redIADS:getSAMSiteByGroupName("SAM " .. unitName):setGoLiveRangeInPercent(95)
		gnd.unitCounterRed = gnd.unitCounterRed + 1
				

		
		elseif unitInfo[3] == "sa11" then                         ---------------- SA 3 Site                                                                        -SA2
					local unitName = gnd.factionNameRed .. gnd.unitCounterRed
						mist.dynAdd(
							{
								country = 'RUSSIA',
								category = 'vehicle',
								name = "SAM " .. unitName,
								units = 
								{
									[1] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SA-11 Buk SR 9S18M1",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 4.7123889803847,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [1]
									[2] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SA-11 Buk LN 9A310M1",
                                        ["y"] = pointVec3Gl.z + 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [2]
                                    [3] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SA-11 Buk LN 9A310M1",
                                        ["y"] = pointVec3Gl.z + 100,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [3]
                                    [4] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SA-11 Buk LN 9A310M1",
                                        ["y"] = pointVec3Gl.z - 50,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [4]
                                    [5] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SA-11 Buk LN 9A310M1",
                                        ["y"] = pointVec3Gl.z +200 ,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.1415926535898,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [5]
                                    [6] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "ATZ-10",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 3.3161255787892,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [6]
                                    [7] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "ATZ-10",
                                        ["y"] = pointVec3Gl.z ,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 2.9670597283904,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [7]
                                    [8] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Excellent",
                                        ["type"] = "ZiL-131 APA-80",
                                        ["y"] = pointVec3Gl.z,
                                        ["x"] = pointVec3Gl.x -200,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [8]
                                    [9] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-4320-31",
                                        ["y"] = pointVec3Gl.z +200,
                                        ["x"] = pointVec3Gl.x + 200,
                                        ["heading"] = 6.1086523819802,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [9]
                                    [10] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-4320-31",
                                        ["y"] = pointVec3Gl.z -200,
                                        ["x"] = pointVec3Gl.x -200 ,
                                        ["heading"] = 0.17453292519943,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [10]
                                    [11] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "Ural-375 PBU",
                                        ["y"] = pointVec3Gl.z +550,
                                        ["x"] = pointVec3Gl.x,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [11]		
                                    [12] = 
                                    {
                                        ["transportable"] = 
                                        {
                                            ["randomTransportable"] = false,
                                        }, -- end of ["transportable"]
                                        ["skill"] = "Random",
                                        ["type"] = "SA-11 Buk CC 9S470M1",
                                        ["y"] = pointVec3Gl.z +550,
                                        ["x"] = pointVec3Gl.x + 20,
                                        ["heading"] = 0,
                                        ["playerCanDrive"] = true,
										livery_id = "desert",										
                                    }, -- end of [12]										
								}, -- end of units
							} -- end of function
							)
		redIADS:addSAMSite("SAM " ..unitName)			
		redIADS:getSAMSiteByGroupName("SAM " .. unitName):setHARMDetectionChance( 100 )
        redIADS:getSAMSiteByGroupName("SAM " .. unitName):setGoLiveRangeInPercent(95)
		gnd.unitCounterRed = gnd.unitCounterRed + 1
		
		end
-----------------END OF RED SAM FORCES--------------------
----------------------------------------------------------
----------------------------------------------------------	
-----------------END OF SAM SITES ------------------------
----------------------------------------------------------
----------------------------------------------------------
------------------START OF RED SUBS-----------------------

	elseif unitInfo[1] == "rship" then
	
		local unitName = gnd.factionNameRed .. gnd.unitCounterRed
					
		local heading = 3.1415926535898		
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[4]) then
			heading = math.floor(unitInfo[4]*0.0174533)
		end
		
		local unitType = "speedboat"
		local liv = "desert"
		if unitInfo[3] == nil then
					unitType = "speedboat"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "1" then
					unitType = "speedboat"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "2" then
					unitType = "Type_071"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "3" then
					unitType = "ALBATROS"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = liv,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "4" then
					unitType = "CV_1143_5"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "5" then
					unitType = "Type_093"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = "periscope_state_1",
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "6" then
					unitType = "MOSCOW"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = "periscope_state_1",
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "7" then
					unitType = "ELNYA"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = "periscope_state_1",
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "8" then
					unitType = "Dry-cargo ship-2"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = "periscope_state_1",
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "9" then
					unitType = "HandyWind"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = "periscope_state_1",
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1
		elseif unitInfo[3] == "10" then
					unitType = "Dry-cargo ship-1"
											mist.dynAdd(
							{
								country = 'CJTF Blue',
								category = 'ship',
								name = unitName,
								units = 
								{
									[1] = 
									{
										x = pointVec3Gl.x,
										y = pointVec3Gl.z,
										type = unitType,
										livery_id = "periscope_state_1",
										["heading"] = heading,
                                        ["playerCanDrive"] = true,
									},
								}, -- end of units
							} -- end of function
							)
			gnd.unitCounterRed = gnd.unitCounterRed + 1

		end

	else
		-- --do nada (not cuddles and not sexually)
	end
						 
end 



function gnd.unitMover (text,pointVec3Gl)		
	-- local group = Group.getByName(gnd.unitName)                            --User provides rounds, ammo
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
	

	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else

		local group = Group.getByName(unitInfo[1])
		local controller = group:getController()
		
	-- if unitInfo[4] == nil then
		-- local vel = 100
	-- elseif tonumber(unitInfo[4]) == nil then
		-- local vel = 100
	-- else 
		-- local vel = tonumber(unitInfo[4])
	-- end
	local vel = 100
	if unitInfo[3] == nil then
	elseif unitInfo[4] == nil then
		 if unitInfo[3] == "slow" then
			vel = 2
		 elseif unitInfo[4] == "slow" then
			vel = 2
		 elseif unitInfo[3] == "fast" then
			vel = 8
		elseif unitInfo[4] == "fast" then
			vel = 8
		 end
	end
	
		controller:resetTask()
		--Controller.resetTask(Controller self) 
		
		
		-- local _groupVec3 = Group.getByName(gnd.unitName):getUnit(1):getPoint() 
		-- local path = {} --build the waypoint to, from for the unit
		-- path[#path + 1] = mist.ground.buildWP (_groupVec3, nil, 1)
		-- path[#path + 1] = mist.ground.buildWP (pointVec3Gl, nil, 1) 
		-- mist.goRoute(gnd.unitName, path)
		
		if unitInfo[3] == "road" then
			
			vars = 
			 {
			 group = group, 
			 point = pointVec3Gl,
			 speed = vel,
			 }
			 mist.groupToRandomPoint(vars)
		elseif unitInfo[3] == 'hold' then
				Hold = { 
				  id = 'Hold', 
				  params = { 
				  } 
				}
			controller:setTask(Hold)
		else
		
			vars = 
				 {
				 group = group, 
				 point = pointVec3Gl,
				 disableRoads = true,
				 speed = vel,
				 }
				 mist.groupToRandomPoint(vars)
		end
	 end
end 

function gnd.go (text, pointVec3Gl)
	
	local unitInfo = air.mysplit(text, air.delimiter)
 	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
		local group = Group.getByName(unitInfo[1])
		local controller = group:getController()
		local speed = 51.4
		local alt = 304
		if unitInfo[3] == nil or tonumber(unitInfo[3]) == false then
		elseif tonumber(unitInfo[3]) then
			speed = math.floor(unitInfo[3]*0.514)
		end
		if unitInfo[4] == nil or tonumber(unitInfo[4]) == false then
		elseif tonumber(unitInfo[3]) then
			alt = math.floor(unitInfo[4]*0.3048)
		end
		
		--start point where they are
		local startPoint = mist.getLeadPos(Group.getByName(unitInfo[1]))
		--end point where the vec3 is
		local endPoint = mist.utils.makeVec2(pointVec3Gl)
		
		local path = {}
		path[#path + 1] = mist.heli.buildWP(startPoint, TurningPoint, speed, alt, 'agl') 
		path[#path + 1] = mist.heli.buildWP(endPoint, TurningPoint, speed, alt, 'agl') 
		mist.goRoute(group, path)
	end


end

function gnd.unitSafe(text,pointVec3Gl)		
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
	

	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
				


		local group = Group.getByName(unitInfo[1])
		local controller = group:getController()                           --User provides rounds, ammo	
		controller:setOption(0, 4) -- hold
		
		
	end	
		
end

function gnd.suicide(text,pointVec3Gl)		
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
	

	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
		local group = Group.getByName(unitInfo[1])
		local controller = group:getController()
		local position = group:getUnit(1):getPoint()
		trigger.action.explosion(position,1000)
				
	end	
		
end

function gnd.unitHot(text,pointVec3Gl)		
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
	

	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
				

		local group = Group.getByName(unitInfo[1])
		local controller = group:getController()                           --User provides rounds, ammo	
		controller:setOption(0, 2) -- fire
		
		
	end	
		
end 

function gnd.unitLaser(text,pointVec3Gl)
	-- local group = Group.getByName(gnd.unitName)                            --User provides rounds, ammo
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else

				if unitInfo[3] == nil then
						unitInfo[3] = "1688"
				elseif tonumber(unitInfo[3]) then
					--if this passes we need to do nothing unitInfo 3 is already a valid laser code as its a number
				else
					unitInfo[3] = "1688"
				end
					
				local group = Group.getByName(unitInfo[1])
				local target = pointVec3Gl
				local ray = Spot.createLaser(group, {x = 0, y = 1, z = 0}, target, tonumber(unitInfo[3]))
				
					
				notify("Laser on code " .. unitInfo[3],2)
				
				gnd.laserTable[tonumber(gnd.laserCounter)] = ray
				gnd.laserCounter = gnd.laserCounter+1
	end
end

function gnd.unitLaserOff(text,pointVec3Gl)

	for key, value in ipairs(gnd.laserTable) do
			--value.destroy()
			Spot.destroy(value)
	   end
	 notify("All Lasers Off",2)
	gnd.laserCounter = 1
	gnd.laserTable = nil
	gnd.laserTable = {}
end 

function gnd.unitShooter(text,pointVec3)
	-- local group = Group.getByName(gnd.unitName)                            --User provides rounds, ammo
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
 	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
	
			
			-- --do some magic code to conv vec3gl to vec2
			local vec2 = mist.utils.makeVec2(pointVec3)
			
			local group = Group.getByName(unitInfo[1])

			local controller = group:getController()
			
			local expend = 5
			local distance = 10
			
			if unitInfo[3] == nil then
			else
				expend = tonumber(unitInfo[3]) 
			end
			if unitInfo[4] == nil then
			else
				distance = tonumber(unitInfo[4])
			end

			local fireTask = { 
				id = 'FireAtPoint', 
				params = {
				point = vec2,
				radius = distance,
				expendQty = expend,
				expendQtyEnabled = true, 
				}
			}
			controller:setTask(fireTask)
	end

end

function gnd.unitInv(text,pointVec3)
	
	local unitInfo = gnd.mysplit(text, gnd.delimiter)
 	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
	
			
			-- --do some magic code to conv vec3gl to vec2
			local group = Group.getByName(unitInfo[1])
			local controller = group:getController()
			
			if unitInfo[3] == nil then
				local setImmortal = { id = 'SetImmortal', params = {value = false}}
				controller:setCommand(setImmortal)
			elseif unitInfo[3] == "on" then
				local setImmortal = { id = 'SetImmortal', params = {value = true}}
				controller:setCommand(setImmortal)
			else
				local setImmortal = { id = 'SetImmortal', params = {value = false}}
				controller:setCommand(setImmortal)
			end

	end

end

function gnd.effect(text,pointVec3)

	local unitInfo = gnd.mysplit(text, gnd.delimiter)
		 
			if unitInfo[2] == nil then
				trigger.action.explosion(pointVec3, 1)
				trigger.action.effectSmokeBig(pointVec3, 5, 0)
			elseif unitInfo[2] == "bomb" then
				trigger.action.explosion(pointVec3, 1)
			else
				trigger.action.effectSmokeBig(pointVec3, 5, 0)
			end

	
end

function gnd.smoke (text,pointVec3Gl)

	local unitInfo = gnd.mysplit(text, gnd.delimiter)
		 
			if unitInfo[3] == nil then
				trigger.action.smoke(pointVec3Gl,2)
			elseif unitInfo[3] == "g" then
				trigger.action.smoke(pointVec3Gl,0)
			elseif unitInfo[3] == "r" then
				trigger.action.smoke(pointVec3Gl,1)
			elseif unitInfo[3] == "w" then
				trigger.action.smoke(pointVec3Gl,2)
			elseif unitInfo[3] == "o" then
				trigger.action.smoke(pointVec3Gl,3)
			elseif unitInfo[3] == "b" then
				trigger.action.smoke(pointVec3Gl,4)
			else
				trigger.action.smoke(pointVec3Gl,2)
			end

end 

function gnd.remove(text,pointVec3)

	local unitInfo = gnd.mysplit(text, gnd.delimiter)
 	
	if Group.getByName(unitInfo[1]) == nil then
	elseif #Group.getByName(unitInfo[1]):getUnits() < 1 then
	else
	
			
			-- --do some magic code to conv vec3gl to vec2
			local group = Group.getByName(unitInfo[1])
			Group.destroy(group)

	end

	
end


		
function gnd.eventHandler (event) 
	if (26 == event.id) then

				
			if string.find(event.text, gnd.delimiter .. "spawn") then 
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitSpawner(event.text,pointVec3)
			elseif string.find(event.text, gnd.delimiter .. "laser") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitLaser(event.text,pointVec3)
			elseif string.find(event.text, gnd.delimiter .. "off") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitLaserOff(event.text,pointVec3)								
			elseif string.find(event.text, gnd.delimiter .. "fire") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitShooter(event.text,pointVec3)
			elseif string.find(event.text, gnd.delimiter .. "smoke") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.smoke(event.text,pointVec3)		
			elseif string.find(event.text, gnd.delimiter .. "safe") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitSafe(event.text,pointVec3)
			elseif string.find(event.text, gnd.delimiter .. "hot") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitHot(event.text,pointVec3)		
			elseif string.find(event.text, gnd.delimiter .. "inv") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitInv(event.text,pointVec3)		
			elseif string.find(event.text, gnd.delimiter .. "effect") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.effect(event.text,pointVec3)	
			elseif string.find(event.text, gnd.delimiter .. "remove") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.remove(event.text,pointVec3)		
			elseif string.find(event.text, gnd.delimiter .. "suicide") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.suicide(event.text,pointVec3)					
			elseif string.find(event.text, gnd.delimiter .. "goto") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.go(event.text,pointVec3)																			
			elseif string.find(event.text, gnd.delimiter .. "move") then
				local pointVec3 = mist.utils.makeVec3GL(event.pos)
				gnd.unitMover(event.text,pointVec3)			
			end	
		end
end



do
	mist.addEventHandler(gnd.eventHandler)
end



