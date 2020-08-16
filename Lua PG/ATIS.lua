-- ATIS at Al Minhad AB on 275.500 MHz AM.
atisAlMinhad=ATIS:New(AIRBASE.PersianGulf.Al_Minhad_AB, 275.500)
atisAlMinhad:SetTowerFrequencies({275.000, 280.000})
atisAlMinhad:SetRadioRelayUnitName("Radio Relay Al_Minhad_AB")
atisAlMinhad:Start()