local SP = LibStub("AceAddon-3.0"):NewAddon("SmoothyPlates", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0", "LibNameplateRegistry-1.0")
-- Info: The new Damn good Plates
-- Tastks: Setting Up new fancy smoothy sick damn good locking informative Nameplates
-- Autor: Max David aka Vènomstrikè

-- All Frames generated with SimpleUI

-- License: GNU General Public License version 2 (GPLv2)

-- Thanks to the WowAce Community for the help to get this AddOn done!


-- TODO 
	-- maybe new castbar overlay (looking up in tidyplates for making castbar invisible)
	-- smoothbarupdate enhance
	-- maybe cc bars are stacking
	-- maybe highlight
	-- combobar set middle, combobar bubbles
	-- cc bars float time
	-- trinket special spell icons
	-- (for leo) own debuffs

--------------Global Variables----------------
local accVersion = 1.5

local EMPTY_TEXTURE = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Empty"
local PURISTA_FONT = "Interface\\Addons\\SmoothyPlates\\Media\\Font\\Designosaur-Regular.ttf" -- Fonts\\ARIALN.TTF
local BANTO = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Glaze"
local HIGHLIGHT_TEXTURE = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\hl"

local InArena = false
local timerIDs = {}
local arenaPlates = {}
local activeStunns = {}
local activeInterrupts = {}
local spelllist = {}

-- Modules
local Specials = nil

-- Spells from DRData
local CCSpells = {

	--[[ INCAPACITATES ]]--
		[    99] = true, -- Incapacitating Roar (talent)
		-- Hunter
		[  3355] = true, -- Freezing Trap
		[ 19386] = true, -- Wyvern Sting
		-- Mage
		[   118] = true, -- Polymorph
		[ 28272] = true, -- Polymorph (pig)
		[ 28271] = true, -- Polymorph (turtle)
		[ 61305] = true, -- Polymorph (black cat)
		[ 61025] = true, -- Polymorph (serpent) -- FIXME: gone ?
		[ 61721] = true, -- Polymorph (rabbit)
		[ 61780] = true, -- Polymorph (turkey)
		[ 82691] = true, -- Ring of Frost
		[ 31661] = true, -- Dragon's Breath
		[157997] = true, -- Ice Nova
		-- Monk
		[115078] = true, -- Paralysis
		[123393] = true, -- Breath of Fire (Glyphed)
		[137460] = true, -- Ring of Peace -- FIXME: correct spellIDs?w
		-- Paladin
		[ 20066] = true, -- Repentance
		-- Priest
		[   605] = true, -- Dominate Mind
		[  9484] = true, -- Shackle Undead
		[ 64044] = true, -- Psychic Horror (Horror effect)
		[ 88625] = true, -- Holy Word: Chastise
		-- Rogue
		[  1776] = true, -- Gouge
		[  6770] = true, -- Sap
		-- Shaman
		[ 51514] = true, -- Hex
		-- Warlock
		[   710] = true, -- Banish
		[137143] = true, -- Blood Horror
		[  6789] = true, -- Mortal Coil
		-- Pandaren
		[107079] = true, -- Quaking Palm

	--[[ SILENCES ]]--
		-- Death Knight
		[108194] = true, -- Asphyxiate (if target is immune to stun)
		[ 47476] = true, -- Strangulate
		-- Druid
		[114237] = true, -- Glyph of Fae Silence
		-- Mage
		[102051] = true, -- Frostjaw
		-- Paladin
		[ 31935] = true, -- Avenger's Shield
		-- Priest
		[ 15487] = true, -- Silence
		-- Rogue
		[  1330] = true, -- Garrote
		-- Blood Elf
		[ 25046] = true, -- Arcane Torrent (Energy version)
		[ 28730] = true, -- Arcane Torrent (Mana version)
		[ 50613] = true, -- Arcane Torrent (Runic power version)
		[ 69179] = true, -- Arcane Torrent (Rage version)
		[ 80483] = true, -- Arcane Torrent (Focus version)

	--[[ DISORIENTS ]]--
		-- Druid
		[ 33786] = true, -- Cyclone
		-- Paladin
		[105421] = true, -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
		[ 10326] = true, -- Turn Evil
		-- Priest
		[  8122] = true, -- Psychic Scream
		-- Rogue
		[  2094] = true, -- Blind
		-- Warlock
		[  5782] = true, -- Fear -- probably unused
		[118699] = true, -- Fear -- new debuff ID since MoP
		[130616] = true, -- Fear (with Glyph of Fear)
		[  5484] = true, -- Howl of Terror (talent)
		[115268] = true, -- Mesmerize (Shivarra)
		[  6358] = true, -- Seduction (Succubus)
		-- Warrior
		[  5246] = true, -- Intimidating Shout (main target)

	--[[ STUNS ]]--
		-- Death Knight
		[108194] = true, -- Asphyxiate
		[ 91800] = true, -- Gnaw (Ghoul)
		[ 91797] = true, -- Monstrous Blow (Dark Transformation Ghoul)
		[115001] = true, -- Remorseless Winter
		-- Druid
		[ 22570] = true, -- Maim
		[  5211] = true, -- Mighty Bash
		[163505] = true, -- Rake (Stun from Prowl)
		-- Hunter
		[117526] = true, -- Binding Shot
		[ 24394] = true, -- Intimidation
		-- Mage
		[ 44572] = true, -- Deep Freeze
		-- Monk
		[119392] =   true, -- Charging Ox Wave
		[120086] = true, -- Fists of Fury
		[119381] =   true, -- Leg Sweep
		-- Paladin
		[   853] = true, -- Hammer of Justice
		[119072] = true, -- Holy Wrath
		[105593] = true, -- Fist of Justice
		-- Rogue
		[  1833] = true, -- Cheap Shot
		[   408] = true, -- Kidney Shot
		-- Shaman
		[118345] = true, -- Pulverize (Primal Earth Elemental)
		[118905] = true, -- Static Charge (Capacitor Totem)
		-- Warlock
		[ 89766] = true, -- Axe Toss (Felguard)
		[ 30283] = true, -- Shadowfury
		[ 22703] = true, -- Summon Infernal
		-- Warrior
		[132168] = true, -- Shockwave
		[132169] = true, -- Storm Bolt
		-- Tauren
		[ 20549] = true -- War Stomp
	}

local classtbl = {
	[62] = "Mage: Arcane",
	[63] = "Mage: Fire",
	[64] = "Mage: Frost",
	[65] = "Paladin: Holy",
	[66] = "Paladin: Protection",
	[70] = "Paladin: Retribution",
	[71] = "Warrior: Arms",
	[72] = "Warrior: Fury",
	[73] = "Warrior: Protection",
	[102] = "Druid: Balance",
	[103] = "Druid: Feral",
	[104] = "Druid: Guardian",
	[105] = "Druid: Restoration",
	[250] = "Death Knight: Blood",
	[251] = "Death Knight: Frost",
	[252] = "Death Knight: Unholy",
	[253] = "Hunter: Beast Mastery",
	[254] = "Hunter: Marksmanship",
	[255] = "Hunter: Survival",
	[256] = "Priest: Discipline",
	[257] = "Priest: Holy",
	[258] = "Priest: Shadow",
	[259] = "Rogue: Assassination",
	[260] = "Rogue: Combat",
	[261] = "Rogue: Subtlety",
	[262] = "Shaman: Elemental",
	[263] = "Shaman: Enhancement",
	[264] = "Shaman: Restoration",
	[265] = "Warlock: Affliction",
	[266] = "Warlock: Demonology",
	[267] = "Warlock: Destruction",
	[268] = "Monk: Brewmaster",
	[269] = "Monk: Windwalker",
	[270] = "Monk: Mistweaver",}

----------------------------------------------

function SP:OnInitialize() -- the initialize part 

	self:HASOS()

	self:print("AddOn succsessfully loaded!")

end

-----------------Method Part-----------------

function SP:HASOS() -- handle all shit on start 

	self:RegisterChatCommand("smp", "HandleChatCommand")

	self.db = LibStub("AceDB-3.0"):New("SPDB")
	self.db.RegisterCallback(self, "OnDatabaseShutdown", "SaveDB")

	if select(2, UnitClass("player")) == "ROGUE" or select(2, UnitClass("player")) == "DRUID" then
		CpFrame = self:CreateCpFrame()
		self:UNIT_COMBO_POINTS("start")
		self:RegisterEvent("UNIT_COMBO_POINTS")
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")	

	self:LNR_RegisterCallback("LNR_ON_NEW_PLATE");

	self.callbacks = LibStub("CallbackHandler-1.0"):New(self)

	self.smoothy = LibStub("LibSmoothStatusBar-1.0")

	-------- Modules ----------

	--self:EnableModule("Specials")

	--Specials = self:GetModule("Specials")

	---------------------------

end

function SP:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)

    self:handlePlate(plateFrame, plateData)

