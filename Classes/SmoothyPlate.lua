local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
_G.SmoothyPlate = {} -- Create Class Table
SmoothyPlate.__index = SmoothyPlate -- Create backfall for lookup

setmetatable(SmoothyPlate, { -- Setup cunstructor call in metatable
  __call = function (cls, ...)
    return cls._constructor(...)
  end
})

function SmoothyPlate._constructor(frame)
  local this = setmetatable({}, SmoothyPlate)

  if frame.SmoothyPlate then return frame.SmoothyPlate end

    this.sp = CreateFrame("BUTTON", "$parentSmoothedPlate", frame);
    this.sp:EnableMouse(false);
    this.sp:SetAllPoints(frame)
    this.sp:SetFrameStrata("BACKGROUND")

    this.sp.BackDrop = this:ConstructElement_BackDrop(this.sp)
    this.sp.HealthBar = this:ConstructElement_HealthBar(this.sp)
    this.sp.PowerBar = this:ConstructElement_PowerBar(this.sp)
    this.sp.CastBar = this:ConstructElement_CastBar(this.sp)
    this.sp.Name = this:ConstructElement_Name(this.sp)
    this.sp.HealPredBar = this:ConstructElement_HealPredBar(this.sp)
    this.sp.AbsorbBar = this:ConstructElement_AbsorbBar(this.sp)
    this.sp.PredSpark = this:ConstructElement_PredSpark(this.sp)

    this.unitid = nil;
    this.health = 0;
    this.currHealth = 0;
    this.currHealPred = 0;
    this.currAbsorb = 0;

    frame.SmoothyPlate = this;
    this.sp:Hide();

  return this
end

function SmoothyPlate:getNameplateFrame()
    return self.sp:GetParent();
end

function SmoothyPlate:GetUnit()
    return self.unitid;
end

function SmoothyPlate:ConstructElement_BackDrop(parent)

    local frame = CreateFrame("Frame", "$parentBackdrop", parent)
	frame:SetSize(140, 46)
	frame:SetPoint("CENTER", 0, 10)
	frame:SetBackdrop(SP.stdbd)
    frame:SetBackdropColor(0,0,0,0.6)
    frame:SetFrameLevel(1)
    frame:SetFrameStrata("BACKGROUND")

    SP:AddSPBorders(frame, 1)

    return frame;
end

function SmoothyPlate:ConstructElement_HealthBar(parent)

    local frameH = CreateFrame("StatusBar", "$parentHealthBar", parent)
	frameH:SetStatusBarTexture(SP.BAR_TEX)
	frameH:GetStatusBarTexture():SetHorizTile(false)
	frameH:SetWidth(131)
	frameH:SetHeight(20)
	frameH:SetPoint("TOP", parent, 0, -16)
    frameH:SetStatusBarColor(1,0,0,1)
    frameH:SetFrameStrata("BACKGROUND")
	SP.smoothy:SmoothBar(frameH)

	frameH.pc = frameH:CreateFontString(nil, "OVERLAY")
	frameH.pc:SetPoint("CENTER", frameH, 0, 0)
	frameH.pc:SetFont(SP.FONT, 11, "OUTLINE")
	frameH.pc:SetJustifyH("LEFT")
	frameH.pc:SetShadowOffset(1, -1)
	frameH.pc:SetTextColor(1, 1, 1)
	frameH.pc:SetText("100%")

    frameH.back = CreateFrame("Frame", "$parentBack", frameH)
    frameH.back:SetSize(131, 20)
    frameH.back:SetPoint("CENTER", 0, 0)
    frameH.back:SetBackdrop(SP.stdbd)
    frameH.back:SetBackdropColor(0,0,0,0.2)

    frameH.back:SetFrameLevel(1)
    frameH:SetFrameLevel(4)

    return frameH;
end

function SmoothyPlate:ConstructElement_PowerBar(parent)

    local frameP = CreateFrame("StatusBar", "$parentPowerBar", parent)
	frameP:SetStatusBarTexture(SP.BAR_TEX)
	frameP:GetStatusBarTexture():SetHorizTile(false)
	frameP:SetWidth(131)
	frameP:SetHeight(3)
	frameP:SetPoint("CENTER", parent, 0, -8)
    frameP:SetStatusBarColor(0.9,0.9,0.1,1)
    frameP:SetFrameStrata("BACKGROUND")
	SP.smoothy:SmoothBar(frameP)

    frameP.back = CreateFrame("Frame", "$parentBack", frameP)
    frameP.back:SetSize(132, 3)
    frameP.back:SetPoint("CENTER", 0, 0)
    frameP.back:SetBackdrop(SP.stdbd)
    frameP.back:SetBackdropColor(0,0,0,0.2)

    frameP.back:SetFrameLevel(3)
    frameP:SetFrameLevel(4)

    return frameP
