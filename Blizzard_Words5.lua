-- Blizzard_Words5.lua
-- Blizzard IP 5-letter words for WoWdle (Overwatch, StarCraft, Diablo, Hearthstone, HotS, WC3).
-- Every entry in this file must be exactly 5 letters. No exceptions.
-- List this file in your .toc AFTER WoWdle_Words5.lua so the table already exists.
-- WoWdle.lua will deduplicate on load, so any overlap with the WoW list is harmless.
-- These words are only included in the answer pool when the "Blizzard Words" option is enabled.

WoWdle_BlizzardWords = WoWdle_BlizzardWords or {}
WoWdle_BlizzardWords[5] = WoWdle_BlizzardWords[5] or {}

local _bliz5 = {

    -- ============================================================
    -- OVERWATCH / OVERWATCH 2
    -- ============================================================

    -- Heroes & characters
    "MERCY",    -- Support hero; Valkyrie suit medic
    "MOIRA",    -- Support hero; geneticist
    "SIGMA",    -- Tank hero; astrophysicist
    "ORISA",    -- Tank hero; Numbani OR15 robot
    "LUCIO",    -- Support hero; Brazilian DJ (Lúcio)
    "REYES",    -- Gabriel Reyes — Reaper's real name
    "GENJI",    -- DPS hero; cyberninja (Genji Shimada)
    "HANZO",    -- DPS hero; archer (Hanzo Shimada)
    "ZARYA",    -- Tank hero; Russian weightlifter (Zarya)
    "WIDOW",    -- Widowmaker — iconic OW sniper shorthand
    "MAUGA",    -- Tank hero; Samoan soldier (OW2)
    "VALLA",    -- Demon Hunter — Diablo crossover via HotS

    -- Factions & lore
    "OMNIC",    -- Sentient robot race at the heart of the Crisis
    "HELIX",    -- Helix Security International — OW lore faction

    -- Maps & locations
    "ILIOS",    -- Greek island control-point map
    "NEPAL",    -- Himalayan control-point map
    "OASIS",    -- Middle-Eastern control-point map
    "KINGS",    -- Kings Row — London hybrid map
    "BUSAN",    -- Korean control-point map

    -- Abilities & mechanics
    "PULSE",    -- Pulse Bomb — Tracer's ultimate
    "VENOM",    -- Venom Mine — Widowmaker ability
    "EMOTE",    -- Cosmetic emote system across all Blizzard titles

    -- ============================================================
    -- STARCRAFT / STARCRAFT II
    -- ============================================================

    -- Races & factions
    "BROOD",    -- Zerg Brood grouping (e.g., Garm Brood)
    "SWARM",    -- Heart of the Swarm / Zerg collective identity

    -- Units
    "DRONE",    -- Zerg worker unit
    "QUEEN",    -- Zerg macro/production/defense unit
    "GHOST",    -- Terran covert ops unit; uses Nuke and EMP
    "MEDIC",    -- Terran support unit (SC1 / SCR)
    "SCOUT",    -- Protoss air unit (SC1 / SCR)
    "PROBE",    -- Protoss worker unit
    "ULTRA",    -- Ultralisk — community shorthand
    "ROACH",    -- Zerg ranged armored ground unit
    "ADEPT",    -- Protoss mobile ranged unit (SC2 LotV)

    -- Buildings & structures
    "PYLON",    -- Protoss power/supply structure
    "DEPOT",    -- Supply Depot — Terran supply building
    "SPORE",    -- Spore Crawler — Zerg anti-air static defense

    -- Terrain & game mechanics
    "CREEP",    -- Zerg terrain spread; buffs Zerg units
    "LARVA",    -- Zerg production mechanic; morphs into units
    "SPINE",    -- Spine Crawler — Zerg anti-ground static defense
    "NYDUS",    -- Nydus Worm / Nydus Canal transport network
    "MORPH",    -- Zerg & Protoss transformation mechanic
    "MICRO",    -- Micro play — individual unit control skill

    -- Characters
    "NARUD",    -- Shape-shifting Xel'Naga villain (SC2 HotS)
    "IZSHA",    -- Zerg advisor to Kerrigan (SC2 HotS)

    -- ============================================================
    -- DIABLO  (I, II, III, IV, Immortal)
    -- ============================================================

    -- Classes (community shorthand)
    "WITCH",    -- Witch Doctor class (D3)
    "NECRO",    -- Necromancer — community shorthand

    -- Characters
    "ADRIA",    -- Adria the Witch — D3 story antagonist (Leah's mother)
    "IZUAL",    -- Izual — fallen angel boss (D2 & D3)

    -- Monsters & enemy types
    "LEECH",    -- Blood Leech / Cave Leech enemy (D2)
    "FETCH",    -- Fetish enemy type — jungle creatures (D3 Act III)

    -- Items & game mechanics
    "GRIFT",    -- Greater Rift — D3 timed endgame dungeon
    "TOPAZ",    -- Topaz gem — used across all Diablo games
    "TRAIT",    -- Trait — character progression node (D4)
    "FACET",    -- Jewel Facet — D2 gem type socketed into gear
    "MIGHT",    -- Might of the Earth — D3 Barbarian set / stat theme
    "RIFTS",    -- Nephalem Rifts — the central D3/Diablo Immortal endgame loop
    "KANAI",    -- Kanai's Cube — the iconic D3 legendary power extraction system

    -- Locations
    "ULDUR",    -- Uldur's Cave — stronghold area in Diablo IV

    -- ============================================================
    -- HEARTHSTONE
    -- ============================================================

    -- Characters & famous cards
    "ELISE",    -- Elise Starseeker / Elise the Trailblazer
    "MORGL",    -- Morgl the Oracle — murloc shaman hero skin
    "NZOTH",    -- N'Zoth the Corruptor — Old God legendary
    "ZEREK",    -- Zerek, Master Cloner — HS card (The Boomsday Project)

    -- Keywords & mechanics
    "SPELL",    -- Spell — core HS card type
    "COMBO",    -- Combo — Rogue mechanic keyword
    "JOUST",    -- Joust — The Grand Tournament keyword
    "ADAPT",    -- Adapt — Journey to Un'Goro keyword
    "BRAWL",    -- Tavern Brawl — weekly HS game mode

    -- Expansions & sets
    "MARCH",    -- March of the Lich King — HS expansion (2022)
    "TWIST",    -- Twist — rotating HS format with special rules

    -- ============================================================
    -- HEROES OF THE STORM
    -- ============================================================

    -- Heroes
    "SONYA",    -- Sonya — Barbarian hero (Diablo crossover)
    "FENIX",    -- Fenix — Protoss hero (StarCraft crossover)
    "BLAZE",    -- Blaze — Terran firebat hero (StarCraft crossover)
    "QHIRA",    -- Qhira — original HotS lore hero

    -- Game mechanics
    "GLOBE",    -- Regeneration Globe — HotS health pickup

    -- ============================================================
    -- WARCRAFT III  (RTS era, non-WoW)
    -- ============================================================

    -- Units & heroes

    -- ============================================================
    -- SHARED / CROSS-BLIZZARD
    -- ============================================================
}

-- Merge into the Blizzard word pool; WoWdle.lua deduplicates on load.
for _, w in ipairs(_bliz5) do
    w = w:upper()
    if #w == 5 then
        table.insert(WoWdle_BlizzardWords[5], w)
    end
end
