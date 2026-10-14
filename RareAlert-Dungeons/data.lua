-- Dungeon rares, generated from the AzerothCore world DB (creature_template rank 2/4 with a
-- spawn on a dungeon map), plus the scripted spawns listed with a note. Only rares that roll
-- for their spawn (SmartAI "On AI Init - Despawn" or a pool chance) are listed.
-- zone: the name GetRealZoneText() returns (enUS); aliases: other names the client may use.
local _, ns = ...

ns.instances = {
	{
		zone = "Wailing Caverns", levels = "15-25",
		rares = {
			{ id = 5912, name = "Deviate Faerie Dragon", level = "19", elite = true },
		},
	},
	{
		zone = "The Deadmines", levels = "15-21",
		aliases = { "Deadmines" },
		rares = {
			{ id = 3586, name = "Miner Johnson", level = "19", elite = true },
		},
	},
	{
		zone = "Shadowfang Keep", levels = "18-25",
		rares = {
			{ id = 3872, name = "Deathsworn Captain", level = "21", elite = true },
		},
	},
	{
		zone = "Blackfathom Deeps", levels = "20-30",
		rares = {
			{ id = 12876, name = "Baron Aquanis", level = "24", elite = true, note = "Summoned from the Fathom Stone (quest)" },
		},
	},
	{
		zone = "The Stockade", levels = "22-30",
		aliases = { "Stormwind Stockade" },
		rares = {
			{ id = 1720, name = "Bruegal Ironknuckle", level = "25", elite = true },
		},
	},
	{
		zone = "Gnomeregan", levels = "24-34",
		rares = {
			{ id = 6228, name = "Dark Iron Ambassador", level = "28", elite = true },
		},
	},
	{
		zone = "Razorfen Kraul", levels = "24-34",
		rares = {
			{ id = 4425, name = "Blind Hunter", level = "27", elite = true },
			{ id = 4842, name = "Earthcaller Halmgar", level = "27", elite = true },
		},
	},
	{
		zone = "Scarlet Monastery", levels = "26-45",
		rares = {
			{ id = 6490, name = "Azshir the Sleepless", level = "32", elite = true },
			{ id = 6488, name = "Fallen Champion", level = "32", elite = true },
			{ id = 6489, name = "Ironspine", level = "32", elite = true },
		},
	},
	{
		zone = "Razorfen Downs", levels = "33-43",
		rares = {
			{ id = 7354, name = "Ragglesnout", level = "37", elite = true },
		},
	},
	{
		zone = "Zul'Farrak", levels = "42-50",
		rares = {
			{ id = 10080, name = "Sandarr Dunereaver", level = "45", elite = true },
			{ id = 10082, name = "Zerillis", level = "45", elite = true },
			{ id = 10081, name = "Dustwraith", level = "46", elite = true },
		},
	},
	{
		zone = "Maraudon", levels = "40-52",
		rares = {
			{ id = 12237, name = "Meshlok the Harvester", level = "46", elite = true },
		},
	},
	{
		zone = "Blackrock Depths", levels = "52-60",
		rares = {
			{ id = 8923, name = "Panzor the Invincible", level = "56", elite = true },
		},
	},
	{
		zone = "Blackrock Spire", levels = "55-60",
		rares = {
			{ id = 10263, name = "Burning Felguard", level = "56-57", elite = true },
			{ id = 9219, name = "Spirestone Butcher", level = "57", elite = true },
			{ id = 9218, name = "Spirestone Battle Lord", level = "58", elite = true },
			{ id = 9217, name = "Spirestone Lord Magus", level = "58", elite = true },
			{ id = 9596, name = "Bannok Grimaxe", level = "59", elite = true },
			{ id = 9718, name = "Ghok Bashguud", level = "59", elite = true },
			{ id = 10509, name = "Jed Runewatcher", level = "59", elite = true },
			{ id = 10376, name = "Crystal Fang", level = "60", elite = true },
		},
	},
	{
		zone = "Dire Maul", levels = "55-60",
		rares = {
			{ id = 11467, name = "Tsu'zee", level = "59", elite = true },
			{ id = 14506, name = "Lord Hel'nurath", level = "62", elite = true, note = "Summoned during the warlock Dreadsteed quest" },
		},
	},
	{
		zone = "Stratholme", levels = "58-60",
		rares = {
			{ id = 10393, name = "Skul", level = "58", elite = true },
			{ id = 10809, name = "Stonespine", level = "60", elite = true },
		},
	},
}

-- Rare-ranked NPCs that are there on every run, so they are bosses, not rares: no alert and no
-- mark when you target or mouse over them (unless you /rare add them).
ns.alwaysSpawn = {
	["Razorfen Spearhide"] = true,      -- Razorfen Kraul, two fixed spawns
	["Lorgus Jett"] = true,             -- Blackfathom Deeps, one of three spots
	["Spawn of Hakkar"] = true,         -- Sunken Temple, one of two spots
	["Pyromancer Loregrain"] = true,    -- Blackrock Depths
	["Verek"] = true,
	["Warder Stilgiss"] = true,
	["Goraluk Anvilcrack"] = true,      -- Upper Blackrock Spire
	["Hearthsinger Forresten"] = true,  -- Stratholme
	["Hyakiss the Lurker"] = true,      -- Karazhan Servant's Quarters, one of the three every reset
	["Shadikith the Glider"] = true,
	["Rokad the Ravager"] = true,
}
