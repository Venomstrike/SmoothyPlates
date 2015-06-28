-- A Lib to determinite when a Unit was stunned or interrupted

local LibCC = LibStub:NewLibrary("LibCC-1.0", 1)

if not LibCC then return end


LibCC.callbacks = LibStub("CallbackHandler-1.0"):New(LibCC)
LibCC.events = LibStub("AceEvent-3.0", LibCC)

-- Register Event
--LibCC.events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "COMBAT_LOG_EVENT_UNFILTERED")

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

local activeStunns = {}


function LibCC:COMBAT_LOG_EVENT_UNFILTERED(event, timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	if not auraType then return end

	if not destGUID or destGUID == "" then return end
	print(destGUID)
	unitID = handleUnitID(select(6, GetPlayerInfoByGUID(destGUID)))

	if eventType == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" and CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) then

		if LibCC:isCC(spellID) then
			if unitID then
				name, z, icon, z, z, z, expires, z, z, z, spellIDNew, z, z, z, z, z = UnitDebuff(unitID, spellName)
				if spellIDNew == spellID then
					activeStunns[unitID] = spellID
					LibCC.callbacks:Fire("UNIT_STUN", destGUID, sourceGUID, unitID, icon, expires, spellID)
				end
			end
		end

	elseif eventType == "SPELL_AURA_REMOVED" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then
		--[[ if in stealth nameplate is not cached and it cant be accessed so we return also when no active stun is set but a aura was removed
		if not activeStunns[unitID] then return end

		if activeStunns[unitID] == spellID then
			activeStunns[unitID] = nil
			LibCC.callbacks:Fire("UNIT_STUN_FADED", unitID, spellID)
		end]]--

	elseif eventType == "SPELL_INTERRUPT" and CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then
		LibCC.callbacks:Fire("UNIT_INTERRUPT", destGUID, sourceGUID, unitID, nil, 3.8, spellID)
	end

end

function LibCC:isCC( spellID )
	
	return CCSpells[spellID] or false

end

function handleUnitID( unitName )
	
	if UnitName("target") == unitName then return "target" end

end