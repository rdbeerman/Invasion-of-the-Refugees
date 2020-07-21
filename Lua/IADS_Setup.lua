do

redIADS = redIADS = SkynetIADS:create('IADS-Network')
redIADS:addSAMSitesByPrefix('SAM')
--redIADS:addEarlyWarningRadarsByPrefix('EWR')
redIADS:activate()

--local iadsDebug = redIADS:getDebugSettings()  --disable if not in use
--iadsDebug.IADSStatus = true
--iadsDebug.samWentDark = true
--iadsDebug.contacts = true
--iadsDebug.radarWentLive = true
--iadsDebug.ewRadarNoConnection = true
--iadsDebug.samNoConnection = true
--iadsDebug.jammerProbability = true
--iadsDebug.addedEWRadar = true
--iadsDebug.hasNoPower = true
--iadsDebug.addedSAMSite = true
--iadsDebug.warnings = true
--iadsDebug.harmDefence = true
--iadsDebug.samSiteStatusEnvOutput = true
--iadsDebug.earlyWarningRadarStatusEnvOutput = true

end