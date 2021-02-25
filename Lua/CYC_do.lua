    --  Name:                           ACT_loadModules
    --  Author:                         Tony
	-- assert(loadfile('C:\\Users\\username\\Saved Games\\DCS.openbeta\\Missions\\In dev\\t45\\Lua\\ACT_loadModules.lua'))()
    --  Dependencies:                   Mist.lua
    --  Description:
    --      Loads all other modules that you want to bring in for your mission
    --  Usage:
    --      1. Uncomment, or add, any .lua files you wish to run
    --      2. 
    --      3.
	
--[[List of outstanding work to do
    1. 
]]--
--Pre reqs for the CYC_MissionPlan.lua function
plan = {}
--pre reques for the CYC_carrier.lua functions
cvn = {}
cvn.carrierName = "CVN-71 Theodore Roosevelt" -- must match groupname in game
cvn.carrierFreq = "127.5 MHz"
cvn.carrierTacan = "71X"
cvn.carrierICLS = "Chan 17"
cvn.startUpTime = 300 -- DO NOT MAKE THIS LESS THAN 200 seconds. this is the time in seconds you want to give to people to start up the jets and be ready to launch in cyclic auditions


function cvn.eventHandler(event)
	if (26 == event.id) then
		--this sectoin should be kept if using CYC_MissionPlan.lua
	
		if string.find (event.text, "wpt") then 			
				local wptxt = string.match(event.text, '%d')
				if wptxt == nil then
					notify("Enter valid wpt format",2)					
				else
					local Vec3 = mist.utils.makeVec3GL(event.pos)
					plan.storeWP(Vec3,event.text,event.initiator)
				end
		
		--START of SECTION
		--CYC_carrier.lua START of SECTION this sectoin should be kept if using CYC_carrier.lua
		
		
		elseif string.find (event.text, "cvn") then 
					local carrierSpeed = string.match(event.text, '%d%d')
					if carrierSpeed == nil then     
					 notify("Enter in a speed",2)
					elseif tonumber (carrierSpeed) <= 31  then						
						cvnVec3 = mist.utils.makeVec3GL(event.pos)
						cvn.Waypoint(carrierSpeed,cvnVec3) -- dependency file CYC_carrier.lua
					else
						notify("Invalid carrier speed: Please enter value from 01 to 30 Knots", 10)
					end	
					
					
					
		elseif string.find (event.text, "lha") then 
					local carrierSpeed = string.match(event.text, '%d%d')
					if carrierSpeed == nil then     
					 notify("Enter in a speed",2)
					elseif tonumber (carrierSpeed) <= 31  then						
						cvnVec3 = mist.utils.makeVec3GL(event.pos)
						lha.Waypoint(carrierSpeed,cvnVec3) -- dependency file CYC_carrier.lua
					else
						notify("Invalid carrier speed: Please enter value from 01 to 30 Knots", 10)
					end				
					
		elseif string.find (event.text, "rke") then 
					local carrierSpeed = string.match(event.text, '%d%d')
					if carrierSpeed == nil then     
					 notify("Enter in a speed",2)
					elseif tonumber (carrierSpeed) <= 31  then						
						cvnVec3 = mist.utils.makeVec3GL(event.pos)
						rke.Waypoint(carrierSpeed,cvnVec3) -- dependency file CYC_carrier.lua
					else
						notify("Invalid speed: Please enter value from 01 to 30 Knots", 10)
					end				
					
		elseif string.find (event.text, "cms") then 
						rke.taskFire(mist.utils.makeVec2(event.pos))  
		--END of SECTION
		--CYC_carrier.lua END of SECTION for CYC_carrier.lua
		
		else
			--do nothing
			

		--end of CYC_carrier.lua
		
		end -- this end goes with the first if string.find (event.text, "wpt") then 	
		
		
	end -- goes with the if (26 == event.id) then line
end --ends the function(event) line section 

do
	mist.addEventHandler(cvn.eventHandler)
end -- goes with the do line
