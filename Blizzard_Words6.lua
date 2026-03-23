-- Blizzard_Words6.lua
-- Blizzard IP 6-letter words for WoWdle (Overwatch, StarCraft, Diablo, Hearthstone, HotS, WC3).
-- Every entry in this file must be exactly 6 letters. No exceptions.
-- List this file in your .toc AFTER WoWdle_Words6.lua so the table already exists.
-- WoWdle.lua will deduplicate on load, so any overlap with the WoW list is harmless.

WoWdle_Words = WoWdle_Words or {}
WoWdle_Words[6] = WoWdle_Words[6] or {}

local _bliz6 = {

    -- ============================================================
    -- OVERWATCH / OVERWATCH 2
    -- ============================================================

    -- Heroes & characters
    "REAPER",   -- DPS hero; wraith-form edgelord (Gabriel Reyes)
    "TRACER",   -- DPS hero; OW's mascot (Lena Oxton)
    "PHARAH",   -- DPS hero; rocket-launcher soldier (Fareeha Amari)
    "SOMBRA",   -- DPS hero; Mexican hacker
    "KIRIKO",   -- Support hero; Japanese shrine maiden (OW2)

    -- Maps & locations
    "DORADO",   -- El Dorado — Mexico payload map
    "RIALTO",   -- Rialto — Venice, Italy payload map
    "AURORA",   -- Aurora ship in OW lore (Numbani origin story)

    -- Abilities & mechanics
    "RECALL",   -- Tracer's time-reversal ability / OW animated short title
    "MATRIX",   -- D.Va's Defence Matrix ability
    "SENTRY",   -- Bastion's Sentry configuration / turret mode
    "TURRET",   -- Torbjörn's deployable turret

    -- ============================================================
    -- STARCRAFT / STARCRAFT II
    -- ============================================================

    -- Units
    "ZEALOT",   -- Protoss front-line melee warrior
    "LURKER",   -- Zerg burrowed anti-ground unit (SC1 / SC2 LotV)
    "VIKING",   -- Terran air/ground transformer unit (SC2)
    "REAPER",   -- Terran cliff-jumping raider unit (SC2)
    "ORACLE",   -- Protoss harass/detection unit (SC2 HotS+)

    -- Buildings & structures
    "BUNKER",   -- Terran static defense structure
    "ARMORY",   -- Terran upgrade building (vehicle/ship weapons)

    -- Characters
    "RAYNOR",   -- Jim Raynor — Terran protagonist across all SC games
    "TYCHUS",   -- Tychus Findlay — Terran outlaw, SC2 Wings of Liberty
    "DEHAKA",   -- Dehaka — primal Zerg pack leader (SC2 / HotS)
    "ZAGARA",   -- Zagara — Zerg swarm queen (SC2 / HotS)
    "ALARAK",   -- Alarak — Tal'darim Highlord (SC2 LotV / HotS)
    "STUKOV",   -- Alexei Stukov — infested Terran (SC / HotS)
    "HORNER",   -- Matt Horner — Raynor's Raiders captain (SC2)

    -- Game mechanics & terms
    "SUPPLY",   -- Supply cap resource (food/supply/psi)
    "INJECT",   -- Queen larva inject — core Zerg macro mechanic
    "PYLONS",   -- "You must construct additional pylons" — iconic SC line
    "BURROW",   -- Zerg burrow ability — core stealth mechanic
    "CHRONO",   -- Chrono Boost — Protoss Nexus ability
    "CHEESE",   -- Cheese strategy — all-in early aggression (beloved SC term)

    -- ============================================================
    -- DIABLO  (I, II, III, IV, Immortal)
    -- ============================================================

    -- Characters & major lore figures
    "TYRAEL",   -- Tyrael — Archangel of Justice; recurring protagonist
    "DIABLO",   -- The Prime Evil, Lord of Terror; namesake of the series
    "LEORIC",   -- King Leoric — the Skeleton King; D2 & D3 boss
    "ZOLTUN",   -- Zoltun Kulle — rogue Horadrim mage; D3 Act II
    "LILITH",   -- Lilith — Daughter of Mephisto; Diablo IV main villain
    "CYDAEA",   -- Cydaea — Maiden of Lust; D3 Act III boss
    "RATHMA",   -- Rathma — first Necromancer; D3 lore and set name
    "LORATH",   -- Lorath Nahr — main D4 story companion
    "KADALA",   -- Kadala — Blood Shard gambler vendor (D3)
    "DURIEL",   -- Duriel — Lord of Pain; Act II D2 boss (infamous difficulty spike)
    "URZAEL",   -- Urzael — D3 Reaper of Souls flying boss
    "AURIEL",   -- Auriel — Archangel of Hope; D3 Reaper of Souls
    "BELIAL",   -- Belial — Lord of Lies; D3 Act II boss

    -- Monsters & enemy types
    "FALLEN",   -- Fallen — iconic imp-like enemy since D1
    "ZOMBIE",   -- Zombie — D1/D3 undead enemy
    "WRAITH",   -- Wraith — spectral undead enemy type
    "SAVAGE",   -- Savage beast enemy type
    "WARDEN",   -- Warden / Dungeon Warden enemy (D4)
    "HERALD",   -- Herald of Pestilence — D3 Reaper of Souls enemy
    "LACUNI",   -- Lacuni — panther-like panther enemy (D3 Act II)
    "PLAGUE",   -- Plague — enemy affix and zone theme

    -- Items, gear & mechanics
    "SCYTHE",   -- Scythe — core Necromancer weapon type
    "AMULET",   -- Amulet — neck slot gear across all Diablo games
    "PORTAL",   -- Town Portal — foundational Diablo mechanic
    "SHRINE",   -- Shrine — interactable buff object in all Diablo games
    "SOCKET",   -- Socket — item modification system
    "QUIVER",   -- Quiver — Demon Hunter off-hand slot (D3)
    "SEASON",   -- Season — timed ladder content cycle
    "PRIMAL",   -- Primal Ancient — highest item tier in D3
    "MANTRA",   -- Mantra — Monk ability category (D3)
    "SIGNET",   -- Signet ring — item type (D2 / D4)
    "SICKLE",   -- Sickle — Necromancer one-hand weapon type
    "SPATHA",   -- Spatha — sword type; Diablo weapon base

    -- Locations
    "KURAST",   -- Kurast — Act III D2 jungle city
    "ARREAT",   -- Mount Arreat — Barbarian homeland (D2 Act V)
    "CANYON",   -- Canyon of the Magi — D2 Act II desert location
    "CAVERN",   -- Cavern of the Moon Clan / various Diablo cavern zones
    "SEWERS",   -- Sewers of Caldeum — D3 Act II location
    "FIELDS",   -- Fields of Misery — D3 Act I open zone

    -- ============================================================
    -- HEARTHSTONE
    -- ============================================================

    -- Characters & famous cards
    "HAKKAR",   -- Hakkar the Soulflayer — Rastakhan's Rumble legendary
    "FINLEY",   -- Sir Finley Mrrgglton / Finley of the Frogs — murloc explorer

    -- Keywords & mechanics
    "DIVINE",   -- Divine Shield — evergreen HS keyword
    "FREEZE",   -- Freeze — mechanic / keyword (Mage)
    "POISON",   -- Poisonous — keyword (kills any minion it damages)
    "CHARGE",   -- Charge — legacy evergreen keyword
    "INFUSE",   -- Infuse — Murder at Castle Nathria keyword
    "REBORN",   -- Reborn — Saviors of Uldum keyword (revives at 1 HP)
    "DREDGE",   -- Dredge — Voyage to the Sunken City keyword
    "LACKEY",   -- Lackey tokens — Descent of Dragons mechanic
    "INVOKE",   -- Invoke — Descent of Dragons / Galakrond keyword
    "SECRET",   -- Secret — trap card type; iconic HS mechanic

    -- Expansions & sets
    "UNGORO",   -- Journey to Un'Goro — HS expansion (2017)
    "GADGET",   -- Mean Streets of Gadgetzan — HS expansion (2016)
    "SUNKEN",   -- Voyage to the Sunken City — HS expansion (2022)
    "TANAAN",   -- Tanaan Jungle — WoW zone referenced in HS cards
    "TITANS",   -- TITANS — HS expansion (2023)
    "MURDER",   -- Murder at Castle Nathria — HS expansion (2022)
    "VOYAGE",   -- Voyage to the Sunken City — HS expansion shorthand
    "FORGED",   -- Forged in the Barrens — HS expansion (2021)

    -- ============================================================
    -- HEROES OF THE STORM
    -- ============================================================

    -- Heroes (6-letter names)
    "LEORIC",   -- Leoric the Skeleton King — Diablo crossover
    "ALARAK",   -- Alarak — StarCraft crossover (already in SC section)
    "LUNARA",   -- Lunara — Night Elf dryad hero (original HotS lore)
    "ZAGARA",   -- Zagara — StarCraft crossover (already in SC section)
    "DEHAKA",   -- Dehaka — StarCraft crossover (already in SC section)
    "CASSIA",   -- Cassia — Amazon hero; Diablo II crossover in HotS
    "SAMURO",   -- Samuro — Blademaster; WC3 crossover in HotS
    "REXXAR",   -- Rexxar — Beastmaster; WC3/WoW/HS crossover in HotS

    -- ============================================================
    -- WARCRAFT III  (RTS era, pre-WoW)
    -- ============================================================

    -- Units & hero types
    "KEEPER",   -- Keeper of the Grove — Night Elf hero unit (WC3)
    "KNIGHT",   -- Knight — Paladin-class mounted Human cavalry (WC3)
    "MORTAR",   -- Mortar Team — Dwarven artillery unit (WC3)
    "COUATL",   -- Couatl — Night Elf flying support unit (WC3)

    -- ============================================================
    -- SHARED / CROSS-BLIZZARD
    -- ============================================================
    "ARCADE",   -- Blizzard Arcade (SC2 custom maps) / OW Arcade mode
    "RANKED",   -- Ranked play system across all Blizzard titles
    "LADDER",   -- Competitive ladder (SC especially iconic)
    "LEAGUE",   -- Grand Master League (SC2) / league ranking system
    "ESPORT",   -- Esports — Blizzard is foundational to competitive gaming
}

-- Merge into the answer pool; WoWdle.lua deduplicates on load.
for _, w in ipairs(_bliz6) do
    w = w:upper()
    if #w == 6 then
        table.insert(WoWdle_Words[6], w)
    end
end