end

function SP:handlePlate(plateFrame, plateData)
	local newPlate = nil

	local bars = {}
	local regions = {}

	-- Look if Plate was already procceeded so we can go a step further and save work
	if not self:getSmoothFrame(plateFrame) then

		bars, regions = self:proccessBlizzBar(plateFrame, true)

		newPlate = self:getPreDefinedPlate(bars.health, regions.name:GetText())

	else

		bars, regions = self:proccessBlizzBar(plateFrame, false)

		newPlate = self:getSmoothFrame(plateFrame)

	end

	-- update the plate and hook scripts
	newPlate.name:SetText(regions.name:GetText())
	newPlate.health:SetMinMaxValues(bars.health:GetMinMaxValues())
	newPlate.health:SetStatusBarColor(bars.health:GetStatusBarColor())
	newPlate.health:SetValue(bars.health:GetValue())
	newPlate.pc:SetText(percent(bars.health:GetValue(), select(2, bars.health:GetMinMaxValues())) .. "%")
	bars.health:HookScript("OnValueChanged", function(self, value) SP:smoothBarUpdate(self, value, newPlate.health) end )
	bars.cast:HookScript("OnShow", function(self) SP:OnShowCastbar(self) end)
	bars.cast:HookScript("OnHide", function(self) SP:OnHideCastbar(self) end)
	bars.cast:HookScript("OnValueChanged", function(self) SP:OnUpdateCastbar(self) end)

	local unitID = self:getUnitIDFromName(plateData.name)
	if unitID then

		arenaPlates[unitID] = plateFrame

		self:clearCC(plateFrame)

		if activeStunns[unitID] then
			self:CCRecovered(unitID, true)
		end

		if activeInterrupts[unitID] then
			self:CCRecovered(unitID, false)
		end

	end

