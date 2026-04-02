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
    "STRATH", "LEGION",

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

    -- The War Within
    "SUREKI",   -- TWW — nerubian spider sub-faction in Azj-Kahet
    "ALGARI",   -- TWW — demonym for Khaz Algar inhabitants; used throughout TWW
    "HOGGER",   -- Hogger — infamous vanilla WoW gnoll boss; Warcraft Rumble leader

    -- Midnight
    "FUNGAL",   -- Harandar is a bioluminescent fungal jungle biome
    "ARATOR",   -- Arator the Redeemed; leads the March on Quel'Danas raid

    -- Moved from Blizzard list (WoW-origin or strongly WoW-associated)
    "SCYTHE",   -- Scythe of Elune; iconic WoW artifact; Death Knight weapon type
    "PLAGUE",   -- Plague — Plaguelands, Plague of Undeath, Scourge; core WoW lore
    "HERALD",   -- Herald of the Titans; iconic WoW achievement and title
    "DIVINE",   -- Divine Shield; core WoW Paladin ability since vanilla
    "SECRET",   -- Secret; Hunter/Mage/Paladin trap mechanic; core WoW ability type
    "KNIGHT",   -- Knight — Death Knight, Blood Knight; central WoW class and lore
    "REXXAR",   -- Rexxar — Beastmaster; WoW character in Outland and beyond
    "SEASON",   -- Season — WoW Mythic+ and PvP seasons; core modern WoW system
    "LEORIC",   -- King Leoric — WoW Scarlet Monastery boss; WoW origin before Diablo 3
    "LUNARA",   -- Lunara — WoW dryad character; appears in Legion and later
    "SAMURO",   -- Samuro — Blademaster; WC3 character with WoW story presence
}

-- Snapshot the core WoW-only words before any other file can append to WoWdle_Words[6].
WoWdle_CoreWords = WoWdle_CoreWords or {}
WoWdle_CoreWords[6] = {}
for _, w in ipairs(WoWdle_Words[6]) do
    table.insert(WoWdle_CoreWords[6], w)
end
