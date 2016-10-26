local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local Healers = SP:NewModule("Healers", "AceEvent-3.0")

local healerclasses = {
	[65] = "Paladin: Holy",
	[105] = "Druid: Restoration",
	[256] = "Priest: Discipline",
	[257] = "Priest: Holy",
	[264] = "Shaman: Restoration",
	[270] = "Monk: Mistweaver"
}
-- Stolen from Healers have to Die | THANX
local ONLY_HEALER_SPELLS = {
    -- Priests
    --      Discipline
    [047540] = "PRIEST", -- Penance XXX strange error received from user on 2015-10-15 (this spell was cast by a hunter...)
    [109964] = "PRIEST", -- Spirit shell -- not seen in disc
    [002060] = "PRIEST", -- Greater Heal
    [014914] = "PRIEST", -- Holy Fire
    [033206] = "PRIEST", -- Pain Suppression
    [000596] = "PRIEST", -- Prayer of Healing
    [000527] = "PRIEST", -- Purify
    [081749] = "PRIEST", -- Atonement
    [132157] = "PRIEST", -- Holy Nova
    --      Holy
    [034861] = "PRIEST", -- Circle of Healing
    [064843] = "PRIEST", -- Divine Hymn
    [047788] = "PRIEST", -- Guardian Spirit
    [032546] = "PRIEST", -- Binding Heal
    [077485] = "PRIEST", -- Mastery: Echo of Light -- the passibe ability
    [077489] = "PRIEST", -- Echo of Light -- the aura applied by the afformentioned
    [000139] = "PRIEST", -- Renew

    -- Druids
    --[018562] = "DRUID", -- Swiftmend -- (also available through restoration afinity talent)
    [102342] = "DRUID", -- Ironbark
    [033763] = "DRUID", -- Lifebloom
    [088423] = "DRUID", -- Nature's Cure
    -- [008936] = "DRUID", -- Regrowth -- (also available through restoration afinity talent)
    [033891] = "DRUID", -- Incarnation: Tree of Life
    [048438] = "DRUID", -- Wild Growth
    [000740] = "DRUID", -- Tranquility
    -- [145108] = "DRUID", -- Ysera's Gift -- (also available through restoration afinity talent)
    -- [000774] = "DRUID", -- Rejuvination -- (also available through restoration afinity talent)

    -- Shamans
    [061295] = "SHAMAN", -- Riptide
    [077472] = "SHAMAN", -- Healing Wave
    [098008] = "SHAMAN", -- Spirit link totem
    [001064] = "SHAMAN", -- Chain Heal
    [073920] = "SHAMAN", -- Healing Rain

    -- Paladins
    [020473] = "PALADIN", -- Holy Shock
    [053563] = "PALADIN", -- Beacon of Light
    [082326] = "PALADIN", -- Holy Light
    [085222] = "PALADIN", -- Light of Dawn

    -- Monks
    [115175] = "MONK", -- Soothing Mist
    [115310] = "MONK", -- Revival
    [116670] = "MONK", -- Vivify
    [116680] = "MONK", -- Thunder Focus Tea
    [116849] = "MONK", -- Life Cocoon
    [119611] = "MONK" -- Renewing mist
};

function Healers:OnEnable()

	--GetSpellTexture(208683);
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    SP.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_HealerIcon")
    SP.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")

end

local healerGUIDs = {}

function Healers:CreateElement_HealerIcon(event, plate)
    local sp = plate.SmoothyPlate.sp
    sp.HealerIcon = CreateFrame("Frame", nil, sp)
    sp.HealerIcon:SetSize(16, 16)
    sp.HealerIcon:SetPoint("TOPLEFT", sp, 7, 18)

	sp.HealerIcon.back = CreateFrame("Frame", nil, sp.HealerIcon)
	sp.HealerIcon.back:SetSize(16, 16)
	sp.HealerIcon.back:SetAllPoints()
	sp.HealerIcon.back:SetBackdrop(SP.stdbd)
	sp.HealerIcon.back:SetBackdropColor(0,0,0,0.6)
	sp.HealerIcon.back:SetFrameLevel(1)

	SP:AddSPBorders(sp.HealerIcon, 1)

    sp.HealerIcon.tex = sp.HealerIcon:CreateTexture()
    sp.HealerIcon.tex:SetAllPoints()
    sp.HealerIcon.tex:SetTexture(SP.HEALER_ICON)

    plate.SmoothyPlate.sp.HealerIcon:Hide()

end

local UnitGUID = UnitGUID
function Healers:UNIT_ADDED(event, plate)
    local guid = UnitGUID(plate.SmoothyPlate.unitid)
    if healerGUIDs[guid] then
        if SP:GetPlateByGUID(guid) then
            plate.SmoothyPlate.sp.HealerIcon:Show()
        else
            plate.SmoothyPlate.sp.HealerIcon:Hide()
        end
    end

end

function Healers:UNIT_REMOVED(event, plate)

    plate.SmoothyPlate.sp.HealerIcon:Hide()

end

function Healers:COMBAT_LOG_EVENT_UNFILTERED(event, timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)

    if not CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) or not spellID or not sourceGUID then return end

    if healerGUIDs[sourceGUID] then return end

    if ONLY_HEALER_SPELLS[spellID] then
        healerGUIDs[sourceGUID] = true;
    else return end

    local plate = SP:GetPlateByGUID(sourceGUID)
    if plate then
        plate.SmoothyPlate.sp.HealerIcon:Show()
    end

end

function Healers:PLAYER_ENTERING_WORLD()
    healerGUIDs = {}
end

function Healers:isHealer(specId)

	if not specId then return false end

	if not healerclasses[specId] then
		return false
	else
		return true
	end

end