end

function SP:proccessBlizzBar(plateFrame, setVisible)
	
	if setVisible then

		-- making blizzards plates invisible (with code block from TidyPlates)
		local bars, regions = {}, {}
		local bargroup, namegroup = plateFrame:GetChildren()
		local health, cast = bargroup:GetChildren()

		bars.health = health
		bars.cast = cast
		bars.group = bargroup

		health.parentPlate = plateFrame		-- Needed for OnHealthUpdate Hook
		cast.parentPlate = plateFrame		-- Needed for UpdateCastBar Hook

		-- Region References
		regions.threatglow,
		regions.healthborder,
		regions.highlight,
		regions.level,
		regions.skullicon,
		regions.raidicon,
		regions.eliteicon
			= bargroup:GetRegions()

		regions.name
			= namegroup:GetRegions()

		regions.castborder,
		regions.castnostop,
		regions.spellicon,
		regions.spelltext,
		regions.spellshadow
			= select(2, cast:GetRegions())

		cast.spellshadow = regions.spellshadow
		cast.castnostop = regions.castnostop
		cast.icon = regions.spellicon

		-- Make Blizzard Plate invisible
		health:SetStatusBarTexture(EMPTY_TEXTURE)
		cast:SetStatusBarTexture(EMPTY_TEXTURE)

		--health:Hide()
		namegroup:Hide()

		regions.threatglow:SetTexture(nil)
		regions.healthborder:Hide()
		regions.highlight:SetTexture(nil)
		regions.level:SetWidth( 000.1 )
		regions.level:Hide()
		regions.skullicon:SetTexture(nil)
		--regions.skullicon:SetAlpha(0)
		regions.raidicon:SetAlpha( 0 )
		--regions.eliteicon:SetTexture(nil)
		regions.eliteicon:SetAlpha(0)

		regions.name:Hide()

		regions.castborder:SetTexture(nil)
		regions.castnostop:SetTexture(nil)
		regions.spellicon:SetTexCoord( 0, 0, 0, 0 )
		regions.spellicon:SetWidth(.001)
		regions.spellicon:Hide()
		regions.spellshadow:SetTexture(nil)
		regions.spellshadow:Hide()
		regions.spelltext:Hide()

		return bars, regions

	else
		local bars, regions = {}, {}
			local bargroup, namegroup = plateFrame:GetChildren()
			local health, cast = bargroup:GetChildren()

			bars.health = health
			bars.cast = cast
			bars.group = bargroup

			-- Region References
			regions.threatglow,
			regions.healthborder,
			regions.highlight,
			regions.level,
			regions.skullicon,
			regions.raidicon,
			regions.eliteicon
				= bargroup:GetRegions()		

			regions.name
				= namegroup:GetRegions()

			regions.castborder,
			regions.castnostop,
			regions.spellicon,
			regions.spelltext,
			regions.spellshadow
				= select(2, cast:GetRegions())

			regions.spellicon:Hide()

			health.parentPlate = plateFrame
			cast.parentPlate = plateFrame

			regions.name = namegroup:GetRegions()

		return bars, regions
	end

end

function SP:getSmoothFrame(plate)
	
	if not plate then return nil end

	return select(1, select(1, plate:GetChildren()):GetChildren()):GetChildren() or nil

end

function SP:OnShowCastbar(bar)
	local cast = self:getSmoothFrame(bar.parentPlate).cast

	bar.spellshadow:Hide()
	if bar.castnostop:IsShown() then self:getSmoothFrame(bar.parentPlate).cast.bar:SetStatusBarColor(1, 0, 0) else self:getSmoothFrame(bar.parentPlate).cast.bar:SetStatusBarColor(fromRGB(255, 255, 0)) end

	cast.icon:SetBackdrop(SP:getBackdrop(bar.icon:GetTexture()))
	cast.bar:SetMinMaxValues(bar:GetMinMaxValues())

	self:getSmoothFrame(bar.parentPlate).cast:Show()

end

function SP:OnHideCastbar(bar)
	
	self:getSmoothFrame(bar.parentPlate).cast:Hide()
	
end

function SP:OnUpdateCastbar(bar)

	self:getSmoothFrame(bar.parentPlate).cast.bar:SetValue(bar:GetValue())
	
end

function SP:smoothBarUpdate(bar, value, newBar)

	if value <= 1 then return end
	
	if newBar.lv == bar:GetValue() then return end

	newBar:SetMinMaxValues(bar:GetMinMaxValues())

	newBar:SetValue(value);
	newBar.lv = value;

	newBar:GetParent().pc:SetText(percent(value, select(2, newBar:GetMinMaxValues())) .. "%")

end

function SP:plateWasKilled(name, barc, barmm, value)
	
	-- setting the newFrame to the bottom, smooth it down to zero and hide it (only a nice feature)
	local newFrame = self:getPreDefinedPlate(UIParent, name)

	newFrame:SetSize(150, 40)

	newFrame.health:SetMinMaxValues(0, 1)
	newFrame.pc:SetText("X DEFEATED X")
	newFrame.pc:SetTextColor(1, 0, 0)

	newFrame.health:GetParent():SetPoint("CENTER", UIParent, 0, -220)
	     
	newFrame.health:SetValue(value);
	SP:FadeInFrame(newFrame, 0.5);
	SP:ScheduleTimer("FadeOutFrame", 3, newFrame, 2);

