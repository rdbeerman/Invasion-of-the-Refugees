act = {}

function act.caucasus()
    trigger.action.outText("Hello Caucasus", 10)
    map = "caucasus"

    act.capAirbases = {
        AIRBASE.Caucasus.Krasnodar_Center,
        AIRBASE.Caucasus.Anapa_Vityazevo
    }

    act.zones = {"zone #001", "zone #002", "zone #003", "zone #004", "zone #005", "zone #006", "zone #007", "zone #008"}

    act.primObjectives = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #002", "primObjective #005", "primObjective #006", "primObjective #007"}

    act.structures = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004"}
    act.typeSpecial = { "primObjective #005", "primObjective #006", "primObjective #007" }

    act.sams = {"SAM #001", "SAM #002", "SAM #003", "SAM #004" }
    act.ewrs = {"EWR #001", "EWR #002", "EWR #003"}
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
    trigger.action.outText("Hello Persian Gulf", 10)
    map = "persianGulf"
    
    act.capAirbases = {
        AIRBASE.Caucasus.Krasnodar_Center,
        AIRBASE.Caucasus.Anapa_Vityazevo
    }

    act.zones = {"zone #001", "zone #002", "zone #003", "zone #004"}

    act.primObjectives = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #002", "primObjective #005", "primObjective #006", "primObjective #007"}

    act.structures = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004"}
    act.typeSpecial = { "primObjective #005", "primObjective #006", "primObjective #007" }

    act.sams = {"SAM #001", "SAM #002", "SAM #003", "SAM #004" }
    act.ewrs = {"EWR #001", "EWR #002", "EWR #003"}
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

--[[
    
    --Syria, not working anyway right now, needs a new moose version
function act.syria()
    trigger.action.outText("Hello Syria", 10)
    map = "syria"
    
    act.capAirbases = {
        AIRBASE.Syria.Damascus, --
        AIRBASE.Syria.Aleppo --temp
    }

    act.zones = {"zone-1", "zone-2" }

    act.primObjectives = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004", "airbase #002", "primObjective #005", "primObjective #006", "primObjective #007"}

    act.structures = {"primObjective #001", "primObjective #002", "primObjective #003", "primObjective #004"}
    act.typeSpecial = { "primObjective #005", "primObjective #006", "primObjective #007" }

    act.sams = {"SAM #001", "SAM #002", "SAM #003", "SAM #004" }
    act.ewrs = {"EWR #001", "EWR #002", "EWR #003"}
    act.defenses = {"defense #001", "defense #002", "defense #003", "defense #004", "defense #005"}
	act.smallDefenses = { "defenseSmall #001", "defenseSmall #002" }

    act.capRed = { "CAP Red #001", "CAP Red #002", "CAP Red #003", "CAP Red #004", "CAP Red #005", "CAP Red #006", "CAP Red #007", "CAP Red #008", "CAP Red #009", "CAP Red #010" }

    act.blueground = { "blueGround #001" }
    act.heloObjectives = { "heloObjective #001", "heloObjective #002", "heloObjective #003" }

    act.escort = { "escort #001" }

    act.airbaseStructures = { "airbase #002" }
    act.airbaseZones = { "airbaseZone #001", "airbaseZone #002" }
    act.airbaseEwr = { "EWR Base #001", "EWR Base #002" }

    --trigger.action.outText("Hello Syria Gulf again", 10) --debug
end

]]--

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

function act.getSams()
    return act.sams
end

function act.getEwrs()
    return act.ewrs
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