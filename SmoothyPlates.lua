local SP = LibStub("AceAddon-3.0"):NewAddon("SmoothyPlates", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local EventHandler = {}
-- Info: The new damn good Plates
-- Author: Max David aka Vènomstrikè
-- #onlynoobsusetidy | jk, smile ;)

-- License: GNU General Public License version 2 (GPLv2)

--[[ TODO:

]]--

--------------Global Variables----------------
local currVersion = 3.0

SP.FONT = "Interface\\Addons\\SmoothyPlates\\Media\\Font\\Designosaur-Regular.ttf"
SP.BAR_TEX = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Glaze"
SP.PRED_BAR_TEX = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Gloss"
SP.HEALER_ICON = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\healer"

--"Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
--"Interface\RaidFrame\Absorb-Edge"

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local UnitIsUnit = UnitIsUnit

-- Modules
local ModuleHealers = nil
local ModuleStunns = nil
local ModuleSilences = nil
local ModuleTrinket = nil

local aceGui, aceGuiWid, sharedMedia = nil

SP.stdbd = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	tile = true,
	tileSize = 12,
	edgeSize = 0,
}

SP.stdbd_edge = {
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	insets = {
		left = 2,
		right = 2,
		top = 2,
		bottom = 2
	},
	tile = true,
	tileSize = 12,
	edgeSize = 12,
}

----------------------------------------------

function SP:OnInitialize() -- the initialize part

	self:HASOS()

	self:print("Nameplates pimped :)")

end

-----------------Method Part-----------------

function SP:HASOS() -- handle all shit on start

	aceGui = LibStub:GetLibrary("AceGUI-3.0", true)
	aceGuiWid = LibStub:GetLibrary("AceGUISharedMediaWidgets-1.0", true)
	sharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0", true)

	self.db = LibStub("AceDB-3.0"):New("SPDB")
	self:HandleMedia()

	self:HandleFirstLoad()

	self.callbacks = LibStub("CallbackHandler-1.0"):New(self)

	self.smoothy = LibStub("LibSmoothStatusBar-1.0")

	-------- Modules ----------

	if self.db.char.options.modules.healers then
		self:EnableModule("Healers")
		ModuleHealers = self:GetModule("Healers")
	else
		self:DisableModule("Healers")
	end

	if self.db.char.options.modules.stuns then
		self:EnableModule("Stunns")
		ModuleStunns = self:GetModule("Stunns")
	else
		self:DisableModule("Stunns")
	end

	if self.db.char.options.modules.silences then
		self:EnableModule("Silences")
		ModuleSilences = self:GetModule("Silences")
	else
		self:DisableModule("Silences")
	end

	if self.db.char.options.modules.trinkets then
		self:EnableModule("Trinket")
		ModuleTrinket = self:GetModule("Trinket")
	else
		self:DisableModule("Trinket")
	end

	---------------------------

	self:RegisterChatCommand("smp", "HandleChatCommand")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	LibStub("AceEvent-3.0"):Embed(EventHandler)
	for eventName in pairs(EventHandler) do EventHandler:RegisterEvent(eventName) end

	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");

end

