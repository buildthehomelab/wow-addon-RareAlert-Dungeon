-- Dungeon rares, generated from the AzerothCore world DB (creature_template rank 2/4 with a
-- spawn on a dungeon map), plus the scripted spawns listed with a note.
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
			{ id = 12902, name = "Lorgus Jett", level = "24", elite = true },
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
			{ id = 4438, name = "Razorfen Spearhide", level = "25-26", elite = true },
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
		zone = "The Temple of Atal'Hakkar", levels = "45-55",
		aliases = { "Sunken Temple" },
		rares = {
			{ id = 5708, name = "Spawn of Hakkar", level = "49", elite = true },
		},
	},
	{
		zone = "Blackrock Depths", levels = "52-60",
		rares = {
			{ id = 9024, name = "Pyromancer Loregrain", level = "52", elite = true },
			{ id = 9042, name = "Verek", level = "53", elite = true },
			{ id = 9041, name = "Warder Stilgiss", level = "54", elite = true },
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
			{ id = 10899, name = "Goraluk Anvilcrack", level = "61", elite = true },
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
			{ id = 10558, name = "Hearthsinger Forresten", level = "57", elite = true },
			{ id = 10393, name = "Skul", level = "58", elite = true },
			{ id = 10809, name = "Stonespine", level = "60", elite = true },
		},
	},
	{
		zone = "Karazhan", levels = "70",
		rares = {
			{ id = 16179, name = "Hyakiss the Lurker", level = "73", elite = true, note = "Servant's Quarters; one of the three spawns per reset" },
			{ id = 16180, name = "Shadikith the Glider", level = "73", elite = true, note = "Servant's Quarters; one of the three spawns per reset" },
			{ id = 16181, name = "Rokad the Ravager", level = "73", elite = true, note = "Servant's Quarters; one of the three spawns per reset" },
		},
	},
}
