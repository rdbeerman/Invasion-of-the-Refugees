groupUnitList = 0

function notify(message, displayFor)
    trigger.action.outTextForCoalition(coalition.side.BLUE, message, displayFor)
end

notify("starting...",1)

group = GROUP:FindByName("unit1")

--unit1 = UNIT:FindByName ( "Unit #001" )
--notify("unit found...",1)

group:HandleEvent( EVENTS.Dead )
notify("event made",1)

function group:OnEventDead( EventData )
    groupUnitList = groupUnitList + 1
    notify("unit died", 5)
    if groupUnitList >= group:GetInitialSize() *  0.5 then
        notify("group is dead", 5)
    end
end

notify("function made",1)