end

function SP:FadeOutFrame(frame, sec)

	local substract = 1 / (sec / 0.02)

	frame.fotid = self:ScheduleRepeatingTimer(function() if frame:GetAlpha() == 0 then self:CancelTimer(frame.fotid); frame:Hide(); end frame:SetAlpha(frame:GetAlpha()-substract) end, 0.02)

end

function SP:FadeInFrame(frame, sec)
	
	frame:SetAlpha(0)

	local add = 1 / (sec / 0.02)

	frame.fotid = self:ScheduleRepeatingTimer(function() if frame:GetAlpha() == 1 then self:CancelTimer(frame.fotid) end frame:SetAlpha(frame:GetAlpha()+add) end, 0.02)

end

function SP:UNIT_COMBO_POINTS(eventname)
	if not CpFrame then return end

	local currentCP = GetComboPoints("player", "target")

	if not currentCP then currentCP = 0 end
	
	CpFrame.cp:SetValue(currentCP*100)

	if currentCP == 0 then CpFrame:SetSize(162, 5); CpFrame.cp:Hide() else CpFrame:SetSize(182, 16); CpFrame.cp:Show() end

end

function SP:CreateCpFrame()
	
	local frame = CreateFrame("Frame", "CpFrame", UIParent) 
	frame:SetSize(182, 16) 
	frame:SetPoint("CENTER", 0 , 0)
	frame:SetMovable(true)
	texture = frame:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.8) 
	frame.background = texture
	frame:SetUserPlaced(true)

	-- moving frame
	frame.resize = CreateFrame("Frame", nil, frame) 
	frame.resize:SetSize(50, 10) 
	frame.resize:SetPoint("TOP", 0, 15) 
	texturers = frame.resize:CreateTexture() 
	texturers:SetAllPoints() 
	texturers:SetTexture(0,0,0,1) 
	frame.resize.background = texturers
	frame.resize:EnableMouse(true)
	frame.resize:SetScript("OnMouseDown", function (self, value) CpFrame:StartMoving() end) 
	frame.resize:SetScript("OnMouseUp", function (self, value) CpFrame:StopMovingOrSizing() end)
	frame.resize:Hide()

	frame.cp = CreateFrame("StatusBar", nil, frame)
	frame.cp:SetStatusBarTexture(BANTO)
	frame.cp:GetStatusBarTexture():SetHorizTile(false)
	frame.cp:SetWidth(180)
	frame.cp:SetHeight(14)
	frame.cp:SetPoint("CENTER", frame, 0, 0)
	frame.cp:SetStatusBarColor(1, 0, 0, 1)
	frame.cp:SetMinMaxValues(0, 500)
	frame.cp:SetValue(0)

	frame.cp1 = CreateFrame("Frame", nil, frame.cp) 
	frame.cp1:SetSize(1, 14) 
	frame.cp1:SetPoint("LEFT", 36, 0) 
	texture = frame.cp1:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0, 0, 0, 0.8)
	frame.cp1.background = texture

	frame.cp2 = CreateFrame("Frame", nil, frame.cp) 
	frame.cp2:SetSize(1, 14) 
	frame.cp2:SetPoint("LEFT", 72, 0) 
	texture = frame.cp2:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0, 0, 0, 0.8)
	frame.cp2.background = texture

	frame.cp3 = CreateFrame("Frame", nil, frame.cp) 
	frame.cp3:SetSize(1, 14) 
	frame.cp3:SetPoint("LEFT", 108, 0) 
	texture = frame.cp3:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0, 0, 0, 0.8)
	frame.cp3.background = texture

	frame.cp4 = CreateFrame("Frame", nil, frame.cp) 
	frame.cp4:SetSize(1, 14) 
	frame.cp4:SetPoint("LEFT", 144, 0) 
	texture = frame.cp4:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0, 0, 0, 0.8)
	frame.cp4.background = texture

	frame.cp5 = CreateFrame("Frame", nil, frame.cp) 
	frame.cp5:SetSize(4, 14) 
	frame.cp5:SetPoint("LEFT", 176, 0) 
	texture = frame.cp5:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(fromRGB(255, 255, 0))
	frame.cp5.background = texture

	return frame

end

