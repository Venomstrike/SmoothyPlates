local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local CMBP = SP:NewModule("Combopoints", "AceEvent-3.0", "LibNameplateRegistry-1.0")

-- Combopoints Module for SmoothyPlates
-- Shows Combopoint bubbles and hooks it to the target plate

--------------Global Variables----------------



----------------------------------------------

function CMBP:OnInitialize()
	
	SP:print("Module: Combopoints, loaded")

end

function CMBP:OnEnable()
	
	SP:print("Module: Combopoints, was enabled")

end

function CMBP:OnDisable()

	SP:print("Module: Combopoints, was disabled")

end