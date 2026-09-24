-- RareAlert: watches for dungeon rares and alerts when one is in range.
-- Scanning uses the unitscan trick: TargetUnit() is protected, so calling it from an addon
-- fires ADDON_ACTION_FORBIDDEN, but only when a unit with that name is close enough to target.
local ADDON, ns = ...

local pairs, ipairs, wipe, tonumber = pairs, ipairs, wipe, tonumber
local GetTime, TargetUnit, InCombatLockdown = GetTime, TargetUnit, InCombatLockdown
local UnitExists, UnitName, UnitLevel, UnitGUID = UnitExists, UnitName, UnitLevel, UnitGUID
local UnitIsDead, UnitPlayerControlled, UnitClassification = UnitIsDead, UnitPlayerControlled, UnitClassification

ns.SCAN_INTERVAL = 0.5
ns.REARM_SECONDS = 60     -- a rare must be out of range this long before it alerts again
ns.KILLED_SECONDS = 600   -- ignore a killed rare (and its corpse) for this long
ns.NEARBY_SECONDS = 2
-- Most dungeon rares on AzerothCore spawn every time, then an "On AI Init" script despawns them
-- 0.5s later unless they win their spawn roll. A scan can catch that flicker, so a rare must stay
-- in range this long before it alerts.
ns.CONFIRM_SECONDS = 1.5

local DEFAULTS = { enabled = true, sound = true, flash = true, custom = {} }

local db
local state = {}    -- [name] = { seen = time, since = sighting start, present = confirmed time, alerted = bool, killed = time }
local watch = {}    -- [name] = rare info; what the scanner probes right now
local spotted = {}  -- [name] = rare info; unlisted rares found by target/mouseover in this zone
ns.state = state
ns.watch = watch

-- lookups built from data.lua
ns.byZone, ns.byName = {}, {}
for _, instance in ipairs(ns.instances) do
	ns.byZone[instance.zone] = instance
	for _, alias in ipairs(instance.aliases or {}) do
		ns.byZone[alias] = instance
	end
	for _, rare in ipairs(instance.rares) do
		rare.zone = instance.zone
		ns.byName[rare.name] = rare
	end
end

function ns.Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cffff8000RareAlert:|r " .. msg)
end

local function CurrentInstance()
	if not IsInInstance() then return end
	return ns.byZone[GetRealZoneText()] or ns.byZone[(GetInstanceInfo())]
end

function ns.RebuildWatch()
	wipe(watch)
	local instance = CurrentInstance()
	ns.instance = instance
	if instance then
		for _, rare in ipairs(instance.rares) do
			watch[rare.name] = rare
		end
	end
	for name in pairs(db.custom) do
		watch[name] = watch[name] or ns.byName[name] or { name = name, custom = true }
	end
	for name, rare in pairs(spotted) do
		watch[name] = watch[name] or rare
	end
end

-- ---------------------------------------------------------------------------
-- detection

local probing, hit = false, false

local function Probe(name)
	probing, hit = true, false
	TargetUnit(name, true)
	probing = false
	return hit
end

-- confirmed: the rare is certainly there (you targeted or moused over it), so skip the wait
function ns.Found(name, rare, confirmed)
	local now = GetTime()
	local s = state[name]
	if not s then
		s = {}
		state[name] = s
	end
	local last = s.seen
	s.seen = now
	if not last or now - last > ns.REARM_SECONDS then
		s.alerted = false
	end
	if not last or now - last > ns.SCAN_INTERVAL * 2.5 then
		s.since = now  -- missed a scan or more, so this is a new sighting
	end
	if not confirmed and now - s.since < ns.CONFIRM_SECONDS then return end
	s.present = now  -- last time it was really there, for the list
	if s.alerted or (s.killed and now - s.killed < ns.KILLED_SECONDS) then return end
	s.alerted = true
	ns.Alert(name, rare)
end

local function Scan()
	for name, rare in pairs(watch) do
		if Probe(name) then
			ns.Found(name, rare)
		end
	end
end

local function NpcID(unit)
	local guid = UnitGUID(unit)
	if guid and guid:sub(3, 5) == "F13" then
		return tonumber(guid:sub(7, 12), 16)
	end
end

-- catches rares that are not in the list, e.g. world rares you mouse over
local function CheckUnit(unit)
	if not UnitExists(unit) or UnitIsDead(unit) or UnitPlayerControlled(unit) then return end
	local class = UnitClassification(unit)
	if class ~= "rare" and class ~= "rareelite" then return end

	local name = UnitName(unit)
	local rare = watch[name] or ns.byName[name]
	if not rare then
		rare = { name = name, id = NpcID(unit), level = tostring(UnitLevel(unit)), elite = class == "rareelite" }
		spotted[name] = rare
		watch[name] = rare  -- keep scanning for it so it stays quiet while it is nearby
	end
	ns.Found(name, rare, true)
end

-- ---------------------------------------------------------------------------
-- events