end

function SmoothyPlate:ConstructElement_CastBar(parent)

    local frameC = CreateFrame("Frame", "$parentCastBar", parent)
	frameC:SetSize(140, 19)
	frameC:SetPoint("BOTTOM", 0, -1)
	frameC:SetBackdrop(SP.stdbd)
    frameC:SetBackdropColor(0,0,0,0.6)

    frameC.back = CreateFrame("Frame", "$parentBack", frameC)
    frameC.back:SetSize(134, 14)
    frameC.back:SetPoint("CENTER", 0, 0)
    frameC.back:SetBackdrop(SP.stdbd)
    frameC.back:SetBackdropColor(0,0,0,0.2)

    frameC.back:SetFrameLevel(3)
    frameC:SetFrameLevel(4)

    SP:AddSPBorders(frameC, 1)

	frameC.bar = CreateFrame("StatusBar", nil, frameC)
	frameC.bar:SetStatusBarTexture(SP.BAR_TEX)
	frameC.bar:GetStatusBarTexture():SetHorizTile(false)
	frameC.bar:SetWidth(134)
	frameC.bar:SetHeight(14)
	frameC.bar:SetPoint("CENTER", 0, 0)
	frameC.bar:SetStatusBarColor(SP:fromRGB(255, 255, 0, 255))

	frameC.icon = CreateFrame("Frame", nil, frameC)
	frameC.icon:SetSize(19, 19)
	frameC.icon:SetPoint("LEFT", -20, 0)

    SP:AddSPBorders(frameC.icon, 1)

    frameC.icon.tex = frameC.icon:CreateTexture()
    frameC.icon.tex:SetAllPoints()

	frameC.name = frameC.bar:CreateFontString(nil, "OVERLAY")
	frameC.name:SetPoint("LEFT", frameC, 8, 0)
	frameC.name:SetFont(SP.FONT, 10, "OUTLINE")
	frameC.name:SetJustifyH("LEFT")
	frameC.name:SetShadowOffset(1, -1)
	frameC.name:SetTextColor(1, 1, 1)
	frameC.name:SetText("Lichtblitz")

    frameC:Hide();

    return frameC;
end

function SmoothyPlate:ConstructElement_AbsorbBar(parent)

    local frameAB = CreateFrame("StatusBar", "$parentAbsorbBar", parent)
	frameAB:SetStatusBarTexture(SP.PRED_BAR_TEX)
	frameAB:GetStatusBarTexture():SetHorizTile(false)
	frameAB:SetWidth(131)
	frameAB:SetHeight(20)
	frameAB:SetPoint("TOP", parent, 0, -12)
    frameAB:SetStatusBarColor(1,1,1,1)
    frameAB:SetFrameLevel(3)
	SP.smoothy:SmoothBar(frameAB)

    return frameAB;
end

function SmoothyPlate:ConstructElement_HealPredBar(parent)

    local frameHP = CreateFrame("StatusBar", "$parentHealPredBar", parent)
	frameHP:SetStatusBarTexture(SP.PRED_BAR_TEX)
	frameHP:GetStatusBarTexture():SetHorizTile(false)
	frameHP:SetWidth(131)
	frameHP:SetHeight(18)
	frameHP:SetPoint("TOP", parent, 0, -12)
    frameHP:SetStatusBarColor(1,1,1,1)
    frameHP:SetFrameLevel(2)
	SP.smoothy:SmoothBar(frameHP)

    return frameHP;
end

function SmoothyPlate:ConstructElement_PredSpark(parent)

    local framePS = CreateFrame("Frame", nil, parent)
    framePS:SetSize(3, 22)
    framePS:SetPoint("RIGHT", parent.HealthBar, 2, 1)
    framePS:SetBackdrop(SP.stdbd)
    framePS:SetBackdropColor(1,1,1,1)

    framePS:Hide()
    return framePS
end

