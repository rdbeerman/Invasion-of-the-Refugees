simple = {}
simple.debug = true

function simple.notify(message, duration) --used this so often now... 
    trigger.action.outText(tostring(message), duration)
    env.info("Notify: " .. tostring(message), false)
end

function simple.debugOutput(message)
    local _outputString = "Debug: " .. tostring(message)
    if simple.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function simple.errorOutput(message)
    local _outputString = "ERROR: " .. tostring(message)
    trigger.action.outText(tostring(_outputString), 300)
    env.error(_outputString, false)
end

function simple.smokeVec3 (vec3) --puts smoke at vec3 for debugging
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function simple.printVec3 (vec3) --prints a vec3 to the message box
    trigger.action.outText("vec3.x: " .. vec3.x .. " ; vec3.y: " .. vec3.y .. " ; vec3.z: " .. vec3.z, 5)
end

function simple.getAltitudeAgl (vec3) --returns the altitude AGL of a given vec3
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    local output = vec3.y - _vec3GL.y
    --simple.debugOutput ("getAltitudeAgl: altitude is " .. output .. "m AGL.")
    return output
end

local function dump(table) --https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
	if type(table) == 'table' then
	   local s = '{ \n'
  
	   for k,v in pairs(table) do
		  if type(k) ~= 'number' then
			  k = '"'..k..'"'
		  end
		  s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
	   end
  
	   return s .. '}'
	else
	   return tostring(table)
	end
end

function simple.dumpTable(table) --call this to dumb a table
	env.info("dumpTable: \n" .. dump(table))
end

do
    simple.notify("simple finished loading", 15)
end