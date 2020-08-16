-- Tanker settings
tankerCVN=RECOVERYTANKER:New(UNIT:FindByName("CVN-71 Theodore Roosevelt"), "Recovery Tanker")
tankerCVN:SetRadio(127.5)
tankerCVN:SetCallsign(CALLSIGN.Tanker.Arco, 2)

-- Start Tanker
tankerCVN:Start()

-- SAR Helo
SARHelo=RESCUEHELO:New(UNIT:FindByName("CVN-71 Theodore Roosevelt"), "SARHelo")
SARHelo:Start()