function SP:getPreDefinedPlate(plate, name)

	local frame = CreateFrame("Frame", nil, plate) 
	frame:SetSize(140, 32) 
	frame:SetPoint("CENTER", 12.5, 10) 
	texture = frame:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.7) 
	frame.background = texture
	
	frame.cast = CreateFrame("Frame", nil, frame) 
	frame.cast:SetSize(140, 16) 
	frame.cast:SetPoint("BOTTOM", 0, -18) 
	texture = frame.cast:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 
	frame.cast.background = texture

	frame.cast.bar = CreateFrame("StatusBar", nil, frame.cast)
	frame.cast.bar:SetStatusBarTexture(BANTO)
	frame.cast.bar:GetStatusBarTexture():SetHorizTile(false)
	frame.cast.bar:SetWidth(136)
	frame.cast.bar:SetHeight(12)
	frame.cast.bar:SetPoint("CENTER", 0, 0)
	frame.cast.bar:SetStatusBarColor(fromRGB(255, 255, 0))

	frame.cast.icon = CreateFrame("Frame", nil, frame.cast) 
	frame.cast.icon:SetSize(16, 16)
	frame.cast.icon:SetPoint("LEFT", -16, 0)
	frame.cast.icon:SetBackdrop(SP:getBackdrop(SP:getIcon(47528)))

	frame.cast:Hide()

	frame.l = CreateFrame("Frame", nil, frame) 
	frame.l:SetSize(1, 32) 
	frame.l:SetPoint("LEFT", 0, 0) 
	texture = frame.l:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1)

	frame.r = CreateFrame("Frame", nil, frame) 
	frame.r:SetSize(1, 32) 
	frame.r:SetPoint("RIGHT", 0, 0) 
	texture = frame.r:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 

	frame.t = CreateFrame("Frame", nil, frame) 
	frame.t:SetSize(140, 1) 
	frame.t:SetPoint("TOP", 0, 0) 
	texture = frame.t:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 

	frame.b = CreateFrame("Frame", nil, frame) 
	frame.b:SetSize(140, 1) 
	frame.b:SetPoint("BOTTOM", 0, 0) 
	texture = frame.b:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 

	-- Becuase specials was disabled we dont need this anymore
	--frame.slots = {}
	--frame.slots[1] = self:createSpecialSlot(frame.b, "RIGHT", -9, 0)
	--frame.slots[2] = self:createSpecialSlot(frame.b, "RIGHT", -9, -17)
	--frame.slots[3] = self:createSpecialSlot(frame.b, "RIGHT", -9, -34)
 	--frame.trinket = self:createSpecialSlot(frame.t, "RIGHT", 1, 0)
	--frame.slotsInit = false

	frame.highlight = CreateFrame("Frame", nil, frame) 
	frame.highlight:SetSize(142, 37)
	frame.highlight:SetPoint("CENTER", 0 , 0) 

	frame.stunned = CreateFrame("Frame", nil, frame)
	frame.stunned:SetSize(35, 35) 
	frame.stunned:SetPoint("LEFT", frame, -37, 0)
	frame.stunned:Hide()
	frame.tid = nil

	frame.cced = CreateFrame("Frame", nil, frame)
	frame.cced:SetSize(35, 35) 
	frame.cced:SetPoint("RIGHT", frame, 37, 0)
	frame.cced:Hide()
	frame.tid = nil

	frame.name = frame.t:CreateFontString(nil, "OVERLAY")
	frame.name:SetPoint("LEFT", frame, "LEFT", 6, 16.5)
	frame.name:SetFont(PURISTA_FONT, 11, "OUTLINE")
	frame.name:SetJustifyH("LEFT")
	frame.name:SetShadowOffset(1, -1)
	frame.name:SetTextColor(1, 1, 1)
	frame.name:SetText(name)

	-- Health Bar
	frame.health = CreateFrame("StatusBar", nil, frame)
	frame.health:SetStatusBarTexture(BANTO)
	frame.health:GetStatusBarTexture():SetHorizTile(false)
	frame.health:SetWidth(131)
	frame.health:SetHeight(20)
	frame.health:SetPoint("CENTER", frame, 0, -3)
	frame.health.tid = 0;
	frame.health.inUse = false;
	frame.health.lv = 0
	self.smoothy:SmoothBar(frame.health)

	frame.pc = frame.health:CreateFontString(nil, "OVERLAY")
	frame.pc:SetPoint("CENTER", frame.health, 0, 0)
	frame.pc:SetFont(PURISTA_FONT, 11, "OUTLINE")
	frame.pc:SetJustifyH("LEFT")
	frame.pc:SetShadowOffset(1, -1)
	frame.pc:SetTextColor(1, 1, 1)
	frame.pc:SetText("100%")

	return frame

end

function SP:createSpecialSlot(plate, relativeTo, x, y)
	
	local h, w = 16, 16

	local frame = CreateFrame("Frame", nil, plate) 
	frame:SetSize(w, h) 
	frame:SetPoint(relativeTo, y, x) 
	frame:SetBackdrop(self:getBackdrop(select(3, GetSpellInfo(59752))))
	
	frame.cd = CreateFrame("Frame", nil, frame) 
	frame.cd:SetSize(w, h-6) 
	frame.cd:SetPoint("BOTTOM", 0, 0) 
	texture = frame.cd:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.6) 
	frame.cd.background = texture

	frame.tid = nil
	frame.id = 0

	frame.l = CreateFrame("Frame", nil, frame) 
	frame.l:SetSize(1, h) 
	frame.l:SetPoint("LEFT", 0, 0) 
	texture = frame.l:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1)

	frame.r = CreateFrame("Frame", nil, frame) 
	frame.r:SetSize(1, h) 
	frame.r:SetPoint("RIGHT", 0, 0) 
	texture = frame.r:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 

	frame.t = CreateFrame("Frame", nil, frame) 
	frame.t:SetSize(w, 1) 
	frame.t:SetPoint("TOP", 0, 0) 
	texture = frame.t:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 

	frame.b = CreateFrame("Frame", nil, frame) 
	frame.b:SetSize(w, 1) 
	frame.b:SetPoint("BOTTOM", 0, 0) 
	texture = frame.b:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 

	frame:Hide()

	return frame

