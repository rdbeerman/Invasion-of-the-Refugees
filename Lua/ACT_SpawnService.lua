
Spawn_AWACS_RED = SPAWN:New("AWACS Red #001")
Spawn_TANKER1 = SPAWN:New("TANKER Blue #001")
Spawn_TANKER2 = SPAWN:New("TANKER Blue #002")
Spawn_TANKER3 = SPAWN:New("TANKER Blue #003")
Spawn_AWACS_BLUE = SPAWN:New("AWACS Blue #001")


Spawn_AWACS_RED:Spawn()
Spawn_TANKER1:Spawn()
Spawn_TANKER2:Spawn()
Spawn_TANKER3:Spawn()
Spawn_AWACS_BLUE:Spawn()


Spawn_AWACS_RED:InitCleanUp( 20 )
Spawn_TANKER1:InitCleanUp( 60 )
Spawn_TANKER2:InitCleanUp( 60 )
Spawn_TANKER3:InitCleanUp( 60 )
Spawn_AWACS_BLUE:InitCleanUp( 60 )