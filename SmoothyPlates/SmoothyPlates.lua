local SP = LibStub("AceAddon-3.0"):NewAddon("SmoothyPlates", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0", "LibNameplateRegistry-1.0")
-- Info: The new Damn good Plates
-- Tastks: Setting Up new fancy smoothy sick damn good locking informative Nameplates
-- Autor: Max David aka Vènomstrikè

-- All Frames generated with SimpleUI

-- License: GNU General Public License version 2 (GPLv2)

-- Thanks to the WowAce Community for the help to get this AddOn done!


-- TODO 
	-- maybe new castbar overlay (looking up in tidyplates for making castbar invisible)

--------------Global Variables----------------
local accVersion = 1.5

local EMPTY_TEXTURE = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Empty"
local PURISTA_FONT = "Interface\\Addons\\SmoothyPlates\\Media\\Font\\Purista-Medium.ttf"
local BANTO = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\BantoBar"
local HIGHLIGHT_TEXTURE = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\hl"

local ActivePlates = {}
local ActiveStunns = {}
local timerIDs = {}

local killedPlates = {}

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

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self:LNR_RegisterCallback("LNR_ON_NEW_PLATE");
    self:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE");
    self:LNR_RegisterCallback("LNR_ON_TARGET_PLATE_ON_SCREEN");

end

function SP:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)

	if not plateData.reaction == "HOSTILE" or not plateData.reaction == "NEUTRAL" then return end

    self:handlePlate(plateFrame)
    ActivePlates[plateFrame:GetName()] = plateFrame

end

function SP:handlePlate(plateFrame)
	local newPlate = nil

	-- making blizzards plates invisible (with code block from TidyPlates)
	local bars, regions = {}, {}
		local bargroup, namegroup = plateFrame:GetChildren()
		local health, cast = bargroup:GetChildren()

		bars.health = health
		bars.cast = cast
		bars.group = bargroup

		health.parentPlate = plateFrame
		cast.parentPlate = plateFrame

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


	for o, i in pairs(regions) do 
		i:Hide()
	end

	health:SetStatusBarTexture(EMPTY_TEXTURE)
	--cast:SetStatusBarTexture(EMPTY_TEXTURE)
	regions.threatglow:SetTexture(nil)

	newPlate = self:getSmoothFrame(plateFrame)

	-- checking if SmoothFrame exists
	if bars.health:GetNumChildren() == 0 then 
		newPlate = self:getPreDefinedPlate(bars.health, regions.name:GetText())
	end

	-- update the plate and hook scripts
	newPlate.name:SetText(regions.name:GetText())
	newPlate.health:SetMinMaxValues(bars.health:GetMinMaxValues())
	newPlate.health:SetStatusBarColor(bars.health:GetStatusBarColor())
	newPlate.health:SetValue(bars.health:GetValue())
	newPlate.pc:SetText(percent(newPlate.health:GetValue(), select(2, newPlate.health:GetMinMaxValues())) .. "%")
	bars.health:HookScript("OnValueChanged", function(self, value) SP:smoothBarUpdate(self, value) end )

end

function SP:getSmoothFrame(plate)
	
	if not plate then return nil end

	return select(1, select(1, plate:GetChildren()):GetChildren()):GetChildren()

end

function SP:smoothBarUpdate(bar, value)

	local newBar = bar:GetChildren().health
	if newBar:GetValue() == bar:GetValue() then return end

	if value <= 1 then 
		barc = {bar:GetStatusBarColor()}
		barmm = {bar:GetMinMaxValues()}
		self:plateWasKilled(bar:GetChildren().name:GetText(), barc, barmm, value); 
		return 
	end

	newBar:SetMinMaxValues(bar:GetMinMaxValues())
	bar:GetChildren().pc:SetText(percent(value, select(2, newBar:GetMinMaxValues())) .. "%")

	if newBar:GetValue() > value then

	   if bar:GetChildren().health.inUse == true then
	        self:CancelTimer(bar:GetChildren().health.tid)
	   end

	      bar:GetChildren().health.inUse = true

	      local discount = newBar:GetValue() - value
	      local substract = round(discount / 20)

	      bar:GetChildren().health.tid = self:ScheduleRepeatingTimer(function()
	      	newBar:SetMinMaxValues(bar:GetMinMaxValues())
	         newBar:SetValue(newBar:GetValue() - substract)
	         if newBar:GetValue() <= value then
	            self:CancelTimer(bar:GetChildren().health.tid);
	            newBar:SetMinMaxValues(bar:GetMinMaxValues());
	            newBar:SetValue(value);
	            bar:GetChildren().health.inUse = false
	         end

	      end, 0.01)
	else

		newBar:SetValue(value);

	end

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

