-- WoWdle_ValidGuesses5.lua
-- Common 5-letter English words accepted as valid guesses but NEVER used as answers.
-- Every entry in this file must be exactly 5 letters. No exceptions.
-- Add new words here; WoWdle.lua will deduplicate on load.

WoWdle_ValidGuesses = WoWdle_ValidGuesses or {}
WoWdle_ValidGuesses[5] = {
    -- Popular Wordle openers & high-frequency starters
    "CRANE", "SLATE", "STARE", "AROSE", "RAISE",
    "AUDIO", "ADIEU", "TEARS", "RATES", "CRATE",
    "TRACE", "SNARE", "SHARE", "SHALE", "TRAIN",
    "TRIAL", "TRAIL", "GRAIL", "PLAIN", "PLAIT",
    "PLAID", "CHAIR", "CHAIN",

    -- Common everyday words A
    "ABOUT", "ABOVE", "ABUSE", "AFTER", "AGAIN",
    "AGREE", "AHEAD", "AISLE", "ALIVE", "ALOFT",
    "ALONE", "ALONG", "ALTER", "AMBER", "AMPLE",
    "ANGEL", "ANGER", "ANGLE", "ANKLE", "ANNEX",
    "APART", "APPLE", "APPLY", "APRON", "APTLY",
    "ARGUE", "ARISE", "ASIDE", "ATONE", "AVOID",
    "AWAKE", "AWARE", "AWFUL",

    -- B
    "BADLY", "BAKER", "BASIC", "BASIN", "BATCH",
    "BEACH", "BEARD", "BEGIN", "BEING", "BELOW",
    "BENCH", "BERRY", "BIRTH", "BISON", "BLAND",
    "BLANK", "BLAZE", "BLEAK", "BLESS", "BLISS",
    "BLOAT", "BLOWN", "BLUNT", "BLUSH", "BOAST",
    "BONUS", "BOOST", "BOOTH", "BOUND", "BOXER",
    "BRAIN", "BRAND", "BRAVE", "BREAD", "BREAK",
    "BREED", "BRICK", "BRIDE", "BRIEF", "BRINK",
    "BRISK", "BROKE", "BROOK", "BROWN", "BRUSH",
    "BUDDY", "BUILD", "BUILT", "BUNCH", "BURST",
    "BUYER",

    -- C
    "CABIN", "CAMEL", "CARGO", "CARRY", "CATCH",
    "CAUSE", "CEASE", "CHECK", "CHEEK", "CHEER",
    "CHESS", "CHILD", "CHIME", "CHUNK", "CIVIC",
    "CIVIL", "CLAMP", "CLANG", "CLASH", "CLASP",
    "CLASS", "CLEAN", "CLEAR", "CLERK", "CLICK",
    "CLIFF", "CLIMB", "CLING", "CLOSE", "CLOUD",
    "CLOWN", "COACH", "COAST", "COINS", "COLOR",
    "COMET", "COMIC", "COUNT", "COVER", "COVET",
    "CRACK", "CRASH", "CRAWL", "CRAZY", "CRIME",
    "CRIMP", "CRISP", "CROWD", "CROWN", "CRUEL",
    "CRUMB", "CRUSH", "CRUST", "CURVE", "CYCLE",

    -- D
    "DAILY", "DAIRY", "DANCE", "DATUM", "DAUNT",
    "DECAY", "DECOY", "DELAY", "DENSE", "DEPOT",
    "DERBY", "DISCO", "DITCH", "DIVER", "DIZZY",
    "DOING", "DOUBT", "DOUGH", "DOUSE", "DOWRY",
    "DOZEN", "DRAFT", "DRAIN", "DRAMA", "DRAPE",
    "DRAWL", "DREAM", "DRESS", "DRIED", "DRIFT",
    "DRINK", "DRIVE", "DRONE", "DROOL", "DROOP",
    "DROVE", "DROWN", "DUNCE", "DUSTY", "DWELT",

    -- E
    "EAGER", "EARLY", "EARTH", "EIGHT", "ELECT",
    "ELITE", "EMPTY", "ENTER", "ENTRY", "EQUAL",
    "EQUIP", "ERROR", "ESSAY", "EVADE", "EVENT",
    "EVERY", "EVICT", "EXACT", "EXIST", "EXTRA",

    -- F
    "FAINT", "FAIRY", "FAITH", "FALSE", "FANCY",
    "FARCE", "FAVOR", "FEAST", "FETCH", "FEWER",
    "FIBER", "FIELD", "FIFTH", "FIFTY", "FIGHT",
    "FINAL", "FIRST", "FIXED", "FIZZY", "FLAIR",
    "FLANK", "FLARE", "FLASH", "FLESH", "FLICK",
    "FLING", "FLINT", "FLOAT", "FLOCK", "FLOOD",
    "FLOOR", "FLORA", "FLOSS", "FLOUR", "FLOWN",
    "FLUKE", "FLUTE", "FOCAL", "FORAY", "FORCE",
    "FOUND", "FRAME", "FRANK", "FRAUD", "FRESH",
    "FRISK", "FRIZZ", "FRONT", "FROZE", "FRUIT",
    "FULLY", "FUNGI", "FUNNY",

    -- G
    "GAUGE", "GAVEL", "GAWKY", "GLOAT", "GLOBE",
    "GLOSS", "GNOME", "GRADE", "GRANT", "GRAPE",
    "GRASP", "GRASS", "GRAVE", "GRAZE", "GREAT",
    "GREED", "GREEN", "GREET", "GRIME", "GRIPE",
    "GROAN", "GROIN", "GROOM", "GROSS", "GROUP",
    "GROWL", "GRUEL", "GRUFF", "GRUNT", "GUAVA",
    "GUILE", "GUISE", "GUSTO", "GYPSY",

    -- H
    "HAUNT", "HEART", "HEAVY", "HEDGE", "HENCE",
    "HERBS", "HERON", "HINGE", "HIPPO", "HOIST",
    "HOLLY", "HOMER", "HONEY", "HORSE", "HOTEL",
    "HOUND", "HUMAN", "HURRY", "HYENA",

    -- I
    "IDEAL", "ICING", "IMAGE", "IMPLY", "INDEX",
    "INDIE", "INEPT", "INFER", "INNER", "INPUT",
    "INTER", "INTRO", "IRONY", "ISSUE", "IVORY",

    -- J
    "JAUNT", "JAZZY", "JEWEL", "JOUST", "JUDGE",
    "JUICE", "JUICY", "JUMBO",

    -- K
    "KAYAK", "KEBAB", "KNACK", "KNAVE", "KNEEL",
    "KNIFE", "KNOCK", "KNOWN",

    -- L
    "LABEL", "LANCE", "LAPEL", "LARGE", "LASER",
    "LATCH", "LATER", "LATTE", "LAUGH", "LAYER",
    "LEACH", "LEARN", "LEASE", "LEASH", "LEAVE",
    "LEDGE", "LEGAL", "LEMON", "LEVEL", "LIBEL",
    "LIFER", "LIMIT", "LINER", "LINGO", "LITER",
    "LIVER", "LLAMA", "LOCAL", "LOGIC", "LOOSE",
    "LOVER", "LOWER", "LUCID", "LUCKY", "LUNAR",
    "LYING",

    -- M
    "MAKER", "MANOR", "MAPLE", "MARCH", "MARRY",
    "MATCH", "MAXIM", "MAYOR", "MEDIA", "MERCY",
    "MERIT", "METAL", "MIGHT", "MIMIC", "MINCE",
    "MINOR", "MINUS", "MISER", "MIXED", "MODEL",
    "MONEY", "MONTH", "MORAL", "MORSE", "MOURN",
    "MOUSE", "MOUTH", "MOVER", "MOVIE", "MUDDY",
    "MULCH", "MUMMY", "MUSIC",

    -- N
    "NAIVE", "NASTY", "NAVAL", "NERVE", "NEVER",
    "NINJA", "NOBLE", "NOISY", "NONCE", "NORTH",
    "NOTCH", "NOVEL", "NURSE",

    -- O
    "OCCUR", "OCEAN", "OFFER", "OFTEN", "OLIVE",
    "ONSET", "OPTIC", "ORBIT", "ORGAN", "OTHER",
    "OTTER", "OUGHT", "OUTER", "OUTDO", "OUNCE",
    "OVARY", "OXIDE", "OZONE",

    -- P
    "PAINT", "PAIRS", "PANIC", "PAPER", "PARKA",
    "PASTE", "PAUSE", "PEACE", "PEACH", "PEARL",
    "PENAL", "PERCH", "PERIL", "PERKY", "PETTY",
    "PHONE", "PHOTO", "PIANO", "PINCH", "PIXEL",
    "PLACE", "PLANK", "PLANT", "PLATE", "PLAZA",
    "PLEAD", "PLUCK", "PLUMB", "PLUME", "PLUMP",
    "PLUNK", "PLUSH", "POINT", "POKER", "POLAR",
    "POLKA", "POPPY", "PORCH", "POSSE", "POUCH",
    "POUND", "PRANK", "PRESS", "PRICE", "PRIDE",
    "PRIME", "PRINT", "PRIOR", "PRIVY", "PROBE",
    "PRONE", "PRONG", "PROOF", "PROSE", "PROUD",
    "PROVE", "PROWL", "PRUNE", "PSALM", "PUDGY",
    "PULSE", "PUPIL", "PURSE", "PUSHY",

    -- Q
    "QUACK", "QUALM", "QUEEN", "QUERY", "QUEUE",
    "QUICK", "QUIET", "QUOTA", "QUOTE",

    -- R
    "RABBI", "RABID", "RAINY", "RAMEN", "RANCH",
    "RAPID", "RASPY", "RATED", "REACH", "REACT",
    "READY", "REEDY", "REFER", "REIGN", "RELAX",
    "REMIT", "REPAY", "RESIN", "REUSE", "RIDER",
    "RIGID", "RISKY", "ROAST", "ROBIN", "ROCKY",
    "ROMAN", "ROUGH", "ROUND", "ROUTE", "ROWDY",
    "ROYAL", "RUGBY", "RULER", "RUSTY",

    -- S
    "SADLY", "SAINT", "SALAD", "SALSA", "SALTY",
    "SANDY", "SAUCE", "SAUNA", "SCALD", "SCALP",
    "SCANT", "SCARE", "SCARF", "SCARY", "SCENE",
    "SCONE", "SCOOP", "SCOPE", "SCORN", "SCOUT",
    "SCOWL", "SCRUB", "SEIZE", "SENSE", "SERVE",
    "SEVEN", "SHARK", "SHARP", "SHEAR", "SHEEN",
    "SHELF", "SHELL", "SHIFT", "SHINE", "SHIRT",
    "SHORT", "SHOVE", "SHOWN", "SHRUB", "SHRUG",
    "SIGHT", "SINCE", "SIXTH", "SIXTY", "SKILL",
    "SKIMP", "SKIRT", "SKULK", "SKUNK", "SLACK",
    "SLAIN", "SLANT", "SLASH", "SLEEK", "SLEEP",
    "SLEET", "SLEPT", "SLICK", "SLIDE", "SLIME",
    "SLIMY", "SLING", "SLINK", "SLOPE", "SLOTH",
    "SLUNK", "SLURP", "SMACK", "SMALL", "SMASH",
    "SMEAR", "SMELL", "SMELT", "SMILE", "SMIRK",
    "SMOKE", "SNACK", "SNAIL", "SNAKE", "SNAKY",
    "SNARL", "SNEAK", "SNIFF", "SNORE", "SOLAR",
    "SOLID", "SOLVE", "SONIC", "SORRY", "SOUTH",
    "SPACE", "SPARE", "SPARK", "SPAWN", "SPEAK",
    "SPEED", "SPEND", "SPICE", "SPILL", "SPINE",
    "SPOOK", "SPOON", "SPORT", "SPOUT", "SPRAY",
    "SPREE", "SPRIG", "SQUAD", "SQUAT", "SQUID",
    "STACK", "STAGE", "STAIN", "STAIR", "STALE",
    "STALK", "STALL", "STAMP", "STAND", "START",
    "STEAD", "STEAL", "STEAM", "STEEL", "STEEP",
    "STEER", "STERN", "STIFF", "STILL", "STING",
    "STINK", "STOMP", "STONE", "STOOD", "STORE",
    "STORK", "STORY", "STOUT", "STOVE", "STRIP",
    "STRUM", "STRUT", "STUCK", "STUDY", "STUFF",
    "STUMP", "STUNG", "SUGAR", "SUITE", "SUNNY",
    "SUPER", "SURGE", "SWARM", "SWEAR", "SWEAT",
    "SWEET", "SWEPT", "SWORE", "SWORN", "SWUNG",
    "SYNTH",

    -- T
    "TABOO", "TAKEN", "TAPER", "TARDY", "TERSE",
    "THANK", "THEIR", "THEME", "THERE", "THICK",
    "THING", "THINK", "THIRD", "THORN", "THOSE",
    "THREE", "THREW", "THROW", "TIARA", "TIGER",
    "TILDE", "TIMED", "TIPSY", "TIRED", "TITLE",
    "TODAY", "TONIC", "TOPAZ", "TOPIC", "TORCH",
    "TOTAL", "TOUCH", "TOUGH", "TOWEL", "TOWER",
    "TOXIC", "TRACK", "TRADE", "TRAMP", "TRASH",
    "TREAD", "TREAT", "TREND", "TRICK", "TRIED",
    "TRITE", "TROMP", "TROOP", "TROUT", "TROVE",
    "TRUCE", "TRUCK", "TRULY", "TRUNK", "TRUST",
    "TRUTH", "TULIP", "TUMOR", "TUNER", "TUNIC",
    "TWEAK", "TWIRL", "TWIST", "TYING",

    -- U
    "UDDER", "ULCER", "ULTRA", "UNCUT", "UNDER",
    "UNDUE", "UNFIT", "UNION", "UNITE", "UNTIL",
    "UPPER", "UPSET", "URBAN", "USHER", "USUAL",
    "UTTER",

    -- V
    "VAGUE", "VALID", "VALVE", "VAPID", "VICAR",
    "VIDEO", "VIGIL", "VIRAL", "VIRUS", "VISIT",
    "VISTA", "VITAL", "VIVID", "VOCAL", "VODKA",
    "VOICE", "VOTER",

    -- W
    "WAFER", "WASTE", "WATCH", "WATER", "WEARY",
    "WEAVE", "WEDGE", "WEIRD", "WHALE", "WHEAT",
    "WHERE", "WHICH", "WHILE", "WHIFF", "WHIRL",
    "WHISK", "WHITE", "WHOLE", "WHOSE", "WIDER",
    "WITCH", "WITTY", "WOMAN", "WOMEN", "WORLD",
    "WORRY", "WORSE", "WORST", "WORTH", "WRING",
    "WROTE",

    -- Y / Z
    "YACHT", "YEARN", "YIELD", "YOUNG", "YOUTH",
    "ZEBRA", "ZONAL",

    -- Additional common words
    "ABACK", "ABASE", "ABASH", "ABATE", "ABBEY", "ABBOT", "ABHOR", "ABIDE", "ABLER", "ABODE",
    "ABORT", "ABYSS", "ALIAS", "ALIBI", "ALLAY", "ALLEY", "ALLOY", "ALPHA", "ALTAR", "ANGST",
    "ANNOY", "ANTIC", "ANVIL", "AORTA", "ARBOR", "ARDOR", "ARGON", "ARGOT", "ARRAY", "ARSON",
    "ASHEN", "ASTER", "ATOLL", "ATTIC", "AUGUR", "AVANT", "AVAST", "AVIAN", "AXIOM", "AZURE",
    "BALMY", "BANAL", "BARGE", "BARON", "BASIL", "BATTY", "BAWDY", "BAYOU", "BEADY", "BEIGE",
    "BELLE", "BELLY", "BERET", "BERTH", "BIGOT", "BIRCH", "BLURT", "BOOZE", "BOOZY", "BRAID",
    "BRASH", "BRAWN", "BROTH", "BURLY", "BUSHY", "BUSTS", "CADET", "CANNY", "CAROL", "CHAFE",
    "CHALK", "CHAMP", "CHANT", "CHAPS", "CHASM", "CHIEF", "CHIPS", "CHURN", "CITED", "CLUMP",
    "COBRA", "COMBO", "COMFY", "CORNY", "CRYPT", "CURLY", "CURRY", "CUSHY", "CUTIE", "DELTA",
    "DIGIT", "DINGO", "DIRGE", "DIVAN", "DOGMA", "DONOR", "DOPEY", "DOWDY", "DRAWN", "DUVET",
    "EASEL", "ELBOW", "ELDER", "FABLE", "FIEND", "FIERY", "FOGGY", "FOLLY", "FORTE", "FORUM",
    "FRAIL", "FRANC", "FROND", "GAMUT", "GAUDY", "GECKO", "GIDDY", "GLEAN", "GLIDE", "GLINT",
    "GLUED", "GODLY", "GORGE", "GOUGE", "GOURD", "GRABS", "GRADS", "HAIRY", "HALVE", "HANDY",
    "HARDY", "HARPS", "HARSH", "HASTE", "HAVOC", "HEWED", "HIPPY", "HORDE", "HORNY", "HOTLY",
    "HOWDY", "HUFFY", "HUMID", "HUTCH", "HYPER", "INBOX", "IRATE", "JELLY", "JERKY", "JOKEY",
    "JOLLY", "JUMPY", "KINKY", "KUDOS", "LAPSE", "LEAFY", "LEAPT", "LEFTY", "LITHE", "LIVID",
    "LOATH", "LOBBY", "LOFTY", "LOOPY", "LOUSY", "LUMPY", "LUSTY", "MANLY", "MELEE", "MESSY",
    "MINTY", "MIRTH", "MISTY", "MOODY", "MOPED", "MOTIF", "MUGGY", "MURKY", "MUSHY", "MUSKY",
    "MUSTY", "NERDY", "NIFTY", "NIPPY", "NUTTY", "OBESE", "ODDER", "ODDLY", "OFFAL", "OPINE",
    "PADDY", "PEEVE", "PURGE", "QUIRK", "RATTY", "REALM", "RIVET", "RUDDY", "SALLY", "SEEDY",
    "SERUM", "SETUP", "SHADY", "SHAKY", "SHALL", "SHAME", "SHANK", "SHARD", "SHAVE", "SHUNT",
    "SILKY", "SILLY", "SNOOP", "SOAPY", "SOGGY", "SPEAR", "SPICY", "STARK", "STAYS", "STEAK",
    "STOIC", "SUAVE", "SULKY", "SURLY", "TACKY", "TAMED", "TANGO", "TANGY", "TARRY", "TASTY",
    "TAUNT", "TEPID", "TESTY", "TOAST", "TOKEN", "TROLL", "TUBBY", "UNIFY", "UPEND", "VALOR",
    "VAUNT", "WACKY", "WIMPY", "WISPY", "WONKY", "WOOLY", "WOOZY", "WORDY", "WORMY", "WRATH",
    "WRUNG", "ZESTY", "ZONED",
}
