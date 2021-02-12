--[[
  Name:                           ACT Anti-Ship
  Author:                         Activity
  Last Modified On:               25/01/2021
  Dependencies:                   mist
  Description:
      Improves Anti-Ship gameplay in DCS world by simple damage modeling and nerfing of AI.
  Usage:
  load ACT_harpoon.lua on mission init
  ]]

as = {}

-- Settings

as.debug = false
as.explosionSize = 500
as.radarChance = 0.3
as.weaponChance = 0.25
as.engineChance = 0.15
as.fireChance = 0.5

as.secNoLower = 1
as.secNoUpper = 6

as.secTimeLower = 10
as.secTimeLower = 60

as.maxMissiles = 8
as.cooldown = 120

-- Declarations, do not change
as.counter = 0
as.database = {}

function as.impact(target)
  local vec3 = target:getPoint()
  trigger.action.explosion(vec3, as.explosionSize)
  
  if math.random(0, 10) <= as.radarChance * 10 then
    local controller = target:getController()
    controller:setOption(9, 1)
    if as.debug == true then
      trigger.action.outText("Disabled radar system", 5, false)
    end
  end
  
  if math.random(0, 10) <= as.weaponChance * 10 then
    local controller = target:getController()
    controller:setOption(0, 4)
    if as.debug == true then
      trigger.action.outText("Disabled weapon system", 5, false)
    end
  end

  if math.random(0, 10) <= as.engineChance * 10 then
    local path = {}
    path[1] = mist.ground.buildWP(vec3, nil, 0)
    mist.goRoute(target, path)
    if as.debug == true then
      trigger.action.outText("Disabled propulsion system", 5, false)
    end
  end
  
  if math.random(0, 10) <= as.fireChance * 10 then
    for i = as.secNoLower, math.random(as.secNoLower, as.secNoUpper) do
      timer.scheduleFunction(as.secondary, target, timer.getTime() + i * math.random(as.secTimeLower, as.secTimeUpper) )
    end

    if as.debug == true then
      trigger.action.outText("Started a fire", 5, false)
    end
  end
end

function as.secondary(target)
  local vec3 = target:getPoint()
  trigger.action.explosion(vec3, as.explosionSize + math.random(100, 500))
  if as.debug == true then
    trigger.action.outText("Secondary explosion", 5, false)
  end
end

function as.missileIntercept(ship)
  local name = ship:getName()
  
  if as.database[name] == nil then
    as.database[name] = 0
  end
  
  as.database[name] = as.database[name] + 1

  if as.debug == true then
    trigger.action.outText("Ship fired "..as.database[name].." missiles.", 5, false)
  end

  if as.database[name] >= as.maxMissiles - 1 then
    local controller = ship:getController()
    controller:setOption(1, false)
    as.database[name] = 0
    timer.scheduleFunction(as.enableRoE, ship, timer.getTime() + as.cooldown)
    if as.debug == true then
      trigger.action.outText(name.." cooldown started.", 5, false)
    end
  end  
end

function as.enableRoE(unit)
  local controller = unit:getController()
  controller:setOption(0, 2)
  if as.debug == true then
    trigger.action.outText("cooldown lifted.", 5, false)
  end
end

do -- Sets up event handlers
  trigger.action.outText("ACT Harpoon Init started", 10 , false)
  local old_onEvent = world.onEvent
    world.onEvent = function(event)
      if (2 == event.id) then
        if event.target:getGroup():getCategory() == 3 then  
          local weaponType = event.weapon:getTypeName()                   --Gets weapon type
          
          if weaponType == "AGM_84D" or weaponType == "C-802AK" or weaponType == "AGM_84E" then      --If weapon is harpoon, consider if slammer + target is ship too, add different ifs for mavs
          as.impact(event.target)
          
          elseif weaponType == "AGM_65E" or weaponType == "AGM_65G" or weaponType == "AGM_65K" or weaponType == "GBU_10" then
            as.impact(event.target)
          end  
        
          if as.debug == true then
            local shooter = event.initiator:getName()
            trigger.action.outText("Impact Detected: \n Shooter: "..tostring(shooter).."\n Weapon: "..tostring(weaponType).."\n Target: "..tostring(event.target:getName()), 10 , false)
          end
        end
      end
      
      if (1 == event.id) then
        if event.initiator:getGroup():getCategory() == 3 then
          as.missileIntercept(event.initiator)
        end
      end
      return old_onEvent(event)
  end
end