function SP:LNR_ON_RECYCLE_PLATE(eventname, plateFrame, plateData)

	ActivePlates[plateFrame:GetName()] = nil

end

function SP:LNR_ON_TARGET_PLATE_ON_SCREEN(eventname, plateFrame, plateData)

	--
	
end

function SP:getPreDefinedPlate(plate, name)

	local frame = CreateFrame("Frame", nil, plate) 
	frame:SetSize(140, 35) 
	frame:SetPoint("CENTER", 12.5 , 10) 
	texture = frame:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.8) 
	frame.background = texture

	frame.highlight = CreateFrame("Frame", nil, frame) 
	frame.highlight:SetSize(142, 37)
	frame.highlight:SetPoint("CENTER", 0 , 0) 

	frame.stunned = CreateFrame("Frame", nil, frame)
	frame.stunned:SetSize(35, 35) 
	frame.stunned:SetPoint("LEFT", frame, -37, 0)
	frame.stunned:Hide()
	frame.stunned.isUsed = false

	frame.cced = CreateFrame("Frame", nil, frame)
	frame.cced:SetSize(35, 35) 
	frame.cced:SetPoint("RIGHT", frame, 37, 0)
	frame.cced:Hide()
	frame.cced.isUsed = false

	frame.highlight = CreateFrame("Frame", nil, frame) 
	frame.highlight:SetSize(142, 37)
	frame.highlight:SetPoint("CENTER", 0 , 0) 

	frame.highlight.l = CreateFrame("Frame", nil, frame.highlight)
	frame.highlight.l:SetSize(2, 35) 
	frame.highlight.l:SetPoint("LEFT", frame.highlight, 0, 0)
	texture = frame.highlight.l:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(1,0,0,1)

	frame.highlight.r = CreateFrame("Frame", nil, frame.highlight)
	frame.highlight.r:SetSize(2, 35) 
	frame.highlight.r:SetPoint("RIGHT", frame.highlight, 0, 0)
	texture = frame.highlight.r:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(1,0,0,1)

	frame.highlight.b = CreateFrame("Frame", nil, frame.highlight)
	frame.highlight.b:SetSize(142, 2) 
	frame.highlight.b:SetPoint("BOTTOM", frame.highlight, 0, 0)
	texture = frame.highlight.b:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(1,0,0,1)

	frame.highlight:Hide()

	frame.name = frame:CreateFontString(nil, "OVERLAY")
	frame.name:SetPoint("LEFT", frame, "LEFT", 10, 17.5)
	frame.name:SetFont(PURISTA_FONT, 11, "OUTLINE")
	frame.name:SetJustifyH("LEFT")
	frame.name:SetShadowOffset(1, -1)
	frame.name:SetTextColor(1, 1, 1)
	frame.name:SetText(name)

	-- Health Bar
	frame.health = CreateFrame("StatusBar", nil, frame)
	frame.health:SetStatusBarTexture(BANTO)
	frame.health:GetStatusBarTexture():SetHorizTile(false)
	frame.health:SetWidth(133)
	frame.health:SetHeight(20)
	frame.health:SetPoint("CENTER", frame, 0, -4)
	frame.health.tid = 0;
	frame.health.inUse = false;

	frame.pc = frame.health:CreateFontString(nil, "OVERLAY")
	frame.pc:SetPoint("CENTER", frame.health, 0, 0)
	frame.pc:SetFont(PURISTA_FONT, 11, "OUTLINE")
	frame.pc:SetJustifyH("LEFT")
	frame.pc:SetShadowOffset(1, -1)
	frame.pc:SetTextColor(1, 1, 1)
	frame.pc:SetText("100%")


	return frame

end

