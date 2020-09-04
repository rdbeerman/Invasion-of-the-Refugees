act = {}

function act.caucasus()
    trigger.action.outText("Hello Caucasus", 5)
    map = "caucasus"

    act.capAirbases = {
        AIRBASE.Caucasus.Krasnodar_Center,
        AIRBASE.Caucasus.Anapa_Vityazevo
    }
    act.zones = {"zone #001", "zone #002", "zone #003", "zone #004", "zone #005", "zone #006", "zone #007", "zone #008", "zone #009", "zone #010", "zone #011"}

    act.primObjectives = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #002", "primObjective #005", "primObjective #006" }

    act.structures = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004"}
    act.typeSpecial = { "primObjective #005", "primObjective #006", "primObjective #007" }
    act.typeSpecialSam = { "primObjective-8" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.sams = {"SAM #001", "SAM #002", "SAM #004" } --sa-3 removed
    act.ewrs = {"EWR #001", "EWR #002", "EWR #003"}
    act.shorad = {"shorad-1", "shorad-2"}
    act.defenses = {"defense #001", "defense #002", "defense #003", "defense #004", "defense #005"}
	act.smallDefenses = { "defenseSmall #001", "defenseSmall #002" }

    act.capRed = { "CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010" }

    act.blueground = { "blueGround #001" }
    act.heloObjectives = { "heloObjective #001", "heloObjective #002", "heloObjective #003" }

    act.escort = { "escort #001" }

    act.airbaseStructures = { "airbase #002" }
    act.airbaseZones = { "airbaseZone #001", "airbaseZone #002" }
    act.airbaseEwr = { "EWR Base #001", "EWR Base #002" }
    
end

function act.persianGulf()
    trigger.action.outText("Hello Persian Gulf", 5)
    map = "persianGulf"
    
    act.capAirbases = {
        AIRBASE.PersianGulf.Shiraz_International_Airport,
        AIRBASE.PersianGulf.Kerman_Airport
    }

    act.zones = {"zone #001", "zone #002", "zone #003", "zone #004"}

    act.primObjectives = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #002", "primObjective #005", "primObjective #006", "primObjective #007"}

    act.structures = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004"}
    act.typeSpecial = { "primObjective #005", "primObjective #006", "primObjective #007" }
    act.typeSpecialSam = { "primObjective-8" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.sams = {"SAM #001", "SAM #002", "SAM #004" } --buggy sa-3 removed
    act.ewrs = {"EWR #001", "EWR #002", "EWR #003"}
    act.shorad = {"shorad-1", "shorad-2"}
    act.defenses = {"defense #001", "defense #002", "defense #003", "defense #004", "defense #005"}
	act.smallDefenses = { "defenseSmall #001", "defenseSmall #002" }

    act.capRed = { "CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010" }

    act.blueground = { "blueGround #001" }
    act.heloObjectives = { "heloObjective #001", "heloObjective #002", "heloObjective #003" }

    act.escort = { "escort #001" }

    act.airbaseStructures = { "airbase #002" }
    act.airbaseZones = { "airbaseZone #001", "airbaseZone #002" }
    act.airbaseEwr = { "EWR Base #001", "EWR Base #002" }
end
    
function act.syria()
    
    trigger.action.outText("Hello Syria", 5)
    map = "syria"
    
    act.capAirbases = {
        AIRBASE.Syria.Palmyra,
        AIRBASE.Syria.Tabqa
    }

    act.zones = { "zone-1", "zone-2", "zone-3", "zone-4", "zone-5", "zone-6", "zone-7", "zone-8", "zone-9", "zone-10", "zone-11", "zone-12" }

    act.primObjectives = { "airbase-1", "airbase-2", "primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4", "primObjective-5", "primObjective-6", "primObjective-7"}

    act.structures = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4"}
    act.typeSpecial = { "primObjective-5", "primObjective-6", "primObjective-7" }
    act.typeSpecialSam = { "primObjective-8" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.sams = {"SAM-1", "SAM-2", "SAM-4" } --sam-3 removed for now
    act.ewrs = {"EWR-1", "EWR-2", "EWR-3"}
    act.shorad = {"shorad-1", "shorad-2"}
    act.defenses = {"defense-1", "defense-2", "defense-3", "defense-4", "defense-5"}
	act.smallDefenses = { "defenseSmall-1", "defenseSmall-2" }

    act.capRed = { "CAP Red-1", "CAP Red-2", "CAP Red-3", "CAP Red-4", "CAP Red-5", "CAP Red-6", "CAP Red-7" }

    act.blueground = { "blueGround-1" }
    act.heloObjectives = { "heloObjective-1", "heloObjective-2", "heloObjective-3" }

    act.escort = { "escort-1" }

    act.airbaseStructures = { "airbase-1", "airbase-2" }
    act.airbaseZones = { "airbaseZone-1", "airbaseZone-2" }
    act.airbaseEwr = { "EWR Base #001", "EWR Base #002", "EWR Base #003" }

end

function act.getZones()
    return act.zones
end

function act.getPrimObjectives()
    return act.primObjectives
end

function act.getStructures()
    return act.structures
end

function act.getTypeSpecial()
    return act.typeSpecial
end

function act.getTypeSpecialSam()
    return act.typeSpecialSam
end

function act.getSams()
    return act.sams
end

function act.getEwrs()
    return act.ewrs
end

function act.getShorad()
    return act.shorad
end

function act.getDefenses()
    return act.defenses
end

function act.getSmallDefenses()
    return act.smallDefenses
end

function act.getRedCap()
    return act.capRed
end

function act.getBlueGround()
    return act.blueGround
end

function act.getHeloObjectives()
    return act.heloObjectives
end

function act.getEscort()
    return act.escort
end

function act.getAirbaseZones()
    return act.airbaseZones
end

function act.getAirbaseStructures()
    return act.airbaseStructures
end

function act.getAirbaseEwr()
    return act.airbaseEwr
end

function act.getSpecialNames()
    return act.specialNames
end

function act.getSpecialSamNames()
    return act.specialSamNames
end