end

function SP:HandleChatCommand(cmd) -- defines what to do when a chat command is typed 

	if cmd == "" then
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
		self:print("Possible SmoothyPlates Commands:")
		self:print("   - /smp ? | Help")
		self:print("   - /smp cpmove | Move the ComboPoint Bar")
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
	elseif cmd == "cpmove" then
		if CpFrame.resize:IsShown() then
			CpFrame.resize:Hide()
		else
			CpFrame.resize:Show()	
		end
	else
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
		self:print("Possible SmoothyPlates Commands:")
		self:print("   - /smp ? | Help")
		self:print("   - /smp cpmove | Move the ComboPoint Bar")
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
	end

end

function SP:HandleFirstLoad() -- Does the things that must be done at the first load of the addon 

	--

end

function SP:SaveDB() -- saves all infos gathered to the DB 
	
	--

end

function SP:CreateInfoFrame() -- creates the Info Frame 

	frame = CreateFrame("Frame", "InfoFrame", UIParent) 
	frame:SetSize(150, 70) 
	frame:SetPoint("CENTER") 
	texture = frame:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.4) 
	frame.background = texture
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetBackdropBorderColor(0, 0, 0, 0.9)

	-- moving frame
	frame.resize = CreateFrame("Frame", "InfoFrame_resize", frame) 
	frame.resize:SetSize(150, 20) 
	frame.resize:SetPoint("TOP", 0, 35) 
	texturers = frame.resize:CreateTexture() 
	texturers:SetAllPoints() 
	texturers:SetTexture(0,0,0,1) 
	frame.resize.background = texturers
	frame.resize:EnableMouse(true)
	frame.resize:SetScript("OnMouseDown", function (self, value) frame:StartMoving() end) 
	frame.resize:SetScript("OnMouseUp", function (self, value) frame:StopMovingOrSizing() end)
	frame.resize:Hide()

	-- rating fonts
	frame.rs = frame.resize:CreateFontString(nil, "OVERLAY")
	frame.rs:SetPoint("LEFT", frame.resize, "LEFT", 10, 0)
	frame.rs:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
	frame.rs:SetJustifyH("LEFT")
	frame.rs:SetShadowOffset(1, -1)
	frame.rs:SetTextColor(1, 1, 1)
	frame.rs:SetText("Click to move")
	
	-- InfoFrame Button
	frame.b = CreateFrame("Button", "InfoFrameB", frame, "UIPanelButtonTemplate")
	frame.b:SetSize(160, 20)
	frame.b:SetPoint("TOP", frame, 0, 12)
	frame.b.text = _G["InfoFrameB" .. "Text"]
	frame.b.text:SetText("Statistics")
	frame.b:SetScript("OnClick", function() self:HandleChatCommand() end )
	--frame.b:Disable()
	
 return frame 

end

function SP:setUpTimerBar(name, clampTo, height, width, forTime, length, y, x)

	local newBar = CreateFrame("Frame", nil, clampTo) 
	newBar:SetSize(width, height+2) 
	newBar:SetPoint("TOP", clampTo, y, x) 
	texture = newBar:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 
	newBar.background = texture
	newBar.tid = nil

	newBar.bar = CreateFrame("StatusBar", nil, newBar)
	newBar.bar:SetStatusBarTexture(BANTO)
	newBar.bar:GetStatusBarTexture():SetHorizTile(false)
	newBar.bar:SetWidth(width-1)
	newBar.bar:SetHeight(height-1)
	newBar.bar:SetPoint("CENTER", newBar, 0, 0)

	newBar.time = newBar.bar:CreateFontString(nil, "OVERLAY")
	newBar.time:SetPoint("CENTER", newBar.bar, 0, 11)
	newBar.time:SetFont(PURISTA_FONT, 9, "OUTLINE")
	newBar.time:SetJustifyH("LEFT")
	newBar.time:SetTextColor(fromRGB(255,255,255))
	newBar.time:SetText("4 Sec")

	newBar.bar:SetMinMaxValues(0, (length*10))
	newBar.bar:SetValue(forTime*10)
	newBar.bar:SetStatusBarColor(fromRGB(0,0,200))


	newBar.tid = self:ScheduleRepeatingTimer(function() 
		if newBar.bar:GetValue() <= 1 
			then newBar.bar:Hide(); self:CancelTimer(newBar.tid); 
		end 
		newBar.bar:SetValue(newBar.bar:GetValue()-1); newBar.time:SetText(SP:getTimeText(newBar.bar:GetValue())) 
	end, 0.1)

end

function SP:getTimeText(milli)

	if milli >= 0 and milli <= 10 then
		return "1 Sec"
	elseif milli >= 10 and milli <= 20 then
		return "2 Sec"
	elseif milli >= 20 and milli <= 30 then
		return "3 Sec"
	elseif milli >= 30 and milli <= 40 then
		return "4 Sec"
	elseif milli >= 40 and milli <= 50 then
		return "5 Sec"
	elseif milli >= 50 and milli <= 60 then
		return "6 Sec"
	elseif milli >= 60 and milli <= 70 then
		return "7 Sec"
	elseif milli >= 70 and milli <= 80 then
		return "8 Sec"
	elseif milli >= 80 and milli <= 90 then
		return "9 Sec"
	elseif milli >= 90 and milli <= 100 then
		return "10 Sec"
	else
		return "Sleep"
	end

