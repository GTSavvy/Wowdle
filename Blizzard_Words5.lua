-- Blizzard_Words5.lua
-- Blizzard IP 5-letter words for WoWdle (Overwatch, StarCraft, Diablo, Hearthstone, HotS, WC3).
-- Every entry in this file must be exactly 5 letters. No exceptions.
-- List this file in your .toc AFTER WoWdle_Words5.lua so the table already exists.
-- WoWdle.lua will deduplicate on load, so any overlap with the WoW list is harmless.

WoWdle_Words = WoWdle_Words or {}
WoWdle_Words[5] = WoWdle_Words[5] or {}

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
    "TALON",    -- Terrorist villain organization
    "HELIX",    -- Helix Security International — OW lore faction

    -- Maps & locations
    "ILIOS",    -- Greek island control-point map
    "NEPAL",    -- Himalayan control-point map
    "OASIS",    -- Middle-Eastern control-point map
    "KINGS",    -- Kings Row — London hybrid map
    "BUSAN",    -- Korean control-point map

    -- Abilities & mechanics
    "PULSE",    -- Pulse Bomb — Tracer's ultimate
    "RALLY",    -- Rally — Brigitte's ultimate
    "BLADE",    -- Dragonblade — Genji's ultimate
    "VISOR",    -- Tactical Visor — Soldier: 76's ultimate
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
    "HYDRA",    -- Hydralisk — community shorthand
    "ULTRA",    -- Ultralisk — community shorthand
    "ROACH",    -- Zerg ranged armored ground unit
    "VIPER",    -- Zerg high-tech flying caster (SC2 HotS+)
    "RAVEN",    -- Terran mechanical support unit (SC2)
    "ADEPT",    -- Protoss mobile ranged unit (SC2 LotV)

    -- Buildings & structures
    "NEXUS",    -- Protoss command center / HotS hub world
    "PYLON",    -- Protoss power/supply structure
    "FORGE",    -- Protoss upgrade building
    "DEPOT",    -- Supply Depot — Terran supply building
    "SPORE",    -- Spore Crawler — Zerg anti-air static defense

    -- Terrain & game mechanics
    "CREEP",    -- Zerg terrain spread; buffs Zerg units
    "LARVA",    -- Zerg production mechanic; morphs into units
    "SPINE",    -- Spine Crawler — Zerg anti-ground static defense
    "NYDUS",    -- Nydus Worm / Nydus Canal transport network
    "MORPH",    -- Zerg & Protoss transformation mechanic
    "MACRO",    -- Macro play — economy and production management
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
    "SHADE",    -- Shade / Shadow Warrior enemy
    "SKULL",    -- Skull enemy / ubiquitous item and environmental motif

    -- Items & game mechanics
    "CACHE",    -- Nephalem Cache / Horadric Cache — loot reward
    "GRIFT",    -- Greater Rift — D3 timed endgame dungeon
    "ELITE",    -- Elite monster tier — yellow/blue champion enemies
    "TOPAZ",    -- Topaz gem — used across all Diablo games
    "TRAIT",    -- Trait — character progression node (D4)
    "FACET",    -- Jewel Facet — D2 gem type socketed into gear
    "MIGHT",    -- Might of the Earth — D3 Barbarian set / stat theme

    -- Locations
    "ULDUR",    -- Uldur's Cave — stronghold area in Diablo IV


    -- ============================================================
    -- HEARTHSTONE
    -- ============================================================

    -- Characters & famous cards
    "YSERA",    -- Ysera — Dragon Aspect legendary (Dream)
    "ELISE",    -- Elise Starseeker / Elise the Trailblazer
    "BRANN",    -- Brann Bronzebeard — Battlecry-doubling legendary
    "MORGL",    -- Morgl the Oracle — murloc shaman hero skin
    "CTHUN",    -- C'Thun — Old God legendary (Whispers of the Old Gods)
    "NZOTH",    -- N'Zoth the Corruptor — Old God legendary
    "HEMET",    -- Hemet Nesingwary — WoW/HS explorer character
    "ZEREK",    -- Zerek, Master Cloner — HS card (The Boomsday Project)

    -- Keywords & mechanics
    "TAUNT",    -- Taunt — evergreen HS keyword
    "SPELL",    -- Spell — core HS card type
    "COMBO",    -- Combo — Rogue mechanic keyword
    "JOUST",    -- Joust — The Grand Tournament keyword
    "ADAPT",    -- Adapt — Journey to Un'Goro keyword
    "BRAWL",    -- Tavern Brawl — weekly HS game mode

    -- Expansions & sets
    "ASHES",    -- Ashes of Outland — HS expansion (2020)
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
    "GRUNT",    -- Grunt — Orc front-line melee unit (WC2/WC3)
    "DRYAD",    -- Dryad — Night Elf ranged support unit (WC3)

    -- ============================================================
    -- SHARED / CROSS-BLIZZARD
    -- ============================================================
    "STORM",    -- Heroes of the Storm / "Into the Storm" / countless references
}

-- Merge into the answer pool; WoWdle.lua deduplicates on load.
for _, w in ipairs(_bliz5) do
    w = w:upper()
    if #w == 5 then
        table.insert(WoWdle_Words[5], w)
    end
end
