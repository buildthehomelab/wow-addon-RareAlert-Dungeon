-- RareAlert-Dungeons UI: the click-to-target alert, the screen flash, and the rare list window.
local ADDON, ns = ...

local GetTime, InCombatLockdown = GetTime, InCombatLockdown

local SOUNDS = {
	"Sound\\Interface\\RaidWarning.wav",
	"Sound\\Event Sounds\\Event_wardrum_ogre.ogg",
}
local BUTTON_HIDE_SECONDS = 90  -- hide the alert once its rare has been out of range this long

local function RareKind(rare)
	if rare.custom then return "Custom" end
	return rare.elite == false and "Rare" or "Rare Elite"
end

-- ---------------------------------------------------------------------------
-- alert button: secure, so a left click can run /targetexact. Secure frames can't be shown,
-- hidden or retargeted in combat, so changes made during combat wait for it to end.

local button = CreateFrame("Button", "RareAlertButton", UIParent, "SecureActionButtonTemplate")
button:SetWidth(300)
button:SetHeight(68)
button:SetPoint("TOP", UIParent, "TOP", 0, -110)
button:SetFrameStrata("HIGH")
button:SetClampedToScreen(true)
button:SetMovable(true)
button:RegisterForClicks("AnyUp")
button:RegisterForDrag("LeftButton")
button:SetAttribute("type1", "macro")
button:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
do  -- the stock tooltip's colours
	local bg = TOOLTIP_DEFAULT_BACKGROUND_COLOR or { r = 0.09, g = 0.09, b = 0.19 }
	local edge = TOOLTIP_DEFAULT_COLOR or { r = 1, g = 1, b = 1 }
	button:SetBackdropColor(bg.r, bg.g, bg.b)
	button:SetBackdropBorderColor(edge.r, edge.g, edge.b)
end
button:Hide()

local model = CreateFrame("PlayerModel", nil, button)
model:SetWidth(56)
model:SetHeight(56)
model:SetPoint("LEFT", 6, 0)

local header = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
header:SetPoint("TOPLEFT", model, "TOPRIGHT", 8, -2)
header:SetText("RARE FOUND")

local nameText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
nameText:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -3)
nameText:SetPoint("RIGHT", -26, 0)
nameText:SetJustifyH("LEFT")

local infoText = button:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
infoText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -3)
infoText:SetPoint("RIGHT", -8, 0)
infoText:SetJustifyH("LEFT")

local close = CreateFrame("Button", nil, button, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 2, 2)
ns.Skin.Alert(button, close)

local shown       -- name on the button right now
local shownAt
local pending     -- { name, rare } or false (hide), applied when combat ends

local function ApplyButton(name, rare)
	if not name then
		shown = nil
		button:Hide()
		return
	end
	shown = name
	shownAt = GetTime()
	button:SetAttribute("macrotext", "/cleartarget\n/targetexact " .. name)
	nameText:SetText(name)
	infoText:SetText(("Level %s %s  -  click to target%s"):format(rare.level or "??", RareKind(rare),
		ns.db.mark and " and mark" or ""))
	model:ClearModel()
	if rare.id then
		pcall(model.SetCreature, model, rare.id)  -- fails for creatures the client hasn't cached
	end
	button:Show()
end

local combatWatcher = CreateFrame("Frame")
combatWatcher:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	if pending ~= nil then
		ApplyButton(pending and pending[1], pending and pending[2])
		pending = nil
	end
end)

local function SetButton(name, rare)
	if InCombatLockdown() then
		pending = name and { name, rare } or false
		combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		ApplyButton(name, rare)
	end
end

close:SetScript("OnClick", function() SetButton(nil) end)
button:SetScript("PostClick", function(self, mouseButton)
	if mouseButton == "RightButton" then SetButton(nil) end
end)
button:SetScript("OnDragStart", function(self)
	if IsShiftKeyDown() and not InCombatLockdown() then self:StartMoving() end
end)
button:SetScript("OnDragStop", button.StopMovingOrSizing)
button:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
	GameTooltip:AddLine(shown or "RareAlert-Dungeons")
	GameTooltip:AddLine(ns.db.mark and "Left-click to target and mark" or "Left-click to target", 1, 1, 1)
	GameTooltip:AddLine("Right-click to dismiss", 1, 1, 1)
	GameTooltip:AddLine("Shift-drag to move", 1, 1, 1)
	GameTooltip:Show()
