    --  Name:                           CYC_MissionPlan
    --  Author:                         Tony
	-- assert(loadfile('C:\\Users\\username\\Saved Games\\DCS.openbeta\\Missions\\In dev\\t45\\Lua\\ACT_loadModules.lua'))()
    --  Dependencies:                   Mist.lua
    --  Description:
    --      Lists all co ordinates and times of waypoint markers 
    --  Usage:
    --      1. Uncomment, or add, any .lua files you wish to run
    --      2. place f10 markers for waypoints named wp2t103000 etc and it will print them via  
    --      3. wp1 is auto and always bulls
	
--[[List of outstanding work to do
   
	7. Takes speeds from ToT at your given ground speed and works out the ToT for each waypoint
	8. Updates the ToT based on a hack time that you can change and it re calculates the ToT
	10. If waypoints aren't ordered 1 - etc then can start from later number 
	11. Only shows the waypoints to the group who hit the F10 menu
]]--



plan = {}



-- Declaration (+1 if summertime)
--	  * Caucasus +4
--    * Nevada -8
--    * Normandy 0
--    * Persian Gulf +4
--    * Syria +2
plan.mapDiff = 3 --effectively sets the time zone difference in hours to the UK of the map






function plan.mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function notify(message, displayFor) --activiy notify function
    trigger.action.outText(message, displayFor)
end

plan.wptstore = {}

function plan.storeWP(Vec3,wptxt)

	--work out which waypoint they want updating
	local splitTxt = plan.mysplit(wptxt, 't')
	--check to see if any tot is there 
	
	--take this value and store into the table the values they want
	local wayPointNo = splitTxt[2]
		--if something is blank 


   local LLposNstring, LLposEstring = plan.LLtool.LLstrings(Vec3)    
   local gElev = math.floor((land.getHeight({x=Vec3.x, y = Vec3.z}))*3.28084)
   --notify(splitTxt[1] .. " " .. splitTxt[2] .. " " .. splitTxt[3] .. " "  ,20)
	
	if splitTxt[3] == nil then
           splitTxt[3] = ""
	else
			splitTxt[3] = "ToT: " .. splitTxt[3] .. " z"
	
     end
	local value = splitTxt[2] ..' N ' .. LLposNstring .. '   E ' .. LLposEstring .. " alt " .. gElev ..  " ft. " .. splitTxt[3]
	
	if tonumber(wayPointNo) == nil then
		notify("Waypoint " .. wayPointNo .. " must be a number",2)
	else
	   	plan.wptstore[tonumber(wayPointNo)] = value
		notify("Waypoint " .. wayPointNo .. " entered",2)
	end

  -- notify("Waypoint " .. splitTxt[2] ..' N ' .. LLposNstring .. '   E ' .. LLposEstring .. " alt " .. gElev ..  " ft. " .. splitTxt[3], 20)
	
	--plan.wpno = wayPointNo
end

function plan.displayWaypoints()
	   notify("Mission Waypoints",120)
	   
	   --notify(plan.wptstore[plan.wpno],20)

	   
	   for key, value in ipairs(plan.wptstore) do
			notify("Waypoint " .. value,120)
	   end
	   
	   -- for index, value in ipairs(plan.wptstore) do
			-- notify(index .. " " .. value,20)
	   -- end
	   
end

function plan.resetWP()
	plan.wptstore = nil
	plan.wptstore = {}
	notify("Mission waypoints reset",2)
end

function plan.printZuluTime()
	local timeAbsZulu = (timer.getAbsTime() - (plan.mapDiff *60*60))

	if timeAbsZulu < 0 then
		timeAbsZulu = 24*60*60 + timeAbsZulu --stops zulu going negative if we go back past midnight
	end
	local localTime = mist.getClockString(timeAbsZulu)
	local times = cvn.mysplit(localTime, ':')
	notify("Time is " .. times[1] .. ":" .. times[2] .. ":" .. times[3] .. " z",20)
end

do
    radioSubMenu = missionCommands.addSubMenu ("Mission planner")
    radioPlan = missionCommands.addCommand ("Display plan", radioSubMenu, plan.displayWaypoints)
	radioTime = missionCommands.addCommand ("Display current zulu time", radioSubMenu, plan.printZuluTime)
	radioReset = missionCommands.addCommand ("Reset all mission waypoints", radioSubMenu, plan.resetWP)
end

plan.LLtool = {}
plan.LLtool.LLstrings = function(pos) -- pos is a Vec3
local LLposN, LLposE = coord.LOtoLL(pos)
local LLposfixN, LLposdegN = math.modf(LLposN)
LLposdegN = LLposdegN * 60
local LLposdegN2, LLposdegN3 = math.modf(LLposdegN)
LLposdegN3 = LLposdegN3 * 60
local LLposfixE, LLposdegE = math.modf(LLposE)
LLposdegE = LLposdegE * 60
local LLposdegE2, LLposdegE3 = math.modf(LLposdegE)
LLposdegE3 = LLposdegE3 * 60
local LLposNstring = string.format('%.2i° %.2i\' %.2d\"', LLposfixN, LLposdegN2, LLposdegN3)
local LLposEstring = string.format('%.3i° %.2i\' %.2d\"', LLposfixE, LLposdegE2, LLposdegE3)
return LLposNstring, LLposEstring

end

