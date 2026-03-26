-- WoWdle_Words6.lua
-- WoW-themed 6-letter words for WoWdle.
-- Every entry in this file must be exactly 6 letters. No exceptions.
-- Add new words here; WoWdle.lua will deduplicate on load.

WoWdle_Words = WoWdle_Words or {}
WoWdle_Words[6] = {
    -- Races
    "TAUREN", "WORGEN", "GOBLIN", "UNDEAD",

    -- Classes & specs
    "SHAMAN", "HUNTER", "PRIEST", "ARCANE",
    "OUTLAW", "WARDEN", "RETRIB",

    -- Named characters & lore figures
    "THRALL", "ANDUIN", "ARTHAS", "TIRION", "CAIRNE",
    "REHGAR", "MEDIVH", "GULDAN", "VARIAN", "BOLVAR",
    "ONYXIA", "XAVIUS", "KILROG", "LOTHAR", "ORGRIM",
    "GARONA", "TICHON", "ATIESH", "ZULJIN", "LEEROY",

    -- Locations & zones
    "ORIBOS", "ULDUAR", "ARATHI", "UNGORO", "GADGET",
    "BOREAN", "AZSUNA", "NAZMIR", "VOLDUN", "ASHRAN",
    "TANAAN", "SILVER", "TARREN", "BROKEN",

    -- Dungeons & raids
    "MOLTEN", "UTGARD", "VIOLET", "THRONE", "SCHOLO",
    "STRATH", "LEGION", "DELVES",

    -- Creatures & mobs
    "MURLOC", "KOBOLD", "WRAITH", "VRYKUL", "DRAGON",
    "MANTID", "SAUROK", "TROGGS", "GNOLLS", "WYVERN",
    "RAPTOR", "ZOMBIE", "SPIDER",

    -- Abilities & spells
    "ENRAGE", "SUMMON", "DISPEL", "SOOTHE", "SCORCH",
    "SHROUD", "VANISH", "AMBUSH", "KIDNEY", "CHARGE",
    "SHIELD", "HAMMER", "HEROIC", "MORTAL", "FROZEN",
    "BREATH", "MIRROR", "PORTAL", "ASCEND", "WARCRY",
    "BATTLE", "AVATAR", "PRAYER", "CHAKRA", "CIRCLE",
    "MANGLE", "SAVAGE", "THRASH", "ASPECT", "VOLLEY",
    "DEVOUR", "BANISH", "LIVING", "AVENGE", "REBUKE",
    "IGNORE", "FADING", "FRENZY",

    -- Gear & items
    "ELIXIR", "POTION", "SCROLL", "TABARD", "HEARTH",
    "AMULET", "HELMET", "GLAIVE", "DAGGER", "QUIVER",
    "MALLET", "BRACER", "GORGET", "GIRDLE", "SOCKET",
    "FLASKS", "RECIPE", "LOCKET", "BUCKLE",

    -- Stats & currencies
    "SPIRIT", "RATING", "ATTACK", "ABSORB", "RENOWN",
    "TROPHY", "COFFER", "MYTHIC",

    -- General WoW terms & culture
    "TALENT", "REBUFF", "GANKED", "WASTES", "SUNKEN",
    "DEPTHS", "SHADOW", "RAIDER", "HEALER", "NORMAL",
    "MINING", "ARMORY", "STABLE", "FLIGHT", "FLYING",
    "GROUND", "TAMING", "INVITE", "QUEUED", "KICKED",
    "LEAVER", "PUGGED", "HOTFIX", "NERFED", "BUFFED",
    "REROLL", "BOUNTY", "WEEKLY", "NINJAS", "TWINKS",
    "LOOTED",

    -- Shadowlands
    "STYGIA", "ZERETH",

    -- Shadowlands / BfA bosses & characters
    "HAKKAR", "JAILER", "MOTHER", "CINDER",

    -- Dragonflight bosses
    "FYRAKK", "RASHOK", "ZSKARN",

}

-- Snapshot the core WoW-only words before any other file can append to WoWdle_Words[6].
WoWdle_CoreWords = WoWdle_CoreWords or {}
WoWdle_CoreWords[6] = {}
for _, w in ipairs(WoWdle_Words[6]) do
    table.insert(WoWdle_CoreWords[6], w)
end
