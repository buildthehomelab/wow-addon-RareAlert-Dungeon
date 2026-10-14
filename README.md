# RareAlert-Dungeons

A World of Warcraft **3.3.5a (Wrath of the Lich King)** addon that knows every rare spawn in the
dungeons, scans for them while you're inside, and alerts you when one is in range. It's a
dungeon-focused cross between unitscan and RareScanner.

## Features

- Built-in list of 29 dungeon rares, from Deviate Faerie Dragon in Wailing Caverns to Stonespine in
  Stratholme. The list comes from the AzerothCore world database: every rare or rare elite creature
  with a spawn on a dungeon map that rolls for its spawn, plus a few that quests summon.
- Rare-ranked NPCs that are there on every run (Lorgus Jett, the Blackrock Depths trio,
  Hearthsinger Forresten, the Karazhan Servant's Quarters trio and a few more) count as bosses:
  no alert and no marker for them
- Scans automatically in any dungeon on the list, only for that dungeon's rares
- Alert: raid-warning text, an orange screen flash, an optional sound (off by default, `/rare sound`), and a button you click to target the rare
- Puts a diamond raid marker on a rare once you target it (the alert button does that) or mouse over it
- Chat message on entering a dungeon that lists its rares
- `/rare` window lists the current dungeon's rares with their status (not seen, **nearby**, seen, killed),
  or every dungeon's rares when you're outside
- Any rare you target or mouse over triggers the alert too, including world rares that aren't on the list
  (but not the always-there bosses above)
- Add your own names with `/rare add`; those are scanned everywhere, like unitscan
- Stays quiet about a rare while it's nearby, and about its corpse after you kill it

## How scanning works

It uses the same trick as unitscan. `TargetUnit()` is a protected function, so when an addon calls
it the game raises a "blocked action" event, but only when a unit with that name is close enough
to target. RareAlert-Dungeons calls it for each rare twice a second and treats the event as "found". It
hides the blocked-action popup for its own calls and still shows it for every other addon.

A rare has to stay in range for 1.5 seconds before it alerts. On AzerothCore most dungeon rares
spawn every time and a script despawns them half a second later unless they win their spawn
roll, so without the wait you'd get an alert for a rare that isn't there. Rares you target or mouse
over alert right away.

Range is the client's visibility range, roughly 100 yards. Rares in a room you haven't reached yet
won't show up until you're close.

## Requirements

- A WoW 3.3.5a (12340) client. The built-in dungeon list matches rare names in English, so it needs an enUS or enGB client.
- The built-in list is built from the [AzerothCore](https://www.azerothcore.org) world database, so it fits AzerothCore servers. The addon runs entirely in the client and needs nothing on the server.

## Installation

1. Download this repo (Code → Download ZIP) and extract it.
2. Copy the inner `RareAlert-Dungeons` folder into your `Interface/AddOns` folder (`World of Warcraft/Interface/AddOns/`), so you end up with `Interface/AddOns/RareAlert-Dungeons/RareAlert-Dungeons.toc`.
3. Restart the game.

Upgrading from the old `RareAlert` folder: delete `Interface/AddOns/RareAlert` first, or both copies will load and alert twice. Settings start fresh under the new name.

If you also run unitscan, remove the dungeon names from it; both addons would alert for them.

## Usage

| Command | What it does |
| --- | --- |
| `/rare` | Show or hide the rare list |
| `/rare on`, `/rare off` | Turn scanning on or off |
| `/rare sound` | Toggle the alert sound (off by default) |
| `/rare flash` | Toggle the screen flash |
| `/rare mark` | Toggle the diamond raid marker on rares |
| `/rare add <name>` | Also scan for this name everywhere (exact, case-sensitive name) |
| `/rare remove <name>` | Stop scanning for a name you added |
| `/rare test` | Show a test alert |
| `/rare reset` | Forget which rares were seen or killed |

`/rarealert` works as well. On the alert: left-click targets the rare, right-click or the X dismisses
it, and shift-drag moves it. During combat the alert text (and sound, if on) still fire, but the button only
updates once combat ends, since the game locks secure buttons in combat.

## Limitations

- Names are English, so the dungeon list only matches on enUS/enGB clients. `/rare add` works in any language.
- The diamond goes on when the rare becomes your target or mouseover, not the moment the scan finds it:
  marking needs a unit, and the scan only knows the name. In a raid you need lead or assist to mark.
- A rare that shares its name with another creature nearby can set off an alert.
- The Fathom Stone and Dreadsteed rares only exist after their quest summons them.

## Troubleshooting

- **Every alert fires twice:** you still have the old `RareAlert` folder in `Interface/AddOns`. Delete it, since both copies load.
- **Alerts for the same rare from unitscan:** remove the dungeon names from unitscan; both addons alert for them.
- **No dungeon rares listed or detected:** the dungeon list only matches English names (enUS/enGB). `/rare add <name>` works in any language.
- **A rare in the next room doesn't alert:** the scan only reaches the client's visibility range, roughly 100 yards.
- **No diamond marker in a raid:** marking needs raid lead or assist.

## Credits

The scanning technique (calling the protected `TargetUnit()` and watching for the blocked-action event) is the one [unitscan](https://github.com/shirsig/unitscan) by shirsig uses. The implementation here is separate. The rare list comes from the AzerothCore world database.

Author: [buildthehomelab](https://github.com/buildthehomelab)

## License

Released under the [MIT License](LICENSE).