local frame = CreateFrame("Frame")
local elapsedSinceScan = 0
local lastAnnounced = {}  -- [zone] = time, so dying and running back does not re-announce

local function Announce()
	local instance = ns.instance
	if not instance or (lastAnnounced[instance.zone] and GetTime() - lastAnnounced[instance.zone] < 600) then return end
	lastAnnounced[instance.zone] = GetTime()
	local names = {}
	for _, rare in ipairs(instance.rares) do
		names[#names + 1] = rare.name
	end
	ns.Print(("%s has %d rare%s: %s. %s"):format(instance.zone, #names, #names == 1 and "" or "s",
		table.concat(names, ", "), db.enabled and "Scanning." or "Scanning is off (/rare on)."))
end

local function OnZoneChanged()
	wipe(spotted)
	ns.RebuildWatch()
	Announce()
	ns.RefreshList()
end

frame:SetScript("OnUpdate", function(self, elapsed)
	if not db then return end
	elapsedSinceScan = elapsedSinceScan + elapsed
	if elapsedSinceScan < ns.SCAN_INTERVAL then return end
	elapsedSinceScan = 0
	if db.enabled then
		Scan()
	end
	ns.OnTick()
end)

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_ACTION_FORBIDDEN" then
		local addon, func = ...
		if addon == ADDON then
			if probing then hit = true end
		elseif func ~= "TargetUnit()" then
			-- we took this event away from UIParent, so show its popup for everyone else,
			-- except other scanners (unitscan, _NPCScan) probing with the same TargetUnit trick
			StaticPopup_Show("ADDON_ACTION_FORBIDDEN", addon)
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, _, _, _, _, destName = ...
		if subEvent == "UNIT_DIED" and watch[destName] then
			local s = state[destName] or {}
			state[destName] = s
			s.killed = GetTime()
			ns.RefreshList()
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		CheckUnit("target")
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		CheckUnit("mouseover")
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		OnZoneChanged()
	elseif event == "ADDON_LOADED" and ... == ADDON then
		RareAlertDB = RareAlertDB or {}
		db = RareAlertDB
		for key, value in pairs(DEFAULTS) do
			if db[key] == nil then db[key] = value end
		end
		ns.db = db
		-- UIParent would pop up "blocked action" on every successful probe
		UIParent:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
		self:RegisterEvent("ADDON_ACTION_FORBIDDEN")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:UnregisterEvent("ADDON_LOADED")
	end
end)
frame:RegisterEvent("ADDON_LOADED")

-- ---------------------------------------------------------------------------
-- slash commands

local function OnOff(value)
	return value and "|cff20ff20on|r" or "|cffff2020off|r"
end

function ns.Toggle(key)
	db[key] = not db[key]
	ns.Print(("%s %s"):format(key == "enabled" and "Scanning" or key:gsub("^%l", string.upper), OnOff(db[key])))
	ns.RefreshList()
end

local HELP = {
	"/rare  -  show or hide the rare list",
	"/rare on | off  -  turn scanning on or off",
	"/rare sound  -  toggle the alert sound",
	"/rare flash  -  toggle the screen flash",
	"/rare add <name>  -  also scan for this name everywhere",
	"/rare remove <name>  -  stop scanning for a name you added",
	"/rare test  -  show a test alert",
	"/rare reset  -  forget which rares were seen or killed",
}

SLASH_RAREALERT1 = "/rare"
SLASH_RAREALERT2 = "/rarealert"
SlashCmdList.RAREALERT = function(input)
	local cmd, arg = input:match("^%s*(%S*)%s*(.-)%s*$")
	cmd = cmd:lower()
	if cmd == "" or cmd == "list" then
		ns.ToggleList()
	elseif cmd == "on" or cmd == "off" then
		db.enabled = cmd == "on"
		ns.Print("Scanning " .. OnOff(db.enabled))
		ns.RefreshList()
	elseif cmd == "sound" or cmd == "flash" then
		ns.Toggle(cmd)
	elseif cmd == "add" and arg ~= "" then
		db.custom[arg] = true
		ns.RebuildWatch()
		ns.Print("Now scanning for " .. arg .. " everywhere.")
		ns.RefreshList()
	elseif cmd == "remove" and arg ~= "" then
		if db.custom[arg] then
			db.custom[arg] = nil
			ns.RebuildWatch()
			ns.Print("Stopped scanning for " .. arg .. ".")
			ns.RefreshList()
		else
			ns.Print(arg .. " is not on your list. Names are case-sensitive.")
		end
	elseif cmd == "test" then
		local rare = ns.byName["Deviate Faerie Dragon"]
		ns.Alert(rare.name, rare)
	elseif cmd == "reset" then
		wipe(state)
		ns.Print("Forgot every seen and killed rare.")
		ns.RefreshList()
	else
		for _, line in ipairs(HELP) do
			ns.Print(line)
		end
	end
end