end)
button:SetScript("OnLeave", GameTooltip_Hide)

-- ---------------------------------------------------------------------------
-- screen flash

local flash = CreateFrame("Frame", nil, UIParent)
flash:SetAllPoints(UIParent)
flash:SetFrameStrata("FULLSCREEN")
flash:Hide()
local flashTexture = flash:CreateTexture(nil, "BACKGROUND")
flashTexture:SetTexture("Interface\\FullScreenTextures\\LowHealth")
flashTexture:SetAllPoints()
flashTexture:SetBlendMode("ADD")
flashTexture:SetVertexColor(1, 0.45, 0)

local FLASH_PULSES, FLASH_PULSE_SECONDS = 3, 0.8
flash:SetScript("OnUpdate", function(self, elapsed)
	self.t = self.t + elapsed
	if self.t >= FLASH_PULSES * FLASH_PULSE_SECONDS then
		self:Hide()
		return
	end
	self:SetAlpha(math.sin((self.t % FLASH_PULSE_SECONDS) / FLASH_PULSE_SECONDS * math.pi))
end)

local function Flash()
	flash.t = 0
	flash:SetAlpha(0)
	flash:Show()
end

-- ---------------------------------------------------------------------------
-- alert

function ns.Alert(name, rare)
	local db = ns.db
	local where = rare.zone and (" in " .. rare.zone) or ""
	ns.Print(("|cffffff00%s|r (%s %s)%s is nearby!"):format(name, rare.level or "??", RareKind(rare), where))
	RaidNotice_AddMessage(RaidWarningFrame, "Rare: " .. name, ChatTypeInfo["RAID_WARNING"])
	if db.sound then
		for _, sound in ipairs(SOUNDS) do
			-- some 3.3.5 builds reject the channel argument
			if not pcall(PlaySoundFile, sound, "Master") then
				PlaySoundFile(sound)
			end
		end
	end
	if db.flash then
		Flash()
	end
	SetButton(name, rare)
	ns.RefreshList()
end

-- ---------------------------------------------------------------------------
-- list window

local list = CreateFrame("Frame", "RareAlertListFrame", UIParent)
list:SetWidth(360)
list:SetHeight(400)
list:SetPoint("CENTER", -200, 60)
list:SetFrameStrata("DIALOG")
list:SetClampedToScreen(true)
list:SetMovable(true)
list:EnableMouse(true)
list:RegisterForDrag("LeftButton")
list:SetScript("OnDragStart", list.StartMoving)
list:SetScript("OnDragStop", list.StopMovingOrSizing)
list:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
list:Hide()
tinsert(UISpecialFrames, "RareAlertListFrame")  -- Escape closes it

local titlePlate = list:CreateTexture(nil, "ARTWORK")
titlePlate:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
titlePlate:SetWidth(300)
titlePlate:SetHeight(64)
titlePlate:SetPoint("TOP", 0, 12)

local title = list:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", titlePlate, "TOP", 0, -14)

local listClose = CreateFrame("Button", nil, list, "UIPanelCloseButton")
listClose:SetPoint("TOPRIGHT", -6, -6)

-- the list sits on a box like the stock options panels' (OptionsBoxTemplate)
local pane = CreateFrame("Frame", nil, list)
pane:SetPoint("TOPLEFT", 18, -36)
pane:SetPoint("BOTTOMRIGHT", -18, 44)
pane:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
})
pane:SetBackdropColor(0.1, 0.1, 0.1)
pane:SetBackdropBorderColor(0.4, 0.4, 0.4)

local scroll = CreateFrame("ScrollFrame", "RareAlertListScroll", pane, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 8, -8)
scroll:SetPoint("BOTTOMRIGHT", -28, 8)

local content = CreateFrame("Frame", nil, scroll)
content:SetWidth(280)
content:SetHeight(1)
scroll:SetScrollChild(content)

ns.Skin.Window(list, titlePlate, title, listClose, pane, scroll)

