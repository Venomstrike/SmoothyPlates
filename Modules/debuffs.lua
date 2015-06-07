local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local DBFS = SP:NewModule("Debuffs", "AceEvent-3.0", "LibNameplateRegistry-1.0")

-- Debuff Module for SmoothyPlates
-- Shows own debuffs of enemy players and hooks it to the target plate

--------------Global Variables----------------



----------------------------------------------

function DBFS:OnInitialize()
	
	SP:print("Module: Debuffs, loaded")

end

function DBFS:OnEnable()
	
	SP:print("Module: Debuffs, was enabled")

end

function DBFS:OnDisable()

	SP:print("Module: Debuffs, was disabled")

end