function SmoothyPlate:ConstructElement_Name(parent)

    local frameN = parent:CreateFontString(nil, "OVERLAY")
	frameN:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -2)
	frameN:SetFont(SP.FONT, 12, "OUTLINE")
	frameN:SetJustifyH("LEFT")
	frameN:SetShadowOffset(1, -1)
	frameN:SetTextColor(1, 1, 1)
	frameN:SetText("Name")

    return frameN;
end

function SmoothyPlate:AddUnit(unitid)
    self.unitid = unitid;

    self:UpdateName();
    self:UpdateHealth();
    self:UpdateHealthColor();
    self:UpdatePower();
    self:UpdatePowerColor();
    self:UpdateCastBarMidway();

    self.sp:Show()
end

function SmoothyPlate:RemoveUnit()
    self.unitid = nil;
    self.sp.CastBar:Hide()
    self.sp:Hide()
end

--------Update Elements--------

local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitSelectionColor = UnitSelectionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local PowerBarColor = PowerBarColor
local GetUnitName = GetUnitName
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

function SmoothyPlate:UpdateName()
    if not self.unitid then return end

    local unitName = GetUnitName(self.unitid, false)
    if strlen(unitName) > 20 then
        unitName = strsub(unitName, 1, 20) .. "..."
    end

    self.sp.Name:SetText(unitName);

end

function SmoothyPlate:UpdateHealth()
    if not self.unitid then return end

    local currHealth, maxHealth = UnitHealth(self.unitid), UnitHealthMax(self.unitid)
    self.sp.HealthBar:SetMinMaxValues(0, maxHealth)
    self.sp.HealthBar:SetValue(currHealth)

    self.sp.HealthBar.pc:SetText(SP:percent(currHealth, maxHealth) .. "%")
    self.currHealth = currHealth
    self.health = maxHealth

    self:UpdateHealAbsorbPrediction()

end

function SmoothyPlate:UpdateHealthColor()
    if not self.unitid then return end

    local r,g,b; local a = 1;
    local classFileName = select(2, UnitClass(self.unitid))

    if UnitIsPlayer(self.unitid) and classFileName then
        local color = RAID_CLASS_COLORS[classFileName]
        r,g,b = color.r, color.g, color.b
    else
        r,g,b = UnitSelectionColor(self.unitid)
    end

    if r == nil or g == nil or b == nil then
        r = 0.9; g = 0.9; b = 0.1;
    end

    -- Set Color to Class- or Thread-Color | else we use the standard yellow
    self.sp.HealthBar:SetStatusBarColor(r,g,b,a)
    self.sp.HealthBar.back:SetBackdropColor(r,g,b,0.08)

end

function SmoothyPlate:UpdatePower()
    if not self.unitid then return end

    local currPower, maxPower = UnitPower(self.unitid), UnitPowerMax(self.unitid)
    self.sp.PowerBar:SetMinMaxValues(0, maxPower)
    self.sp.PowerBar:SetValue(currPower)

end

function SmoothyPlate:UpdatePowerColor()
    if not self.unitid then return end

    local powerType, _, r, g, b = UnitPowerType(self.unitid)
    if powerType then
        local color = PowerBarColor[powerType]
        r,g,b = color.r, color.g, color.b
    end

    -- Set Color to Powertype-Color or an alternative Power-Color
    self.sp.PowerBar:SetStatusBarColor(r,g,b,0.8)
    self.sp.PowerBar.back:SetBackdropColor(r,g,b,0.08)

end

local function UpdateFillBar(barWidth, previousTexture, bar, amount)
	if ( amount == 0 ) then
		return previousTexture;
	end

	bar:ClearAllPoints()
	bar:Point("TOPLEFT", previousTexture, "TOPRIGHT");
	bar:Point("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");

	bar:SetWidth(barWidth);

	return bar:GetStatusBarTexture();
end

