-- Tanker settings
tankerCVN=RECOVERYTANKER:New(UNIT:FindByName("CVN-71 Theodore Roosevelt"), "Recovery Tanker")
tankerCVN:SetRadio(127.5)
tankerCVN:SetCallsign(CALLSIGN.Tanker.Arco, 2)

-- Start Tanker
tankerCVN:Start()

-- SAR Helo
SARHelo=RESCUEHELO:New(UNIT:FindByName("CVN-71 Theodore Roosevelt"), "SARHelo")
SARHelo:Start()

-- AWACS settings
local awacsCVN=RECOVERYTANKER:New("CVN-71 Theodore Roosevelt", "AWACS Blue")
awacsCVN:SetAWACS()
awacsCVN:SetCallsign(CALLSIGN.AWACS.Overlord, 1)
awacsCVN:SetAltitude(20000)
awacsCVN:SetRadio(240)
awacsCVN:SetTACAN(2, "OVR")

-- Start AWACS
awacsCVN:Start()