-- WoWdle_Words5.lua
-- WoW-themed 5-letter words for WoWdle.
-- Every entry in this file must be exactly 5 letters. No exceptions.
-- Add new words here; WoWdle.lua will deduplicate on load.

WoWdle_Words = WoWdle_Words or {}
WoWdle_Words[5] = {
    -- Races
    "GNOME", "DWARF", "TROLL", "DRUID", "NIGHT",
    "PANDA",

    -- Classes & specs
    "ROGUE", "FROST", "DEATH", "DEMON", "FERAL",
    "RESTO", "HAVOC", "BLOOD", "MELEE", "HEALS",

    -- Named characters & lore figures
    "JAINA", "VELEN", "ELUNE", "UTHER", "MAIEV",
    "MURKY", "YSERA",

    -- Locations & zones
    "NEXUS", "FORGE", "VAULT", "REALM", "ARENA",
    "STORM", "ULDUM", "SIEGE",

    -- Creatures & mobs
    "GOLEM", "DRAKE", "BEAST", "TALON", "BEARS",
    "HYDRA", "HARPY", "GNOLL", "WHELP", "GHOUL",
    "VIPER", "NYMPH", "DEMON",

    -- Abilities & spells
    "STABS", "CURSE", "GLYPH", "CHARM", "GRACE",
    "FLAME", "BLADE", "SPEAR", "SMITE", "BLINK",
    "SWEEP", "SHOUT", "TAUNT", "PARRY", "DODGE",
    "BLOCK", "REPEL", "PURGE", "SHEEP", "ROOTS",
    "STUNS", "HEXED", "FEARS", "SNARE", "RALLY",
    "REVEL", "BLIND", "ERUPT", "LUNGE", "RUNES",
    "FLARE",

    -- Gear & items
    "SHARD", "TOTEM", "SIGIL", "ANVIL", "EMBER",
    "ARROW", "STAFF", "CLOAK", "RINGS", "BOOTS",
    "CHEST", "CRYPT", "ALTAR", "BADGE", "TOKEN",
    "CREST", "RELIC", "AEGIS", "SABER", "CANON",
    "VISOR", "QUILL", "PRISM", "FLASK", "GLOVE",
    "WAIST", "WRIST", "SWORD",

    -- Stats & currencies
    "MAGIC", "POWER", "FOCUS", "HONOR", "VALOR",
    "HASTE", "ARMOR", "MOXIE", "VIGOR",

    -- General WoW terms & culture
    "QUEST", "HORDE", "GUILD", "PATCH", "GRIND",
    "AGGRO", "TWINK", "PARSE", "PULLS", "TRASH",
    "PHASE", "RESET", "GRIEF", "SEVER", "CROSS",

    -- Warcraft RTS / lore terms
    "OGRES", "ELVES", "TITAN", "NAARU", "LITCH",
    "RAVEN", "EAGLE", "CROWS",

    -- Geography & scenery
    "SWAMP", "BAYOU", "RUINS", "TOMBS", "DELTA",
    "RIDGE", "SHORE", "HAVEN", "GROVE", "GLADE",
    "PEAKS", "SPIRE", "TOWER",

    -- Structures & places
    "MISTS", "COVEN", "CABAL", "ORDER", "LODGE",
    "HALLS", "MANOR", "ABBEY", "TOMES",

    -- Shadowlands
    "ANIMA", "TORGA", "REZAN",

    -- Battle for Azeroth
    "GRONG", "DAZAR", "TALOC",

    -- Dragonflight
    "ASHEN", "MAGMA", "WRATH", "CHAOS", "SPITE",
    "DREAD", "GLOOM", "SHADE", "ABYSS", "VOIDS",
    "TIDAL", "BRINE", "CORAL", "NAGAS", "SIREN",
    "CTHUN", "SYLVA", "NYMUE", "IGIRA",

    -- The War Within
    "DELVE", "NERUB", "DOKAH",
}

-- Snapshot the core WoW-only words before any other file can append to WoWdle_Words[5].
-- WoWdle.lua uses WoWdle_CoreWords to build the daily pool so it stays consistent
-- regardless of which optional word files the player has installed.
WoWdle_CoreWords = WoWdle_CoreWords or {}
WoWdle_CoreWords[5] = {}
for _, w in ipairs(WoWdle_Words[5]) do
    table.insert(WoWdle_CoreWords[5], w)
end
