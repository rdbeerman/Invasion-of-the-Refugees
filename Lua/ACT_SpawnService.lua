
Spawn_AWACS_RED = SPAWN:New("AWACS Red 1")
Spawn_AWACS_RED2 = SPAWN:New("AWACS Red 2")
Spawn_AWACS_RED3 = SPAWN:New("AWACS Red 3")

Spawn_TANKERSLOW = SPAWN:New("KC-135 Slow")
Spawn_TANKERFAST = SPAWN:New("KC-135 Fast")
Spawn_TANKERMPRS = SPAWN:New("KC-135 MPRS")

Spawn_AWACS_BLUE = SPAWN:New("AWACS Blue")


Spawn_AWACS_RED:Spawn()
Spawn_AWACS_RED2:Spawn()
Spawn_AWACS_RED3:Spawn()

Spawn_TANKERSLOW:Spawn()
Spawn_TANKERFAST:Spawn()
Spawn_TANKERMPRS:Spawn()

Spawn_AWACS_BLUE:Spawn()


Spawn_AWACS_RED:InitCleanUp( 20 )
Spawn_AWACS_RED2:InitCleanUp( 20 )
Spawn_AWACS_RED3:InitCleanUp( 20 )

Spawn_TANKERSLOW:InitCleanUp( 60 )
Spawn_TANKERFAST:InitCleanUp( 60 )
Spawn_TANKERMPRS:InitCleanUp( 60 )

Spawn_AWACS_BLUE:InitCleanUp( 60 )

function moveEventHandler(event)
    if event.id == 26 and event.text == 'awacs' then
        local _group = Spawn_AWACS_BLUE:GetFirstAliveGroup()
        
        local _orbitTask = { 
            id = 'Orbit', 
            params = { 
              pattern = AI.Task.OrbitPattern,
              point = event.pos,
              point2 = event.pos,
              speed = _group:getVelocity(),
              altitude = _group:getHeight()
            } 
           }
        
        local controller = _group:getController()
        controller:setTask(_orbitTask)
        trigger.action.outText("Awacs tasked" , 10 , false)
    end
end

do
    mist.addEventHandler(moveEventHandler)
end