function SP:HandleChatCommand(cmd) -- defines what to do when a chat command is typed 

	if cmd == "" then
		
	elseif cmd == "config" then

	else
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
		self:print("Possible SmoothyPlates Commands:")
		self:print("   - /smp config | Opens the Configure Window")
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

function SP:setUpTimerBar(name, clampTo, height, width, forTime, y, x)

	local newBar = CreateFrame("Frame", nil, clampTo) 
	newBar:SetSize(width, height+2) 
	newBar:SetPoint("TOP", clampTo, y, x) 
	texture = newBar:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 
	newBar.background = texture

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

	newBar.bar:SetMinMaxValues(0, (forTime*10))
	newBar.bar:SetValue(forTime*10)
	newBar.bar:SetStatusBarColor(fromRGB(0,0,200))


	timerIDs[name] = self:ScheduleRepeatingTimer(function() 
		if newBar.bar:GetValue() <= 1 
			then newBar.bar:Hide(); self:CancelTimer(timerIDs[name]); 
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

function SP:COMBAT_LOG_EVENT_UNFILTERED(event, timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	if not auraType then return end


	if eventType == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" then

		isEnemy = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE
		isPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER or bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER
		
		if isEnemy and isPlayer then
			if self:isCC(spellID) then
				unitID = self:getUnitIDFromName(split(destName, "-", false))
				if unitID then
					num = 0
					while num < 40 do
						num = num + 1
						name, z, icon, z, z, z, expires, z, z, z, spellIDNew, z, z, z, z, z = UnitDebuff(unitID, num)
						if spellIDNew == spellID then
							self:CCFound(destGUID, sourceGUID, unitID, icon, expires, spellID, true)
						end
					end
				end
			end
		end

	elseif eventType == "SPELL_AURA_REMOVED" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then
		if ActiveStunns[destGUID] == spellID then
			self:CCFaded(destGUID, true);
		end

	elseif eventType == "SPELL_INTERRUPT" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then 
		self:CCFound( destGUID, sourceGUID, destName, nil, 3.5, spellID, false )
	end
end

function SP:CCFound( destGUID, sourceGUID, unitID, icon, expires, spellID, isStunn )
	
	-- expires - GetTime()
	if isStunn then
		if self:getSmoothFrame(self:GetPlateByGUID(destGUID)) then
			local stunFrame = self:getSmoothFrame(self:GetPlateByGUID(destGUID)).stunned
			self:setUpTimerBar(UnitName(unitID)..spellID, stunFrame, 10, 35, expires - GetTime(), 0, 13)
			if stunFrame.isUsed then self:CCFaded(destGUID, true) end
			stunFrame:SetBackdrop(self:getBackdrop(icon))
			stunFrame:Show();
			stunFrame.isUsed = true
			ActiveStunns[destGUID] = spellID
			self:ScheduleTimer(function() stunFrame:Hide() end, round(expires - GetTime()))
		end
	else
		-- 47528 mind freeze for interrupt icon
		if self:getSmoothFrame(self:GetPlateByGUID(destGUID)) then
			local ccFrame = self:getSmoothFrame(self:GetPlateByGUID(destGUID)).cced
			self:setUpTimerBar(unitID..spellID, ccFrame, 10, 35, 3.7, 0, 13)
			if ccFrame.isUsed then self:CCFaded(destGUID, false) end
			ccFrame:SetBackdrop(self:getBackdrop(select(3, GetSpellInfo(47528))))
			ccFrame:Show();
			ccFrame.isUsed = true
			self:ScheduleTimer(function() ccFrame:Hide() end, expires)
		end
	end

end

function SP:CCFaded(destGUID, isStunn)
	
	if isStunn then
		if self:getSmoothFrame(self:GetPlateByGUID(destGUID)) then
			local stunFrame = self:getSmoothFrame(self:GetPlateByGUID(destGUID)).stunned
			stunFrame:Hide();
			stunFrame.isUsed = false
			ActiveStunns[destGUID] = nil
		end
	else
		if self:getSmoothFrame(self:GetPlateByGUID(destGUID)) then
			local ccFrame = self:getSmoothFrame(self:GetPlateByGUID(destGUID)).cced
			ccFrame:Hide();
			ccFrame.isUsed = false
		end
	end

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