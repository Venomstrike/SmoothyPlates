local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local Stunns = SP:NewModule("Stunns")

local activeStunns = {}
local UnitGUID = UnitGUID
local GetTime = GetTime
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo

function Stunns:OnEnable()

    SP.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_StunnFrame")
    SP.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
    SP.RegisterCallback(self, "SP_PLAYER_ENTERING_WORLD")

    self.cc = LibStub("LibCC-1.0")
    self.cc.RegisterCallback(self, "ENEMY_STUN")
    self.cc.RegisterCallback(self, "ENEMY_STUN_FADED")

end

function Stunns:SP_PLAYER_ENTERING_WORLD()
    activeStunns = {} -- dont forget to clean up, kids
end

function Stunns:CreateElement_StunnFrame(event, plate)
    local sp = plate.SmoothyPlate.sp

    sp.StunnFrame = CreateFrame("Frame", nil, sp)
	sp.StunnFrame:SetSize(36, 36)
	sp.StunnFrame:SetPoint("TOPLEFT", sp, -31, -5)

    sp.StunnFrame.tex = sp.StunnFrame:CreateTexture()
    sp.StunnFrame.tex:SetAllPoints()

    SP:AddSPBorders(sp.StunnFrame, 1)

    sp.StunnFrame.cd = CreateFrame("Cooldown", nil, sp.StunnFrame, "CooldownFrameTemplate")
    sp.StunnFrame.cd:SetAllPoints()
    sp.StunnFrame.cd:SetHideCountdownNumbers(false)

    sp.StunnFrame:Hide()

end

function Stunns:ENEMY_STUN(event, destGUID, sourceGUID, spellID)

    if not activeStunns[destGUID] then activeStunns[destGUID] = {} end
    activeStunns[destGUID][spellID] = true;
    self:ApplyStun(destGUID)

end

function Stunns:ENEMY_STUN_FADED(event, destGUID, sourceGUID, spellID)

    if activeStunns[destGUID] and activeStunns[destGUID][spellID] then
        activeStunns[destGUID][spellID] = nil
    end

    if activeStunns[destGUID] then
        local stunnCount = 0
        for i in ipairs(activeStunns[destGUID]) do stunnCount = stunnCount + 1 end
        if stunnCount == 0 then activeStunns[destGUID] = nil end
    end

    self:ApplyStun(destGUID)

end

function Stunns:ApplyStun(guid, forceHide)
    local currStunn = activeStunns[guid]
    local plate = SP:GetPlateByGUID(guid)

    if currStunn and not forceHide then
        if plate then
            local expires, icon, duration = 0, nil, 0
            local iconN, durationN, expiresNew, timeModN = nil, 0, 0, 0
            -- So we have a table with all stunns applied to the unit
            -- we have to iterate over the table to determine what stunn duration is the highest
            -- so we can be save to always show the stunn wich is actualy stunning the unit
            -- Damn, it took long to figure out how to do this the best way...
            for k,v in pairs(activeStunns[guid]) do
                if v then
                    _, _, iconN, _, _, durationN, expiresNew, _, _, _, _, _, _, _, _, timeModN = UnitDebuff(plate.SmoothyPlate.unitid, GetSpellInfo(k))
                    if expiresNew then -- to be safe if the stun-debuff does not exists on the unit (for whatever cases)
                        local exNew = (expiresNew - GetTime()) / timeModN -- timeMod for some Time-Shit accuracy (holy shat i dont want to know in wich cases)
                        if exNew > expires then
                            expires = exNew
                            icon = iconN
                            duration = durationN
                        end
                    end
                end
            end
            _ = nil
            if duration == 0 or not plate.SmoothyPlate.sp.StunnFrame then return end

            plate.SmoothyPlate.sp.StunnFrame.tex:SetTexture(icon)
            plate.SmoothyPlate.sp.StunnFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            plate.SmoothyPlate.sp.StunnFrame.cd:SetCooldown(GetTime() - (duration-expires), duration)

            plate.SmoothyPlate.sp.StunnFrame:Show()
        end
    else
        if plate then
            if plate.SmoothyPlate.sp.StunnFrame then
                plate.SmoothyPlate.sp.StunnFrame:Hide()
            end
        end
    end

end

function Stunns:UNIT_ADDED(event, plate)
    self:ApplyStun(UnitGUID(plate.SmoothyPlate.unitid))
end

function Stunns:UNIT_REMOVED(event, plate)
    self:ApplyStun(UnitGUID(plate.SmoothyPlate.unitid), true)
end
