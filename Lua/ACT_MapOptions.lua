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
act.escortBlue = {}
act.escortRed = {}
act.escortGrey = {}
act.redTarget = {}
act.carrierDefense = {}
act.precisionObjectives = {}
act.precisionSAMzones = {}
act.precisionGroups = {}

act.convoyRed = {}
act.convoyCpBlue = {}

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
        AIRBASE.Syria.Tabqa,
        AIRBASE.Syria.Palmyra,
        AIRBASE.Syria.Khalkhalah
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
    templateArrayBuilder(1, act.escortBlue, "escortBlue-")
    templateArrayBuilder(1, act.escortRed, "escortRed-")
    templateArrayBuilder(1, act.escortGrey, "escortGrey-")
    templateArrayBuilder(2, act.redTarget, "redTarget-")
    templateArrayBuilder(1, act.carrierDefense, "carrierDefense-")
    templateArrayBuilder(2, act.precisionObjectives, "precisionZone-") 
    templateArrayBuilder(2, act.precisionSAMzones, "precisionSAM-")
    templateArrayBuilder(1, act.precisionGroups, "precisionGroup-")   

    --convoy stuff
    templateArrayBuilder(1, act.convoyRed, "Convoy-")
    templateArrayBuilder(1, act.convoyCpBlue, "Checkpoint-")
    act.convoyRedEndZone = {"convoyRedEndZone-1"}

    act.primObjectives = { "airbase-1", "airbase-2", "primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4", "primObjective-5", "primObjective-6", "primObjective-7", "primObjective-8"}
    act.ships = {"ship-1", "ship-2", "ship-3"}
    act.shipCarrier = {"ship-4"}
    act.shipEngFrac = 50

    act.structures = {"primObjective-1", "primObjective-2", "primObjective-3", "primObjective-4"}
    act.typeSpecial = { "primObjective-5", "primObjective-6", "primObjective-7" }
    act.typeSpecialSam = { "primObjective-SA10" }

    act.specialNames = {"SCUD Site", "Artillery Battery", "Smerch Battery"}
    act.specialSamNames = {"SA-10 site"}

    act.blueground = { "blueGround-1" }
    act.heloObjectives = { "heloObjective-1", "heloObjective-2", "heloObjective-3" }

    act.precisionNames = {"Military Base", "Palace", "Headquarters", "Bridge", "Military Research Base", "Military Base", "Harbour", "Hydroelectric powerplant", "Hydroelectric powerplant", "Hydroelectric powerplant", "Bridge", "Harbour", "Bridge", "Bridge", "Palace", "Headquarters", "Headquarters", "Powerplant", "Heliport", "Heliport"}
end

function act.getCheckpointsBlue()
    return act.convoyCpBlue
end

function act.getConvoyRed()
    return act.convoyRed
end

function act.getconvoyRedEndZone()
    return act.convoyRedEndZone
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

function act.getEscortBlue()
    return act.escortBlue
end

function act.getEscortRed()
    return act.escortRed
end

function act.getEscortGrey()
    return act.escortGrey
end

function act.getRedTarget()
    return act.redTarget
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

function act.getShipCarrier()
    return act.shipCarrier
end

function act.getCarrierDefense()
    return act.carrierDefense
end

function act.getShipEngFrac()
    return act.shipEngFrac
end

function act.getPrecisionObjectives()
    return act.precisionObjectives
end

function act.getPrecisionSAMzones()
    return act.precisionSAMzones
end

function act.getPrecisionGroups()
    return act.precisionGroups
end

function act.getPrecisionNames()
    return act.precisionNames
end