function SP:HandleMedia()

	sharedMedia:Register("font", "Designosaur Regular", SP.FONT)
	sharedMedia:Register("font", "ElvUI Mentium", "Interface\\Addons\\SmoothyPlates\\Media\\Font\\ElvUI-Mentium.ttf")
	sharedMedia:Register("font", "Purista Medium", "Interface\\Addons\\SmoothyPlates\\Media\\Font\\Purista-Medium.ttf")
	sharedMedia:Register("statusbar", "Blizzard Nameplate Bar", "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
	sharedMedia:Register("statusbar", "Glaze", SP.BAR_TEX)
	sharedMedia:Register("statusbar", "Gloss", SP.PRED_BAR_TEX)
	sharedMedia:Register("statusbar", "Flat", "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Flat")
	sharedMedia:Register("statusbar", "Minimalist", "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Minimalist")
	sharedMedia:Register("statusbar", "Minimal", "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Minimal")

	if self.db.char.options then
		SP.FONT = sharedMedia:Fetch("font", self.db.char.options.media.font)
		SP.BAR_TEX = sharedMedia:Fetch("statusbar", self.db.char.options.media.bar)
		SP.PRED_BAR_TEX = sharedMedia:Fetch("statusbar", self.db.char.options.media.predBar)
	end

end

function SP:HandleFirstLoad()
	if not self.db.char.options then
		self.db.char.options = {
			media = {
				font = "Purista Medium",
				bar = "Glaze",
				predBar = "Blizzard Nameplate Bar"
			},
			modules = {
				stuns = true,
				silences = true,
				healers = true,
				trinkets = true
			},
			plugins = {

			}
		}

		local frameP = aceGui:Create("Frame"); frameP:EnableResize(false)
		frameP:SetCallback("OnClose", function(widget) aceGui:Release(widget) end)
		frameP:SetTitle("Thx m9-1"); frameP:SetLayout("Flow")
		frameP:SetWidth(240); frameP:SetHeight(130)
		local labelP = aceGui:Create("Label")
		labelP:SetText("Thank you for downloading SmoothyPlates! This is your first game with this AddOn. If you notice that your nameplates are buggy, activate the [Bigger Nameplates]-Option in the Interface-Options.       Type /smp for the options");
		labelP:SetWidth(220)
		frameP:AddChild(labelP)
	end

end

function SP:CreateOptionFrame()

	if aceGui and aceGuiWid then

		local frameO = aceGui:Create("Frame")
		frameO:SetTitle("SmoothyPlates Options")
		frameO:SetLayout("Flow")
		frameO:SetStatusText("Version: " .. currVersion)
		frameO:SetWidth(290)
		frameO:SetHeight(410)
		frameO:EnableResize(false)

		local frameS = aceGui:Create("ScrollFrame")
		frameS:SetWidth(270)
		frameS:SetHeight(330)

		local frameF = aceGui:Create("LSM30_Font")
		frameF.list = sharedMedia:HashTable("font")
		frameF.SetLabel(frameF, 'General Font')
		frameF.SetValue(frameF, self.db.char.options.media.font)
		frameF:SetCallback("OnValueChanged", function(dropdown, event, value) dropdown.SetValue(dropdown, value) end)

		local frameB = aceGui:Create("LSM30_Statusbar")
		frameB.list = sharedMedia:HashTable("statusbar")
		frameB.SetLabel(frameB, 'Texture for all Bars')
		frameB.SetValue(frameB,  self.db.char.options.media.bar)
		frameB:SetCallback("OnValueChanged", function(dropdown, event, value) dropdown.SetValue(dropdown, value) end)

		local framePB = aceGui:Create("LSM30_Statusbar")
		framePB.list = sharedMedia:HashTable("statusbar")
		framePB.SetLabel(framePB, 'Texture for Absorb/Heal prediction')
		framePB.SetValue(framePB,  self.db.char.options.media.predBar)
		framePB:SetCallback("OnValueChanged", function(dropdown, event, value) dropdown.SetValue(dropdown, value) end)


		local cbHeal = aceGui:Create("CheckBox")
		cbHeal:SetLabel("Healers")
		cbHeal:SetValue(self.db.char.options.modules.healers)

		local cbSilences = aceGui:Create("CheckBox")
		cbSilences:SetLabel("Silences")
		cbSilences:SetValue(self.db.char.options.modules.silences)

		local cbStuns = aceGui:Create("CheckBox")
		cbStuns:SetLabel("Stuns")
		cbStuns:SetValue(self.db.char.options.modules.stuns)

		local cbTrinket = aceGui:Create("CheckBox")
		cbTrinket:SetLabel("Trinkets")
		cbTrinket:SetValue(self.db.char.options.modules.trinkets)

		local lblPlugins = aceGui:Create("Label")
		lblPlugins:SetText("Coming soon ;)")

		local modules = aceGui:Create("InlineGroup")
		modules:SetTitle("Modules")

		local media = aceGui:Create("InlineGroup")
		media:SetTitle("Media")

		local plugins = aceGui:Create("InlineGroup")
		plugins:SetTitle("Plugins")

		media:AddChild(frameF)
		media:AddChild(frameB)
		media:AddChild(framePB)

		modules:AddChild(cbStuns)
		modules:AddChild(cbSilences)
		modules:AddChild(cbHeal)
		modules:AddChild(cbTrinket)

		plugins:AddChild(lblPlugins)

		frameS:AddChild(media)
		frameS:AddChild(modules)
		frameS:AddChild(plugins)

		frameO:AddChild(frameS)

		frameO:SetCallback("OnClose", function()

			self.db.char.options.media.font = frameF.GetValue(frameF)
			self.db.char.options.media.bar = frameB.GetValue(frameB)
			self.db.char.options.media.predBar = framePB.GetValue(framePB)

			self.db.char.options.modules.stuns = cbStuns:GetValue()
			self.db.char.options.modules.silences = cbSilences:GetValue()
			self.db.char.options.modules.healers = cbHeal:GetValue()
			self.db.char.options.modules.trinkets = cbTrinket:GetValue()

			local frameP = aceGui:Create("Frame"); frameP:EnableResize(false)
			frameP:SetCallback("OnClose", function(widget) aceGui:Release(widget) end)
			frameP:SetTitle("Reload"); frameP:SetLayout("Flow")
			frameP:SetWidth(305); frameP:SetHeight(90)
			local labelP = aceGui:Create("Label")
			labelP:SetText("If you changed something you should reload (/reload)."); labelP:SetWidth(310)
			frameP:AddChild(labelP)
		end)

	else
		self:print("Hmm, something went wrong while creating the options... :(")
	end

end


-----------------Plate handling-----------------

local inArena = false
function SP:PLAYER_ENTERING_WORLD()
	plateStorage = {}
	self.callbacks:Fire("SP_PLAYER_ENTERING_WORLD")

	if select(2, IsInInstance()) == "arena" then
		inArena = true
		self.callbacks:Fire("SP_ARENA_STATE_CHANGED", inArena)
	else
		if inArena then
			inArena = false
			self.callbacks:Fire("SP_ARENA_STATE_CHANGED", inArena)
		end
	end

end

local plateStorage = {}

function BypassFunction() return true end

function SP:NAME_PLATE_CREATED(event, plate)
	local blizzFrame = plate:GetChildren()

	blizzFrame._Show = blizzFrame.Show
	blizzFrame.Show = BypassFunction

	SmoothyPlate(plate);
	self.callbacks:Fire("AFTER_SP_CREATION", plate)

end

function SP:NAME_PLATE_UNIT_ADDED(event, unitid)
	local plate = GetNamePlateForUnit(unitid);

	-- Personal Display
	if UnitIsUnit("player", unitid) then
		plate:GetChildren():_Show()
	-- Normal Plates
	else
		plate:GetChildren():Hide()
		if plate and plate.SmoothyPlate then
			plate.SmoothyPlate:AddUnit(unitid)
			plateStorage[UnitGUID(plate.SmoothyPlate.unitid)] = plate
			self.callbacks:Fire("AFTER_SP_UNIT_ADDED", plate)
		end
	end
end

function SP:NAME_PLATE_UNIT_REMOVED(event, unitid)
	local plate = GetNamePlateForUnit(unitid);

	if unitid and plate and plate.SmoothyPlate and plate.SmoothyPlate.unitid then
		self.callbacks:Fire("BEFORE_SP_UNIT_REMOVED", plate)
		plateStorage[UnitGUID(plate.SmoothyPlate.unitid)] = nil
		plate.SmoothyPlate:RemoveUnit()
	end
end

function SP:GetPlateByGUID(guid)
	return plateStorage[guid]
end

----------------Plate Event handling-----------------

function EventHandler:UNIT_HEALTH(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealth();

end

function EventHandler:UNIT_MAXHEALTH(event, unitid)
	self:UNIT_HEALTH(event, unitid)

end

function EventHandler:UNIT_HEALTH_FREQUENT(event, unitid)
	self:UNIT_HEALTH(event, unitid)

end



function EventHandler:UNIT_POWER(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdatePower();

end

function EventHandler:UNIT_MAXPOWER(event, unitid)
	self:UNIT_POWER(event, unitid)

end

function EventHandler:UNIT_POWER_FREQUENT(event, unitid)
	self:UNIT_POWER(event, unitid)

end

function EventHandler:UNIT_DISPLAYPOWER(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealthColor();
	plate.SmoothyPlate:UpdatePowerColor();

end



function EventHandler:UNIT_HEAL_PREDICTION(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealAbsorbPrediction()
end

function EventHandler:UNIT_ABSORB_AMOUNT_CHANGED(event, unitid)
	self:UNIT_HEAL_PREDICTION(event, unitid)
end

function EventHandler:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(event, unitid)
	self:UNIT_HEAL_PREDICTION(event, unitid)
end



function EventHandler:UNIT_NAME_UPDATE(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateName();
	plate.SmoothyPlate:UpdateHealthColor();
	plate.SmoothyPlate:UpdatePowerColor();

end

function EventHandler:PLAYER_TARGET_CHANGED(event, unitid)
	self:UNIT_NAME_UPDATE(event, unitid)

end



function EventHandler:UNIT_SPELLCAST_START(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	SP.callbacks:Fire("BEFORE_SP_UNIT_CAST_START", plate)
	plate.SmoothyPlate:StartCasting(false)

end

function EventHandler:UNIT_SPELLCAST_STOP(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:StopCasting()

end

function EventHandler:UNIT_SPELLCAST_CHANNEL_START(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	SP.callbacks:Fire("BEFORE_SP_UNIT_CHANNEL_START", plate)
	plate.SmoothyPlate:StartCasting(true)

end

function EventHandler:UNIT_SPELLCAST_CHANNEL_STOP(event, unitid)
	self:UNIT_SPELLCAST_STOP(event, unitid)

end

function EventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateCastBarMidway()

end

function EventHandler:UNIT_SPELLCAST_DELAYED(event, unitid)
	self:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_INTERRUPTIBLE(event, unitid)
	self:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(event, unitid)
	self:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

-----------------------------------------------------

function SP:HandleChatCommand(cmd) -- defines what to do when a chat command is typed

	if cmd == "options" then
		self:CreateOptionFrame()
	else
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
		self:print("Possible SmoothyPlates Commands:")
		self:print("   - /smp (?) | Show all commands")
		self:print("   - /smp options | Show options")
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
	end

end

function SP:SaveDB() -- saves all infos gathered to the DB

	--

end

-----------------MISC-------------------



---------------Conveniance Methods-----------------

function SP:getBackdropWithEdge(path, tileN, tileSizeN, edgeSizeN, insetSize) -- gets an bockdrop object with the image from the path as the background
	insetSize = insetSize or 0

	return {
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		bgFile = path,
		tile = tileN,
		tileSize = tileSizeN,
		edgeSize = edgeSizeN,
		insets = {
			left = insetSize,
			right = insetSize,
			top = insetSize,
			bottom = insetSize
		},
	}

end

function SP:getBackdrop(path, tileN, tileSizeN) -- gets an bockdrop object with the image from the path as the background
	return {
		bgFile = path,
		tile = tileN,
		tileSize = tileSizeN
	}

end

function SP:AddSPBorders(frame, size)

	frame.l = CreateFrame("Frame", nil, frame)
	frame.l:SetSize(size, frame:GetHeight())
	frame.l:SetPoint("LEFT", 0, 0)
	frame.l:SetBackdrop(SP.stdbd)
    frame.l:SetBackdropColor(0,0,0,1)

	frame.r = CreateFrame("Frame", nil, frame)
	frame.r:SetSize(size, frame:GetHeight())
	frame.r:SetPoint("RIGHT", 0, 0)
	frame.r:SetBackdrop(SP.stdbd)
    frame.r:SetBackdropColor(0,0,0,1)

	frame.t = CreateFrame("Frame", nil, frame)
	frame.t:SetSize(frame:GetWidth(), size)
	frame.t:SetPoint("TOP", 0, 0)
	frame.t:SetBackdrop(SP.stdbd)
    frame.t:SetBackdropColor(0,0,0,1)

	frame.b = CreateFrame("Frame", nil, frame)
	frame.b:SetSize(frame:GetWidth(), size)
	frame.b:SetPoint("BOTTOM", 0, 0)
	frame.b:SetBackdrop(SP.stdbd)
    frame.b:SetBackdropColor(0,0,0,1)

end

function SP:print(msg) -- the print funktion with the Red VFrame before every chat msg

	print("|cffff0020SmoothyPlates|r: " .. msg)

end

---------------Functional Methods-----------------

function SP:percent(is, from)

	return SP:round((is / from) * 100)

end

function SP:round(n) -- rounds a value

    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)

end

function SP:contains(tbl, value) -- returns true if the value is existent in the given tbl

	for i,n in pairs(tbl) do
		if n == value then return true end
	end

	return false

end

function SP:split(inputstr, sep, tbl) -- splits a string

        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end

        if tbl then return t else return t[1] end

end

function SP:fromRGB(r, g, b, a)

	return (r/255), (g/255), (b/255), (a/255)

end

function SP:getIndex(tbl, value) -- returns the index where the value is in the table

	for i,n in pairs(tbl) do
		if n == value then return i end
	end

end

----------------------------------------------
