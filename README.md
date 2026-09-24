# RareAlert-Dungeons

A World of Warcraft **3.3.5a (Wrath of the Lich King)** addon that knows every rare spawn in the
dungeons, scans for them while you're inside, and alerts you when one is in range. It's a
dungeon-focused cross between unitscan and RareScanner.

## Features

- Built-in list of 40 dungeon rares, from Deviate Faerie Dragon in Wailing Caverns to the Karazhan
  Servant's Quarters trio. The list comes from the AzerothCore world database: every rare or rare
  elite creature with a spawn on a dungeon map, plus a few that scripts or quests spawn.
- Scans automatically in any dungeon on the list, only for that dungeon's rares
- Alert: raid-warning text, a sound, an orange screen flash, and a button you click to target the rare
- Chat message on entering a dungeon that lists its rares
- `/rare` window lists the current dungeon's rares with their status (not seen, **nearby**, seen, killed),
  or every dungeon's rares when you're outside
- Any rare you target or mouse over triggers the alert too, including world rares that aren't on the list
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

## Install

1. Download this repo (Code → Download ZIP) and extract it.
2. Copy the inner `RareAlert-Dungeons` folder into `World of Warcraft/Interface/AddOns/`, so you end up with `Interface/AddOns/RareAlert-Dungeons/RareAlert-Dungeons.toc`.
3. Restart the game.

Upgrading from the old `RareAlert` folder: delete `Interface/AddOns/RareAlert` first, or both copies will load and alert twice. Settings start fresh under the new name.

If you also run unitscan, remove the dungeon names from it; both addons would alert for them.

## Usage

| Command | What it does |
| --- | --- |
| `/rare` | Show or hide the rare list |
| `/rare on`, `/rare off` | Turn scanning on or off |
| `/rare sound` | Toggle the alert sound |
| `/rare flash` | Toggle the screen flash |
| `/rare add <name>` | Also scan for this name everywhere (exact, case-sensitive name) |
| `/rare remove <name>` | Stop scanning for a name you added |
| `/rare test` | Show a test alert |
| `/rare reset` | Forget which rares were seen or killed |

`/rarealert` works as well. On the alert: left-click targets the rare, right-click or the X dismisses
it, and shift-drag moves it. During combat the alert text and sound still fire, but the button only
updates once combat ends, since the game locks secure buttons in combat.

## Limitations

- Names are English, so the dungeon list only matches on enUS/enGB clients. `/rare add` works in any language.
- A rare that shares its name with another creature nearby can set off an alert.
- The Fathom Stone, Dreadsteed and Karazhan rares only exist after their event or quest spawns them.