end

---------------CC Tracker-----------------

function SP:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())

	if instanceType == "arena" then
		InArena = true
	else
		InArena = false
	end

end

function SP:COMBAT_LOG_EVENT_UNFILTERED(event, timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	if not InArena then return end
	--print(timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	if not auraType then return end

	--print(timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)

	if not destGUID or destGUID == "" then return end
	unitID = self:getUnitIDFromName(select(6, GetPlayerInfoByGUID(destGUID)))

	if eventType == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then

		--isEnemy = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE
		--isPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER or bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER

		if self:isCC(spellID) then
			if unitID then
				name, z, icon, z, z, z, expires, z, z, z, spellIDNew, z, z, z, z, z = UnitDebuff(unitID, spellName)
				if spellIDNew == spellID then			
					self:CCFound(destGUID, sourceGUID, unitID, icon, expires, spellID, true)
					self.callbacks:Fire("ENEMY_STUN", destGUID, sourceGUID, unitID, icon, expires, spellID)
				end
			end
		end

	elseif eventType == "SPELL_AURA_REMOVED" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then
		if not self:isValidEnemy(unitID) then return end
		-- if in stealth nameplate is not cached and it cant be accessed so we return also when no active stun is set but a aura was removed
		if not activeStunns[unitID] then return end

		if activeStunns[unitID].spellID == spellID then	
			self:StunFaded(self:getSmoothFrame(arenaPlates[unitID]).stunned, unitID)
			self.callbacks:Fire("ENEMY_STUN_FADED", self:getSmoothFrame(arenaPlates[unitID]).stunned, unitID )
		end

	elseif eventType == "SPELL_INTERRUPT" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then
		if not self:isValidEnemy(unitID) then return end
		self:CCFound( destGUID, sourceGUID, unitID, nil, 3.8, spellID, false )
		self.callbacks:Fire("ENEMY_INTERRUPT", destGUID, sourceGUID, unitID, nil, 3.8, spellID)
	end

end

function SP:CCFound( destGUID, sourceGUID, unitID, icon, expires, spellID, isStunn )

	-- expires - GetTime()
	if isStunn then

		if not activeStunns[unitID] or activeStunns[unitID].expires < (expires - GetTime()) then

			if arenaPlates[unitID] then self:StunFaded(self:getSmoothFrame(arenaPlates[unitID]).stunned, unitID) end

			activeStunns[unitID] =
			{
				["destGUID"] = destGUID,
				["sourceGUID"] = sourceGUID,
				["unitID"] = unitID,
				["icon"] = icon,
				["expires"] = expires,
				["spellID"] = spellID,
				["dur"] = (expires - GetTime())
			}

			self:ApplyStun(unitID)

		else 

			self:StunDodged(sourceGUID, spellID, self:getSmoothFrame(arenaPlates[unitID]).stunned)

		end
	else

		self:InterruptFaded(self:getSmoothFrame(arenaPlates[unitID]).cced, unitID)

		activeInterrupts[unitID] =
		{
			["destGUID"] = destGUID,
			["sourceGUID"] = sourceGUID,
			["unitID"] = unitID,
			["icon"] = icon,
			["expires"] = (expires + GetTime()),
			["spellID"] = spellID,
			["dur"] = expires
		}

		self:ApplyInterrupt(unitID)

	end

end

function SP:CCRecovered(unitID, isStunn)
	
	if isStunn then

		self:ApplyStun(unitID)

	else

		self:ApplyInterrupt(unitID)

	end

end

function SP:ApplyStun( unitID )

	if self:getSmoothFrame(arenaPlates[unitID]) then

		local stun = activeStunns[unitID]

		local stunFrame = self:getSmoothFrame(arenaPlates[unitID]).stunned
		self:setUpTimerBar(UnitName(unitID)..stun.spellID, stunFrame, 10, 35, stun.expires - GetTime(), stun.dur, 0, 13)
		stunFrame:SetBackdrop(self:getBackdrop(stun.icon))
		stunFrame:Show();
		stunFrame.tid = self:ScheduleTimer(function() SP:StunFaded(stunFrame, unitID) end, stun.expires - GetTime())

	end

end

function SP:ApplyInterrupt( unitID )

	-- 47528 mind freeze for interrupt icon
	if self:getSmoothFrame(arenaPlates[unitID]) then

		local interrupt = activeInterrupts[unitID]

		local ccFrame = self:getSmoothFrame(arenaPlates[unitID]).cced
		self:setUpTimerBar(unitID..interrupt.spellID, ccFrame, 10, 35, interrupt.expires - GetTime(), interrupt.dur, 0, 13)
		
		ccFrame:SetBackdrop(self:getBackdrop(select(3, GetSpellInfo(47528))))
		ccFrame:Show();
		ccFrame.tid = self:ScheduleTimer(function() SP:InterruptFaded(ccFrame, unitID) end, interrupt.expires - GetTime())

	end

end

function SP:StunDodged(GUID, spellID, stunFrame)
	
	local frame = CreateFrame("Frame", nil, stunFrame:GetParent()) 
	frame:SetSize(30, 45)
	frame:SetPoint("CENTER", -132 , 7)
	texture = frame:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.8)
	frame.background = texture

	frame.n = frame:CreateFontString(nil, "OVERLAY")
	frame.n:SetPoint("TOP", frame, 1, -2)
	frame.n:SetFont(PURISTA_FONT, 7, "OUTLINE")
	frame.n:SetJustifyH("LEFT")
	frame.n:SetShadowOffset(1, -1)
	frame.n:SetTextColor(1, 1, 1)
	frame.n:SetText("")

	frame.ico = CreateFrame("Frame", nil, frame)
	frame.ico:SetSize(25, 25) 
	frame.ico:SetPoint("CENTER", frame, 0, 0)
	frame.ico:SetBackdrop(self:getBackdrop(select(3, GetSpellInfo(spellID))))

	frame.d = frame:CreateFontString(nil, "OVERLAY")
	frame.d:SetPoint("BOTTOM", frame, 1, 2)
	frame.d:SetFont(PURISTA_FONT, 7, "OUTLINE")
	frame.d:SetJustifyH("LEFT")
	frame.d:SetShadowOffset(1, -1)
	frame.d:SetTextColor(1, 0, 0)
	frame.d:SetText("DODGE")

	local _, classFilename, _, _, _, name, _ = GetPlayerInfoByGUID(GUID)
	local col = RAID_CLASS_COLORS[classFilename]
	if not col then frame:Hide(); return end
	frame.n:SetTextColor(col.r, col.g, col.b)
	frame.n:SetText(string.sub(name, 1, 7))


	self:FadeInFrame(frame, 0.4)
	self:ScheduleTimer(function() SP:FadeOutFrame(frame, 0.4) end, 1.8)

	-- maybe setting frame to nil?

end

function SP:StunFaded(stunFrame, unitID)

	stunFrame:Hide();
	stunFrame.tid = nil;
	activeStunns[unitID] = nil

end

function SP:InterruptFaded(ccFrame, unitID)

	ccFrame:Hide();
	ccFrame.tid = nil;
	activeInterrupts[unitID] = nil

end

function SP:clearCC(plateFrame)
	
	local ccFrame = self:getSmoothFrame(plateFrame).cced
	local stunFrame = self:getSmoothFrame(plateFrame).stunned

	ccFrame:Hide()
	stunFrame:Hide()
	self:CancelTimer(ccFrame.tid)
	self:CancelTimer(stunFrame.tid)
	ccFrame.tid = nil;
	stunFrame.tid = nil;


	local ccBar = ccFrame:GetChildren()
	if not ccBar then return end
	local stunBar = stunFrame:GetChildren()
	if not stunBar then return end
	self:CancelTimer(ccBar.tid)
	self:CancelTimer(stunBar.tid)
	ccBar:Hide()
	stunBar:Hide()
	ccBar = nil
	stunBar = nil

end

function SP:isCC( spellID )
	
	return CCSpells[spellID] or false

end

function SP:getUnitIDFromName(unitName)
	
	num = 0
	while num < 5 do
		num = num + 1
		an = UnitName("arena"..tostring(num))
		if an == unitName then return ("arena"..tostring(num)) end
	end

	if UnitName("target") == unitName then return "target" end

	return nil

end

function SP:isValidEnemy( unitID )
	
	if unitID == "arena1" or unitID == "arena2" or unitID == "arena3" or unitID == "arena4" or unitID == "arena5" or unitID == "target" then return true end
	return false

end

---------------Misc Methods-----------------

function SP:getBackdrop(path) -- gets an bockdrop object with the image from the path as the background 
	backdropS = {
	  -- path to the background texture
	  bgFile = path,
	  -- true to repeat the background texture to fill the frame, false to scale it
	  tile = false,
	  -- size (width or height) of the square repeating background tiles (in pixels)
	  tileSize = 20
	}

	return backdropS

end

function SP:print(msg) -- the print funktion with the Red VFrame before every chat msg 

	print("|cffff0020SmoothyPlates|r: " .. msg)

end

function SP:getIcon(id, isItem)

	isItem = isItem or nil

	if isItem then
		local rv = select(10, GetItemInfo(id))
		return rv
	else
		local rv = select(3, GetSpellInfo(id))
		return rv
	end

end

function SP:getMilliEndTime(sec)

	return sec*1000 + GetTime()

end

function SP:MilliToSeconds(milli)
	
	return milli/1000 - GetTime()

end

---------------Functional Methods-----------------

function percent(is, from)
	
	return round((is / from) * 100)

end

function round(n) -- rounds a value 

    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)

end

function contains(tbl, value) -- returns true if the value is existent in the given tbl 

	for i,n in pairs(tbl) do
		if n == value then return true end
	end

	return false
	
end

function split(inputstr, sep, tbl) -- splits a string 

        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end

        if tbl then return t else return t[1] end

end

function fromRGB(r, g, b)

	local rn = tonumber("0."..round((r/255) * 100))
	local gn = tonumber("0."..round((g/255) * 100))
	local bn = tonumber("0."..round((b/255) * 100))

	if r >= 251 then rn = 1 end
	if g >= 251 then gn = 1 end
	if b >= 251 then bn = 1 end

	return rn, gn, bn, 1

end

function getIndex(tbl, value) -- returns the index where the value is in the table 
	
	for i,n in pairs(tbl) do
		if n == value then return i end
	end

end

----------------------------------------------