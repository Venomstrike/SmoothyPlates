local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local Trinket = SP:NewModule("Trinket", "AceTimer-3.0", "AceEvent-3.0")

local trinketSpellIDs = {
    [208683] = true,
    [195710] = true,
    [ 42292] = true
}

local playerUsedTrinket = {}

local TrinketTexture

function Trinket:OnEnable()

    TrinketTexture = GetSpellTexture(208683)

    SP.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_TrinketIcon")
    SP.RegisterCallback(self, "SP_ARENA_STATE_CHANGED")
    SP.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")

end

function Trinket:CreateElement_TrinketIcon(event, plate)
    local sp = plate.SmoothyPlate.sp
    sp.TrinketIcon = CreateFrame("Frame", nil, sp)
    sp.TrinketIcon:SetSize(16, 16)
    sp.TrinketIcon:SetPoint("TOPRIGHT", sp, -7, 18)

	sp.TrinketIcon.back = CreateFrame("Frame", nil, sp.TrinketIcon)
	sp.TrinketIcon.back:SetSize(16, 16)
	sp.TrinketIcon.back:SetAllPoints()
	sp.TrinketIcon.back:SetBackdrop(SP.stdbd)
	sp.TrinketIcon.back:SetBackdropColor(0,0,0,0.6)
	sp.TrinketIcon.back:SetFrameLevel(1)

	SP:AddSPBorders(sp.TrinketIcon, 1)

    sp.TrinketIcon.cd = CreateFrame("Cooldown", nil, sp.TrinketIcon, "CooldownFrameTemplate")
    sp.TrinketIcon.cd:SetAllPoints()
    sp.TrinketIcon.cd:SetHideCountdownNumbers(true)

    sp.TrinketIcon.tex = sp.TrinketIcon:CreateTexture()
    sp.TrinketIcon.tex:SetAllPoints()
    sp.TrinketIcon.tex:SetTexture(TrinketTexture)
    sp.TrinketIcon.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    plate.SmoothyPlate.sp.TrinketIcon:Hide()

end

local inArena = false
function Trinket:SP_ARENA_STATE_CHANGED(event, isInArena)
    playerUsedTrinket = {}
    inArena = isInArena
    if inArena then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end


local CombatLog_Object_IsA, COMBATLOG_FILTER_HOSTILE_PLAYERS, UnitGUID = CombatLog_Object_IsA, COMBATLOG_FILTER_HOSTILE_PLAYERS, UnitGUID
function Trinket:COMBAT_LOG_EVENT_UNFILTERED(event, timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)

    if not CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) or not spellID or not sourceGUID then return end

    if playerUsedTrinket[sourceGUID] then return end

    if trinketSpellIDs[spellID] then
        playerUsedTrinket[sourceGUID] = GetTime() + 180
        self:ScheduleTimer(function()
            if playerUsedTrinket[sourceGUID] then
                playerUsedTrinket[sourceGUID] = nil
                self:ApplyTrinket(sourceGUID)
            end
        end, 180)
    else return end

    self:ApplyTrinket(sourceGUID)
end

function Trinket:ApplyTrinket(guid, forceHide)
    local plate = SP:GetPlateByGUID(guid)
    if not plate then return end

    if not inArena then plate.SmoothyPlate.sp.TrinketIcon:Hide() return end
    if forceHide then plate.SmoothyPlate.sp.TrinketIcon:Hide() return end

    if playerUsedTrinket[guid] then
        plate.SmoothyPlate.sp.TrinketIcon.cd:SetCooldown(GetTime() - playerUsedTrinket[guid], 180)
        plate.SmoothyPlate.sp.TrinketIcon:Show()
    else
        plate.SmoothyPlate.sp.TrinketIcon.cd:SetCooldown(0, 0)
        plate.SmoothyPlate.sp.TrinketIcon:Show()
    end

end

function Trinket:UNIT_ADDED(event, plate)
    self:ApplyTrinket(UnitGUID(plate.SmoothyPlate.unitid))
end

function Trinket:UNIT_REMOVED(event, plate)
    self:ApplyTrinket(UnitGUID(plate.SmoothyPlate.unitid), true)
end
