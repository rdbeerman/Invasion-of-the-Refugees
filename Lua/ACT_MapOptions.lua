act = {}

function act.caucasus()
    trigger.action.outText("Hello Caucasus", 10)
    map = "caucasus"

    act.capAirbases = {
        AIRBASE.Caucasus.Krasnodar_Center,
        AIRBASE.Caucasus.Anapa_Vityazevo
    }

    act.Zones = {"zone #001", "zone #002", "zone #003", "zone #004", "zone #005", "zone #006", "zone #007", "zone #008", "zone #009", "zone #010", "zone #011"}
end

function act.persianGulf()
    trigger.action.outText("Hello Persian Gulf", 10)
    map = "persianGulf"
    
    act.capAirbases = {
        AIRBASE.Caucasus.Krasnodar_Center,
        AIRBASE.Caucasus.Anapa_Vityazevo
    }

    act.Zones = {"zone #001", "zone #002", "zone #003", "zone #004"}
end

function act.getZones()
    return act.Zones
end
