-- Optional DragonUI integration. Without DragonUI's helpers the stock frames stay as they are.
local _, ns = ...

local S = {}
ns.Skin = S

local D = _G.DragonUI
local N = _G.DragonUI_NineSlice
local F = D and D.ForeverUI
local CP = D and D.CharacterPanel
local windowLayout = N and N.GetLayout and N.GetLayout("NoPortraitFrameTemplate")
local insetLayout = N and N.GetLayout and N.GetLayout("InsetFrameTemplate")
local cardLayout = N and N.GetLayout and N.GetLayout("SmallInsetFrameTemplate") or insetLayout
S.enabled = (D and D._dir and N and N.ApplyLayout and windowLayout and insetLayout) and true or false

local function tile(frame, file)
	local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
	texture:SetTexture(D._dir .. "UI\\" .. file, "REPEAT", "REPEAT")
	texture:SetHorizTile(true)
	texture:SetVertTile(true)
	texture:SetAllPoints(frame)
	return texture
end

local function closeButton(close, owner, x, y)
	if CP and CP.ModernizeCloseButton then
		CP.ModernizeCloseButton(close, owner, x, y)
	end
end

function S.Button(button)
	if S.enabled and D.SkinRedButton then
		D.SkinRedButton(button)
	end
end

-- The alert: a marble card under the small filigree trim, like DragonUI's own small panels.
function S.Alert(button, close)
	if not S.enabled then return end
	button:SetBackdrop(nil)
	tile(button, "ui-background-marble")
	N.ApplyLayout(button, cardLayout)
	closeButton(close, button, -2, -2)
end

-- The list window: rock ground under the bronze no-portrait chrome, the list on a marble inset.
function S.Window(frame, header, title, close, pane, scroll)
	if not S.enabled then return end
	frame:SetBackdrop(nil)
	local rock = tile(frame, "ui-background-rock")
	rock:ClearAllPoints()
	rock:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -21)
	rock:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)

	local chrome = CreateFrame("Frame", nil, frame)
	chrome:SetAllPoints(frame)
	chrome:SetFrameLevel(frame:GetFrameLevel() + 30)
	chrome:EnableMouse(false)
	N.ApplyLayout(chrome, windowLayout)

	-- The title moves into the chrome's title bar; the dialog header plate isn't needed there.
	header:Hide()
	title:SetParent(chrome)
	title:ClearAllPoints()
	title:SetPoint("TOP", frame, "TOP", 0, -5)

	close:SetFrameLevel(chrome:GetFrameLevel() + 5)
	closeButton(close, frame, 1, 0)

	pane:SetBackdrop(nil)
	pane:ClearAllPoints()
	pane:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -28)
	pane:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 44)
	tile(pane, "ui-background-marble")
	N.ApplyLayout(pane, insetLayout)

	if F and F.SkinScrollBar then
		F.SkinScrollBar(scroll)
	elseif CP and CP.ReskinScrollBar then
		CP.ReskinScrollBar(scroll, scroll, -7, 18, -7, true)
	end
end