local body = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
body:SetPoint("TOPLEFT")
body:SetWidth(280)
body:SetJustifyH("LEFT")
body:SetSpacing(2)

local function FooterButton(label, width, onClick)
	local b = CreateFrame("Button", nil, list, "UIPanelButtonTemplate")
	b:SetWidth(width)
	b:SetHeight(22)
	b:SetText(label)
	b:SetScript("OnClick", onClick)
	ns.Skin.Button(b)
	return b
end

local scanButton = FooterButton("", 110, function()
	SlashCmdList.RAREALERT(ns.db.enabled and "off" or "on")
end)
scanButton:SetPoint("BOTTOMLEFT", 18, 16)
local soundButton = FooterButton("", 100, function() ns.Toggle("sound") end)
soundButton:SetPoint("LEFT", scanButton, "RIGHT", 4, 0)
local testButton = FooterButton("Test", 80, function() SlashCmdList.RAREALERT("test") end)
testButton:SetPoint("LEFT", soundButton, "RIGHT", 4, 0)

local function Status(name)
	local s = ns.state[name]
	if not s then return "|cff777777not seen|r" end
	local now = GetTime()
	if s.killed and now - s.killed < ns.KILLED_SECONDS then return "|cff999999killed|r" end
	if s.present and now - s.present < ns.NEARBY_SECONDS then return "|cff20ff20NEARBY|r" end
	if s.present then return ("|cffccccccseen %dm ago|r"):format(math.floor((now - s.present) / 60)) end
	return "|cff777777not seen|r"
end

local function RareLine(lines, rare, withStatus)
	local line = ("|cffffd100%s|r |cff999999(%s)|r"):format(rare.name, rare.level or "??")
	if withStatus then
		line = line .. "  " .. Status(rare.name)
	end
	lines[#lines + 1] = line
	if rare.note then
		lines[#lines + 1] = "    |cff888888" .. rare.note .. "|r"
	end
end

function ns.RefreshList()
	if not list:IsShown() then return end
	local db = ns.db
	local lines = {}
	local instance = ns.instance

	if instance then
		title:SetText(instance.zone)
		for _, rare in ipairs(instance.rares) do
			RareLine(lines, rare, true)
		end
	else
		title:SetText("Dungeon rares")
		lines[#lines + 1] = "|cffaaaaaaYou're not in a dungeon with rares. They scan automatically once you enter one.|r"
		for _, inst in ipairs(ns.instances) do
			lines[#lines + 1] = " "
			lines[#lines + 1] = ("|cffff8000%s|r |cff999999(%s)|r"):format(inst.zone, inst.levels)
			for _, rare in ipairs(inst.rares) do
				RareLine(lines, rare, false)
			end
		end
	end

	local custom = {}
	for name in pairs(db.custom) do
		custom[#custom + 1] = name
	end
	if #custom > 0 then
		table.sort(custom)
		lines[#lines + 1] = " "
		lines[#lines + 1] = "|cffff8000Your names|r |cff999999(scanned everywhere)|r"
		for _, name in ipairs(custom) do
			lines[#lines + 1] = ("|cffffd100%s|r  %s"):format(name, Status(name))
		end
	end

	body:SetText(table.concat(lines, "\n"))
	content:SetHeight(body:GetStringHeight() + 8)
	scanButton:SetText(db.enabled and "Scanning: On" or "Scanning: Off")
	soundButton:SetText(db.sound and "Sound: On" or "Sound: Off")
end

function ns.ToggleList()
	if list:IsShown() then
		list:Hide()
	else
		list:Show()
	end
end

list:SetScript("OnShow", ns.RefreshList)

-- called by the scanner every tick
local lastRefresh = 0
function ns.OnTick()
	local now = GetTime()
	if now - lastRefresh >= 1 then
		lastRefresh = now
		ns.RefreshList()
	end
	-- drop the alert once its rare has been out of range for a while
	if shown and pending == nil then
		local s = ns.state[shown]
		local last = math.max(shownAt, s and s.seen or 0)
		if now - last > BUTTON_HIDE_SECONDS then
			SetButton(nil)
		end
	end
end
