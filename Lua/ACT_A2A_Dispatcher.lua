--Define Detecting network
DetectionSetGroupRED = SET_GROUP:New()
DetectionSetGroupRED:FilterPrefixes( { "EWR Base", "AWACS Red #001"} )
DetectionSetGroupRED:FilterStart()

DetectionRED = DETECTION_AREAS:New( DetectionSetGroupRED, 5000 )

--Init Dispatcher
A2ADispatcherRED = AI_A2A_DISPATCHER:New( DetectionRED, 30000 )

--Define Border
BorderRED = ZONE_POLYGON:New( "BORDER Red", GROUP:FindByName( "BORDER Red" ) )
A2ADispatcherRED:SetBorderZone( BorderRED )

--Define EngageRadius
A2ADispatcherRED:SetEngageRadius( 150000 )

--Define Squadrons

A2ADispatcherRED:SetSquadron( "CAP_RED_1", AIRBASE.PersianGulf.Kerman_Airport, {"CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010"} )
A2ADispatcherRED:SetSquadron( "CAP_RED_2", AIRBASE.PersianGulf.Shiraz_International_Airport, {"CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010"} )

--Define Squadron properties
A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_1", 1 )
A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_1", 2 )

A2ADispatcherRED:SetSquadronOverhead( "CAP_RED_2", 1 )
A2ADispatcherRED:SetSquadronGrouping( "CAP_RED_2", 2 )

--Define CAP Squadron execution
A2ADispatcherRED:SetSquadronCap( "CAP_RED_1", BorderRED,  6000, 8000, 600, 900, 600, 900, "BARO")
A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_1", 2, 500, 600, 1)

A2ADispatcherRED:SetSquadronCap( "CAP_RED_2", BorderRED,  3000, 9000, 400, 800, 600, 900, "BARO")
A2ADispatcherRED:SetSquadronCapInterval( "CAP_RED_2", 1, 500, 600, 1)

--Debug
A2ADispatcherRED:SetTacticalDisplay( true )

--Define Defaults
A2ADispatcherRED:SetDefaultTakeOffInAir()
A2ADispatcherRED:SetDefaultLandingAtRunway()