local mathmax, UnitGetIncomingHeals, UnitGetTotalHealAbsorbs, UnitGetTotalAbsorbs = math.max, UnitGetIncomingHeals, UnitGetTotalHealAbsorbs, UnitGetTotalAbsorbs
function SmoothyPlate:UpdateHealAbsorbPrediction()
    if not self.unitid then return end

	local allIncomingHeal = UnitGetIncomingHeals(self.unitid) or 0
	local unitCurrentHealAbsorb = UnitGetTotalHealAbsorbs(self.unitid) or 0
    local totalAbsorb = UnitGetTotalAbsorbs(self.unitid) or 0
	local health, maxHealth = self.currHealth, self.health

	if(health < unitCurrentHealAbsorb) then
		unitCurrentHealAbsorb = health
	end

	local maxOverflow = 1
	if(health - unitCurrentHealAbsorb + allIncomingHeal > maxHealth * maxOverflow) then
		allIncomingHeal = maxHealth * maxOverflow - health + unitCurrentHealAbsorb
	end

    local showSpark = false
	if(health - unitCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
        showSpark = true
		if(allIncomingHeal > unitCurrentHealAbsorb) then
			totalAbsorb = mathmax(0, maxHealth - (health - unitCurrentHealAbsorb + allIncomingHeal))
		else
			totalAbsorb = mathmax(0, maxHealth - health)
		end
	end

    self.sp.PredSpark:Hide()

    self.currHealPred = allIncomingHeal
    if allIncomingHeal == 0 then
        self.sp.HealPredBar:SetMinMaxValues(0, self.health)
        self.sp.HealPredBar:SetValue(0)
    else
        self.sp.HealPredBar:SetMinMaxValues(0, self.health)
        if showSpark then
            self.sp.PredSpark:Show()
        end
        self.sp.HealPredBar:SetValue(allIncomingHeal)
    end

    self.currAbsorb = totalAbsorb
    if totalAbsorb == 0 then
        self.sp.AbsorbBar:SetMinMaxValues(0, self.health)
        self.sp.AbsorbBar:SetValue(0)
    else
        self.sp.AbsorbBar:SetMinMaxValues(0, self.health)
        if showSpark then
            self.sp.PredSpark:Show()
        end
        self.sp.AbsorbBar:SetValue(totalAbsorb)
    end

    local barWidth = self.sp.HealthBar:GetWidth()
    local previousTexture = self.sp.HealthBar:GetStatusBarTexture();
	previousTexture = UpdateFillBar(barWidth, previousTexture, self.sp.HealPredBar, allIncomingHeal);
	previousTexture = UpdateFillBar(barWidth, previousTexture, self.sp.AbsorbBar, totalAbsorb);

end

function SmoothyPlate:UpdateCastBarMidway()
    if not self.unitid then return end

    if UnitCastingInfo(self.unitid) then
        self:StartCasting(false)
	else
        if UnitChannelInfo(self.unitid) then
            self:StartCasting(true)
        end
	end

end

function SmoothyPlate:PrepareCast(text, texture, min, max, notInterruptible)
    if not self.unitid then return end

    self.sp.CastBar.bar:SetMinMaxValues(min, max)
    self.sp.CastBar.name:SetText(text)
    self.sp.CastBar.icon.tex:SetTexture(texture)
    self.sp.CastBar.icon.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    if notInterruptible then
        self.sp.CastBar.bar:SetStatusBarColor(SP:fromRGB(152,152,152,255))
        self.sp.CastBar.back:SetBackdropBorderColor(SP:fromRGB(152,152,152,45))
    else
        self.sp.CastBar.bar:SetStatusBarColor(SP:fromRGB(237,219,72,255))
        self.sp.CastBar.back:SetBackdropBorderColor(SP:fromRGB(237,219,72,45))
    end

end

-- Thanx to TidyPlates for this spell part | Hihi just stole it :)
local function OnUpdateCastBarForward(self)
		local currentTime = GetTime() * 1000
		self:SetValue(currentTime)
end

local function OnUpdateCastBarReverse(self)
	local currentTime = GetTime() * 1000
	local startTime, endTime = self:GetMinMaxValues()
	self:SetValue((endTime + startTime) - currentTime)
end

function SmoothyPlate:StartCasting(channeled)
    if not self.unitid then return end

    self:StopCasting()
    local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible
    if not channeled then
        name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unitid)
        self.sp.CastBar.bar:SetScript("OnUpdate", OnUpdateCastBarForward)
    else
        name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unitid)
        self.sp.CastBar.bar:SetScript("OnUpdate", OnUpdateCastBarReverse)
    end

    if isTradeSkill or not name or not startTime or not endTime then return end

    self:PrepareCast(text, texture, startTime, endTime, notInterruptible)
    self.sp.CastBar:Show()

end

function SmoothyPlate:StopCasting()
    self.sp.CastBar.bar:SetScript("OnUpdate", nil)
    self.sp.CastBar:Hide()

    if not self.unitid then return end

    -- Do we have to do something here?

end

-------------------------------
