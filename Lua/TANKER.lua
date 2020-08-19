do
    -- Get groups
  local _shell = Group.getByName("TANKER Blue #002#001")

  -- Get the tanker down
  function tankerShellActionsLow()
  trigger.action.pushAITask(_shell, 1)
  trigger.action.pushAITask(_shell, 3)
  trigger.action.outText("Shell1-1 going to 20 angels", 5)
  end

  function tankerShellActionsHigh()
  trigger.action.pushAITask(_shell, 2)
  trigger.action.pushAITask(_shell, 3)
  trigger.action.outText("Shell1-1 going to 31 angels", 5)
  end

  -- ADD SUB RADIO MENUs
  local tankerMenu = missionCommands.addSubMenu("Tanker")
  local shellMenu = missionCommands.addSubMenu("Shell1-1", tankerMenu)

  -- ADD MENU ITEMS
  missionCommands.addCommand("Request low orbit", shellMenu, tankerShellActionsLow, {})
  missionCommands.addCommand("Request high (default) orbit", shellMenu, tankerShellActionsHigh, {})
end
