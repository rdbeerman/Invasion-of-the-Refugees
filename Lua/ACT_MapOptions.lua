act = {}

act.zones = {}
act.sams = {}
act.ewrs = {}
act.shorad = {}
act.smallDefenses = {}
act.pointDefenses = {}
act.capRed = {}
act.airbaseZones = {}
act.airbaseEwr = {}
act.shipsZones = {}

function templateArrayBuilder(type, arrayName, nameString) --1: groups; 2: zones
    local i = 1
    local _var = true
    if type == 1 then --check for groups
        while _var == true do
            local groupName = nameString .. tostring(i)
            if Group.getByName(groupName) ~= nil then
                arrayName[i] = groupName
                i = i + 1
            else
                _var = false
            end
        end
    elseif type == 2 then --check for zones
        while _var == true do
            local zoneName = nameString .. tostring(i)
            if trigger.misc.getZone(zoneName) ~= nil then
                arrayName[i] = zoneName
                i = i + 1
            else
                _var = false
            end
        end
    end
end

function act.caucasus()
    trigger.action.outText("Hello Caucasus", 5)
    map = "caucasus"

    act.capAirbases = {
        AIRBASE.Caucasus.Krasnodar_Center,
        AIRBASE.Caucasus.Anapa_Vityazevo
    }

    templateArrayBuilder(2, act.zones, "zone-")
    templateArrayBuilder(1, act.sams, "SAM-")
    templateArrayBuilder(1, act.ewrs, "EWR-")
    templateArrayBuilder(1, act.shorad, "shorad-")
    templateArrayBuilder(1, act.smallDefenses, "defenseSmall-")
    templateArrayBuilder(1, act.pointDefenses, "pointDefense-")
    templateArrayBuilder(1, act.capRed, "CAP Red-")
    templateArrayBuilder(2, act.airbaseZones, "airbaseZone-")
    templateArrayBuilder(1, act.airbaseEwr, "EWR Base-")


    act.primObjectives = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4", "primObjective-5", "primObjective-6", "primObjective-7"}

    act.structures = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4"}
    act.typeSpecial = { "primObjective-5", "primObjective-6", "primObjective-7" }
    act.typeSpecialSam = { "primObjective-8" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.blueground = { "blueGround-1" }
    act.heloObjectives = { "heloObjective-1", "heloObjective-2", "heloObjective-3" }

    act.escort = { "escort-1" } 
    
end

function act.persianGulf()
    trigger.action.outText("Hello Persian Gulf", 5)
    map = "persianGulf"
    
    act.capAirbases = {
        AIRBASE.PersianGulf.Shiraz_International_Airport,
        AIRBASE.PersianGulf.Kerman_Airport
    }

    act.zones = {}
    act.sams = {}
    act.ewrs = {}
    act.shorad = {}
    act.smallDefenses = {}
    act.pointDefenses = {}
    act.capRed = {}
    act.airbaseZones = {}
    act.airbaseEwr = {}

    templateArrayBuilder(2, act.zones, "zone-")
    templateArrayBuilder(1, act.sams, "SAM-")
    templateArrayBuilder(1, act.ewrs, "EWR-")
    templateArrayBuilder(1, act.shorad, "shorad-")
    templateArrayBuilder(1, act.smallDefenses, "defenseSmall-")
    templateArrayBuilder(1, act.pointDefenses, "pointDefense-")
    templateArrayBuilder(1, act.capRed, "CAP Red-")
    templateArrayBuilder(2, act.airbaseZones, "airbaseZone-")
    templateArrayBuilder(1, act.airbaseEwr, "EWR Base-")

    act.primObjectives = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4", "primObjective-5", "primObjective-6", "primObjective-7"}

    act.structures = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4"}
    act.typeSpecial = { "primObjective-5", "primObjective-6", "primObjective-7" }
    act.typeSpecialSam = { "primObjective-8" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.blueground = { "blueGround-1" }
    act.heloObjectives = {"heloObjective-2", "heloObjective-3" }

    act.escort = { "escort-1" }

end
    
function act.syria()
    
    trigger.action.outText("Hello Syria", 5)
    map = "syria"
    
    act.capAirbases = {
        AIRBASE.Syria.Palmyra,
        AIRBASE.Syria.Tabqa
    }

    templateArrayBuilder(2, act.zones, "zone-")
    templateArrayBuilder(1, act.sams, "SAM-")
    templateArrayBuilder(1, act.ewrs, "EWR-")
    templateArrayBuilder(1, act.shorad, "shorad-")
    templateArrayBuilder(1, act.smallDefenses, "defenseSmall-")
    templateArrayBuilder(1, act.pointDefenses, "pointDefense-")
    templateArrayBuilder(1, act.capRed, "CAP Red-")
    templateArrayBuilder(2, act.airbaseZones, "airbaseZone-")
    templateArrayBuilder(1, act.airbaseEwr, "EWR Base-")
    templateArrayBuilder(2, act.shipsZones, "shipsZone-")

    act.primObjectives = { "airbase-1", "airbase-2", "primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4", "primObjective-5", "primObjective-6", "primObjective-7"}
    act.ships = {"ship-1", "ship-2", "ship-3"}

    act.structures = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4"}
    act.typeSpecial = { "primObjective-5", "primObjective-6", "primObjective-7" }
    act.typeSpecialSam = { "primObjective-8" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.blueground = { "blueGround-1" }
    act.heloObjectives = { "heloObjective-1", "heloObjective-2", "heloObjective-3" }

    act.escort = { "escort-1" }

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

function act.getSmallDefenses()
    return act.smallDefenses
end

function act.getPointDefenses()
    return act.pointDefenses
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

function act.getAirbaseEwr()
    return act.airbaseEwr
end

function act.getSpecialNames()
    return act.specialNames
end

function act.getSpecialSamNames()
    return act.specialSamNames
end

function act.getShips()
    return act.ships
end

function act.getShipsZones()
    return act.shipsZones
end