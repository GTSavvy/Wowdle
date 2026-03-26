-- WoWdle: A Wordle clone for World of Warcraft
-- A WoW-themed Wordle addon

local addonName, addon = ...

-- ============================================================
-- WORD LIST
-- Loaded from WoWdle_Words5.lua and WoWdle_Words6.lua (core WoW words)
-- and optionally Blizzard_Words5.lua / Blizzard_Words6.lua (other Blizzard IPs).
-- All files must be listed before this one in the .toc.
-- Words of both lengths are merged into one flat pool.
-- Each game picks randomly from the active pool; the UI resizes
-- to match whatever length is drawn.
-- ============================================================

local function loadAndValidate(letterCount)
    local source = WoWdle_Words and WoWdle_Words[letterCount]
    if not source then
        error("WoWdle: WoWdle_Words[" .. letterCount .. "] not found. "
              .. "Check your .toc load order.")
    end
    local seen, clean = {}, {}
    for _, w in ipairs(source) do
        w = w:upper()
        if #w == letterCount and not seen[w] then
            seen[w] = true
            table.insert(clean, w)
        end
    end
    return clean
end

local function loadBlizzardWords(letterCount)
    local source = WoWdle_BlizzardWords and WoWdle_BlizzardWords[letterCount]
    if not source then return {} end
    local seen, clean = {}, {}
    for _, w in ipairs(source) do
        w = w:upper()
        if #w == letterCount and not seen[w] then
            seen[w] = true
            table.insert(clean, w)
        end
    end
    return clean
end

local WORDS          = {}
local BLIZZARD_WORDS = {}
local ANSWER_SET     = {}
local DAILY_POOL     = {}   -- fixed 5-letter WoW-only words; never changes with options
do
    for _, w in ipairs(loadAndValidate(5)) do
        table.insert(WORDS, w)
        ANSWER_SET[w] = true
    end
    for _, w in ipairs(loadAndValidate(6)) do
        table.insert(WORDS, w)
        ANSWER_SET[w] = true
    end
    for _, w in ipairs(loadBlizzardWords(5)) do
        table.insert(BLIZZARD_WORDS, w)
        ANSWER_SET[w] = true
    end
    for _, w in ipairs(loadBlizzardWords(6)) do
        table.insert(BLIZZARD_WORDS, w)
        ANSWER_SET[w] = true
    end

    -- Build DAILY_POOL from the core WoW-only snapshot taken before any
    -- Blizzard word files could append to WoWdle_Words[5]. This guarantees
    -- all players get the same daily word regardless of which optional files
    -- they have installed.
    local coreSource = WoWdle_CoreWords and WoWdle_CoreWords[5]
    if coreSource then
        local seen = {}
        for _, w in ipairs(coreSource) do
            w = w:upper()
            if #w == 5 and not seen[w] then
                seen[w] = true
                table.insert(DAILY_POOL, w)
            end
        end
    else
        -- Fallback: WoWdle_Words5.lua is an older version without the snapshot.
        -- Use loadAndValidate result but warn the player.
        print("|cffffcc00WoWdle|r: |cffff4444WoWdle_Words5.lua is outdated. "
              .. "Daily word may differ between players. Please update.|r")
        for _, w in ipairs(DAILY_POOL) do end -- already empty, fill from WORDS
        for _, w in ipairs(WORDS) do
            if #w == 5 then table.insert(DAILY_POOL, w) end
        end
    end
end

-- ============================================================
-- VALID GUESS SETS
-- ============================================================

local function loadValidGuesses(letterCount)
    local source = WoWdle_ValidGuesses and WoWdle_ValidGuesses[letterCount]
    if not source then
        print("|cffffcc00WoWdle|r: WoWdle_ValidGuesses[" .. letterCount .. "] not found. "
              .. "All " .. letterCount .. "-letter words will be accepted as guesses.")
        return {}
    end
    local set = {}
    for _, w in ipairs(source) do
        w = w:upper()
        if #w == letterCount then set[w] = true end
    end
    return set
end

local VALID_GUESSES = {
    [5] = loadValidGuesses(5),
    [6] = loadValidGuesses(6),
}

local function isValidGuess(word)
    return ANSWER_SET[word] == true
        or (VALID_GUESSES[#word] and VALID_GUESSES[#word][word] == true)
end

-- ============================================================
-- SAVED VARIABLES
-- ============================================================
WoWdle_SavedVars = WoWdle_SavedVars or {}

-- ============================================================
-- OPTIONS
-- ============================================================

local OPTION_DEFS = {
    {
        key     = "validWordsOnly",
        default = true,
        label   = "Valid Words Only",
        desc    = "Only words in the answer or guess lists are accepted.",
    },
    {
        key     = "hardMode",
        default = false,
        label   = "Hard Mode",
        desc    = "All revealed hints must be used in subsequent guesses.",
    },
    {
        key     = "sixLetterWords",
        default = true,
        label   = "6-Letter Words",
        desc    = "Include 6-letter words in the answer pool.",
    },
    {
        key     = "blizzardWords",
        default = false,
        label   = "Blizzard Words",
        desc    = "Include words from other Blizzard titles (Overwatch, StarCraft, Diablo, etc.).",
    },
    {
        key     = "minimapButton",
        default = true,
        label   = "Minimap Button",
        desc    = "Show a button on the minimap to open WoWdle.",
    },
}

local function getOptions()
    if not WoWdle_SavedVars.options then
        WoWdle_SavedVars.options = {}
    end
    local opts = WoWdle_SavedVars.options
    for _, def in ipairs(OPTION_DEFS) do
        if opts[def.key] == nil then
            opts[def.key] = def.default
        end
    end
    return opts
end

local function activePool()
    local opts   = getOptions()
    local want6  = opts.sixLetterWords
    local wantBz = opts.blizzardWords

    if want6 and wantBz then
        local pool = {}
        for _, w in ipairs(WORDS)          do table.insert(pool, w) end
        for _, w in ipairs(BLIZZARD_WORDS) do table.insert(pool, w) end
        return pool
    end

    local pool = {}
    for _, w in ipairs(WORDS) do
        if want6 or #w == 5 then table.insert(pool, w) end
    end
    if wantBz then
        for _, w in ipairs(BLIZZARD_WORDS) do
            if want6 or #w == 5 then table.insert(pool, w) end
        end
    end
    return pool
end

-- ============================================================
-- DAILY WORD HELPERS
-- ============================================================

local function todayStamp()
    local t = date("*t")
    return t.year * 10000 + t.month * 100 + t.day
end

local function getDailyWord()
    local h = (todayStamp() * 2654435761) % (2^32)
    return DAILY_POOL[(h % #DAILY_POOL) + 1]
end

local function dailyAlreadyCompleted()
    return WoWdle_SavedVars.lastCompletedDate == todayStamp()
end

local function markDailyCompleted()
    WoWdle_SavedVars.lastCompletedDate = todayStamp()
end

-- ============================================================
-- STATS
-- ============================================================

local function getStats()
    if not WoWdle_SavedVars.stats then
        WoWdle_SavedVars.stats = {
            gamesPlayed      = 0,
            gamesWon         = 0,
            gamesSkipped     = 0,
            currentStreak    = 0,
            bestStreak       = 0,
            lastDailyWonDate = 0,
            guessDistrib     = {0, 0, 0, 0, 0, 0},
        }
    end
    if not WoWdle_SavedVars.stats.guessDistrib then
        WoWdle_SavedVars.stats.guessDistrib = {0, 0, 0, 0, 0, 0}
    end
    -- Migrate older saves that predate the skipped stat.
    if WoWdle_SavedVars.stats.gamesSkipped == nil then
        WoWdle_SavedVars.stats.gamesSkipped = 0
    end
    return WoWdle_SavedVars.stats
end

local function yesterdayStamp()
    local t  = date("*t")
    t.day    = t.day - 1
    local ts = time(t)
    local d  = date("*t", ts)
    return d.year * 10000 + d.month * 100 + d.day
end

local function recordResult(won, guessCount, isDaily)
    local s = getStats()
    s.gamesPlayed = s.gamesPlayed + 1
    if won then
        s.gamesWon = s.gamesWon + 1
        if guessCount >= 1 and guessCount <= 6 then
            s.guessDistrib[guessCount] = s.guessDistrib[guessCount] + 1
        end
        if isDaily then
            local today = todayStamp()
            if s.lastDailyWonDate == yesterdayStamp() then
                s.currentStreak = s.currentStreak + 1
            elseif s.lastDailyWonDate ~= today then
                s.currentStreak = 1
            end
            s.lastDailyWonDate = today
            if s.currentStreak > s.bestStreak then
                s.bestStreak = s.currentStreak
            end
        end
    else
        if isDaily then
            s.currentStreak = 0
        end
    end
end

-- Counts an in-progress free play game as skipped (played but not finished).
-- Only called when the player has made at least one guess.
local function recordSkip()
    local s = getStats()
    s.gamesPlayed   = s.gamesPlayed + 1
    s.gamesSkipped  = s.gamesSkipped + 1
end

-- ============================================================
-- ACTIVE WORD LENGTH
-- ============================================================
local WORD_LENGTH = 5

local function applyWord(word)
    WORD_LENGTH = #word
    return word
end

-- ============================================================
-- STATE
-- ============================================================
local state = {
    answer       = "",
    guesses      = {},
    currentInput = "",
    maxGuesses   = 6,
    won          = false,
    lost         = false,
    isDaily      = false,
}

-- ============================================================
-- FRAME REFERENCES
-- ============================================================
local MainFrame, InputBox, GridFrame
local MinimapBtn  -- also referenced by the options panel checkbox
local TileFrames = {}
local KeyButtons = {}

-- ============================================================
-- LAYOUT
-- ============================================================
local FRAME_PADDING = 20
local MAX_GRID_W    = 320
local TILE_GAP      = 6
local NUM_ROWS      = 6
local KEY_W         = 28
local KEY_H         = 32

local function tileSize(len)
    return math.floor((MAX_GRID_W - (len - 1) * TILE_GAP) / len)
end

local function gridWidth(len)
    local ts = tileSize(len)
    return len * ts + (len - 1) * TILE_GAP
end

local function gridHeight(len)
    local ts = tileSize(len)
    return NUM_ROWS * ts + (NUM_ROWS - 1) * TILE_GAP
end

local function frameWidth(len)
    return gridWidth(len) + FRAME_PADDING * 2
end

local FREEPLAY_EXTRA_H = 34  -- extra height for the second button row in free play
local COUNTDOWN_H      = 28  -- extra height for the daily countdown line

local function frameHeight(len, isDaily)
    local base = gridHeight(len) + 30 + (KEY_H + 5) * 3 + 60 + COUNTDOWN_H + 40
    return base + (isDaily and 0 or FREEPLAY_EXTRA_H)
end

-- ============================================================
-- COLORS
-- ============================================================
local COLOR_CORRECT = {0.18, 0.65, 0.35, 1}
local COLOR_PRESENT = {0.75, 0.60, 0.10, 1}
local COLOR_ABSENT  = {0.28, 0.28, 0.28, 1}
local COLOR_EMPTY   = {0.10, 0.10, 0.10, 1}
local COLOR_TEXT    = {1, 1, 1}

local RARITY_COLORS = {
    [1] = {1.00, 0.50, 0.00, 1},
    [2] = {0.64, 0.21, 0.93, 1},
    [3] = {0.00, 0.44, 0.87, 1},
    [4] = {0.12, 1.00, 0.00, 1},
    [5] = {1.00, 1.00, 1.00, 1},
    [6] = {0.62, 0.62, 0.62, 1},
}

-- Returns the faction-appropriate victory exclamation.
local function factionCheer()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    if faction == "Alliance" then
        return "|cff00ccffFor the Alliance!|r"
    else
        return "|cff00ff7fFor the Horde!|r"
    end
end
local function randomWord()
    local pool = activePool()
    return pool[math.random(1, #pool)]
end

local function scoreGuess(guess, answer)
    local len    = #answer
    local result = {}
    for i = 1, len do result[i] = "absent" end
    local counts = {}
    for i = 1, len do
        if guess:sub(i,i) == answer:sub(i,i) then
            result[i] = "correct"
        else
            local a = answer:sub(i,i)
            counts[a] = (counts[a] or 0) + 1
        end
    end
    for i = 1, len do
        if result[i] ~= "correct" then
            local g = guess:sub(i,i)
            if counts[g] and counts[g] > 0 then
                result[i] = "present"
                counts[g] = counts[g] - 1
            end
        end
    end
    return result
end

local function setTileColor(tile, r, g, b)
    tile.inner:SetBackdropColor(r, g, b, 1)
end

local function updateTile(row, col, letter, status)
    local tile = TileFrames[row] and TileFrames[row][col]
    if not tile then return end
    tile.text:SetText(letter or "")
    if     status == "correct" then setTileColor(tile, unpack(COLOR_CORRECT))
    elseif status == "present" then setTileColor(tile, unpack(COLOR_PRESENT))
    elseif status == "absent"  then setTileColor(tile, unpack(COLOR_ABSENT))
    else                            setTileColor(tile, unpack(COLOR_EMPTY))
    end
end

local function updateCurrentRowDisplay()
    local row = #state.guesses + 1
    if row > state.maxGuesses then return end
    for col = 1, WORD_LENGTH do
        updateTile(row, col, state.currentInput:sub(col, col), nil)
    end
end

local function updateKeyboard(letter, status)
    local btn = KeyButtons[letter]
    if not btn then return end
    local current = btn.status
    if current == "correct" then return end
    if status == "correct" then
        btn.bg:SetColorTexture(unpack(COLOR_CORRECT)); btn.status = "correct"
    elseif status == "present" and current ~= "correct" then
        btn.bg:SetColorTexture(unpack(COLOR_PRESENT)); btn.status = "present"
    elseif status == "absent" and not current then
        btn.bg:SetColorTexture(unpack(COLOR_ABSENT));  btn.status = "absent"
    end
end

-- ============================================================
-- TILE CREATION
-- ============================================================
local function createTile(parent, row, col, ts)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(ts, ts)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT",
               (col - 1) * (ts + TILE_GAP),
               -(row - 1) * (ts + TILE_GAP))
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0.4, 0.4, 0.45, 1)

    local inner = CreateFrame("Frame", nil, f, "BackdropTemplate")
    inner:SetPoint("TOPLEFT",     f, "TOPLEFT",      1, -1)
    inner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1,  1)
    inner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    inner:SetBackdropColor(unpack(COLOR_EMPTY))
    inner:SetBackdropBorderColor(0, 0, 0, 0)
    f.inner = inner

    local fontObj = (ts < 44) and "GameFontNormal" or "GameFontNormalLarge"
    f.text = inner:CreateFontString(nil, "OVERLAY", fontObj)
    f.text:SetAllPoints()
    f.text:SetJustifyH("CENTER")
    f.text:SetJustifyV("MIDDLE")
    f.text:SetTextColor(unpack(COLOR_TEXT))

    return f
end

-- ============================================================
-- GRID REBUILD
-- ============================================================
local function rebuildGrid()
    local len = WORD_LENGTH
    local ts  = tileSize(len)

    MainFrame:SetSize(frameWidth(len), frameHeight(len, state.isDaily))

    for row = 1, NUM_ROWS do
        if TileFrames[row] then
            for col = 1, 6 do
                if TileFrames[row][col] then
                    TileFrames[row][col]:Hide()
                    TileFrames[row][col] = nil
                end
            end
        end
        TileFrames[row] = {}
    end

    GridFrame:SetSize(gridWidth(len), gridHeight(len))

    for row = 1, NUM_ROWS do
        for col = 1, len do
            TileFrames[row][col] = createTile(GridFrame, row, col, ts)
        end
    end

    if InputBox then
        InputBox:SetMaxLetters(len)
    end
end

-- ============================================================
-- IN-PROGRESS SAVE / RESTORE
-- Two independent slots: inProgress.daily and inProgress.freeplay.
-- Both persist across logout/login. Switching modes saves the current
-- board into its slot and loads the other.
-- ============================================================

local function getSlot()
    return state.isDaily and "daily" or "freeplay"
end

-- Saves current board into its slot. Completed games are saved too so the
-- player can always come back and view a finished board.
local function saveProgress()
    WoWdle_SavedVars.inProgress = WoWdle_SavedVars.inProgress or {}
    WoWdle_SavedVars.inProgress[getSlot()] = {
        answer  = state.answer,
        guesses = { unpack(state.guesses) },
        won     = state.won,
        lost    = state.lost,
        stamp   = todayStamp(),
    }
end

local function clearSlot(slot)
    if WoWdle_SavedVars.inProgress then
        WoWdle_SavedVars.inProgress[slot] = nil
    end
end

-- Forward declaration — defined in GAME LOGIC section below.
local resetBoard

-- Replays a saved slot onto the board. Returns true on success.
-- If isDaily and the stamp is stale, breaks streak and returns false.
local function replaySlot(saved, isDaily)
    if not saved or not saved.answer or not saved.guesses then return false end

    if isDaily and saved.stamp ~= todayStamp() then
        -- Stale daily: break streak, discard save, start fresh.
        getStats().currentStreak = 0
        clearSlot("daily")
        return false
    end

    state.answer       = applyWord(saved.answer)
    state.isDaily      = isDaily
    state.guesses      = {}
    state.currentInput = ""

    rebuildGrid()
    resetBoard()

    -- Restore won/lost after resetBoard (which clears them to false).
    state.won  = saved.won  or false
    state.lost = saved.lost or false

    for _, guess in ipairs(saved.guesses) do
        local row    = #state.guesses + 1
        local result = scoreGuess(guess, state.answer)
        for col = 1, WORD_LENGTH do
            updateTile(row, col, guess:sub(col, col), result[col])
            updateKeyboard(guess:sub(col, col), result[col])
        end
        table.insert(state.guesses, guess)
    end

    -- Restore end-of-game message if the board was already finished.
    if state.won then
        if isDaily then
            local noun = #state.guesses == 1 and "guess" or "guesses"
            MainFrame.msgText:SetText(
                factionCheer() .. " Daily word solved in " ..
                #state.guesses .. " " .. noun .. "!")
        else
            MainFrame.msgText:SetText(factionCheer() .. " You got it!")
        end
    elseif state.lost then
        MainFrame.msgText:SetText(
            "|cffff4444Defeated!|r\n" ..
            "|cffaaaaaaThe word was|r |cffffcc00" .. saved.answer .. "|r")
    end

    return true
end

-- Updates the mode button highlights and New Word button visibility.
-- Forward-declared; defined after the buttons exist in BuildUI.
local refreshModeButtons

-- Saves current board, then loads the daily slot (or starts a fresh daily).
local function switchToDaily()
    saveProgress()  -- save whichever mode we're leaving

    WoWdle_SavedVars.inProgress = WoWdle_SavedVars.inProgress or {}
    local saved = WoWdle_SavedVars.inProgress["daily"]

    if not replaySlot(saved, true) then
        -- No save, or stale — start today's daily fresh.
        state.answer       = applyWord(getDailyWord())
        state.isDaily      = true
        state.guesses      = {}
        state.won          = false
        state.lost         = false
        state.currentInput = ""
        rebuildGrid()
        resetBoard()
    end

    MainFrame.TitleText:SetText("WoWdle  |cff8888ff– Daily|r")
    if refreshModeButtons then refreshModeButtons() end
end

-- Saves current board, then loads the free play slot (or starts a fresh game).
local function switchToFreePlay()
    saveProgress()  -- save whichever mode we're leaving

    WoWdle_SavedVars.inProgress = WoWdle_SavedVars.inProgress or {}
    local saved = WoWdle_SavedVars.inProgress["freeplay"]

    if not replaySlot(saved, false) then
        -- No save — start a fresh free play game.
        state.answer       = applyWord(randomWord())
        state.isDaily      = false
        state.guesses      = {}
        state.won          = false
        state.lost         = false
        state.currentInput = ""
        rebuildGrid()
        resetBoard()
    end

    MainFrame.TitleText:SetText("WoWdle  |cffffcc00– Free Play|r")
    if refreshModeButtons then refreshModeButtons() end
end

-- Called on login. Tries to restore whichever mode was active last session.
-- Prefers daily if both slots exist. Returns true if a board was restored.
local function restoreProgress()
    WoWdle_SavedVars.inProgress = WoWdle_SavedVars.inProgress or {}
    local daily    = WoWdle_SavedVars.inProgress["daily"]
    local freeplay = WoWdle_SavedVars.inProgress["freeplay"]

    -- Check for stale daily and break streak if needed (even if we end up
    -- restoring free play, the streak should still reset).
    if daily and daily.stamp ~= todayStamp() then
        getStats().currentStreak = 0
        clearSlot("daily")
        daily = nil
    end

    -- Prefer restoring daily if it exists and is for today.
    if daily then
        return replaySlot(daily, true)
    elseif freeplay then
        return replaySlot(freeplay, false)
    end

    return false
end

-- ============================================================
-- GAME LOGIC
-- ============================================================
resetBoard = function()
    state.guesses      = {}
    state.currentInput = ""
    state.won          = false
    state.lost         = false

    for row = 1, NUM_ROWS do
        for col = 1, WORD_LENGTH do
            updateTile(row, col, "", nil)
        end
    end
    for _, btn in pairs(KeyButtons) do
        btn.bg:SetColorTexture(0.20, 0.20, 0.25)
        btn.status = nil
    end
    if MainFrame and MainFrame.msgText then
        MainFrame.msgText:SetText("")
    end
    if InputBox then
        InputBox:SetText("")
        InputBox:SetFocus()
    end
end

local function startDailyGame()
    state.answer       = applyWord(getDailyWord())
    state.isDaily      = true
    state.guesses      = {}
    state.won          = false
    state.lost         = false
    state.currentInput = ""
    rebuildGrid()
    resetBoard()
    if MainFrame then
        MainFrame.TitleText:SetText("WoWdle  |cff8888ff– Daily|r")
        if refreshModeButtons then refreshModeButtons() end
    end
end

local function startFreeGame()
    state.answer       = applyWord(randomWord())
    state.isDaily      = false
    state.guesses      = {}
    state.won          = false
    state.lost         = false
    state.currentInput = ""
    rebuildGrid()
    resetBoard()
    if MainFrame then
        MainFrame.TitleText:SetText("WoWdle  |cffffcc00– Free Play|r")
        if refreshModeButtons then refreshModeButtons() end
    end
end

local function checkHardMode(guess)
    for _, prev in ipairs(state.guesses) do
        local result = scoreGuess(prev, state.answer)
        for i = 1, WORD_LENGTH do
            if result[i] == "correct" and guess:sub(i,i) ~= prev:sub(i,i) then
                return "Position " .. i .. " must be " .. prev:sub(i,i) .. "!"
            end
        end
        for i = 1, WORD_LENGTH do
            if result[i] == "present" then
                local letter = prev:sub(i,i)
                if not guess:find(letter, 1, true) then
                    return "Guess must contain " .. letter .. "!"
                end
            end
        end
    end
    return nil
end

local function submitGuess()
    if state.won or state.lost then return end

    local guess = state.currentInput:upper()
    if #guess ~= WORD_LENGTH then
        MainFrame.msgText:SetText("|cffff4444Need " .. WORD_LENGTH .. " letters!|r")
        return
    end

    if getOptions().validWordsOnly and not isValidGuess(guess) then
        MainFrame.msgText:SetText("|cffff4444Not in word list!|r")
        return
    end

    if getOptions().hardMode then
        local hardErr = checkHardMode(guess)
        if hardErr then
            MainFrame.msgText:SetText("|cffff4444" .. hardErr .. "|r")
            return
        end
    end

    local row    = #state.guesses + 1
    local result = scoreGuess(guess, state.answer)

    for col = 1, WORD_LENGTH do
        updateTile(row, col, guess:sub(col, col), result[col])
        updateKeyboard(guess:sub(col, col), result[col])
    end

    table.insert(state.guesses, guess)
    state.currentInput = ""
    InputBox:SetText("")

    -- Persist progress after every guess so a relog can restore the board.
    saveProgress()

    local allCorrect = true
    for _, r in ipairs(result) do
        if r ~= "correct" then allCorrect = false; break end
    end

    if allCorrect then
        state.won = true
        saveProgress()
        recordResult(true, #state.guesses, state.isDaily)
        if state.isDaily then
            markDailyCompleted()
            local noun = #state.guesses == 1 and "guess" or "guesses"
            MainFrame.msgText:SetText(
                factionCheer() .. " Daily word solved in " ..
                #state.guesses .. " " .. noun .. "!")
        else
            MainFrame.msgText:SetText(factionCheer() .. " You got it!")
        end
    elseif #state.guesses >= state.maxGuesses then
        state.lost = true
        saveProgress()
        recordResult(false, #state.guesses, state.isDaily)
        if state.isDaily then markDailyCompleted() end
        MainFrame.msgText:SetText(
            "|cffff4444Defeated!|r\n" ..
            "|cffaaaaaaThe word was|r |cffffcc00" .. state.answer .. "|r")
    end
end

-- ============================================================
-- CHALLENGE / WORD SHARING
-- ROT13 is its own inverse so the same function encodes and decodes.
-- ============================================================

-- Vigenère cipher with fixed key. encode=true encrypts, encode=false decrypts.
local function vigenere(str, encode)
    local key    = "WOWDLE"
    local keyLen = #key
    local result = {}
    for i = 1, #str do
        local c = str:sub(i, i):upper()
        local b = string.byte(c)
        if b >= 65 and b <= 90 then
            local shift = string.byte(key, (i - 1) % keyLen + 1) - 65
            if encode then
                table.insert(result, string.char((b - 65 + shift) % 26 + 65))
            else
                table.insert(result, string.char((b - 65 - shift + 26) % 26 + 65))
            end
        else
            table.insert(result, c)
        end
    end
    return table.concat(result)
end

-- Opens a small popup with a pre-filled editbox the player can copy.
local function showChallengePopup(code)
    local popup = CreateFrame("Frame", "WoWdleChallengePopup", UIParent, "BackdropTemplate")
    popup:SetSize(320, 90)
    popup:SetPoint("CENTER", UIParent, "CENTER")
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(200)
    popup:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    popup:SetBackdropColor(0.05, 0.05, 0.08, 0.97)
    popup:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", popup, "TOP", 0, -12)
    title:SetText("|cffffcc00Share this challenge with a friend:|r")

    local shareText = "/wowdle play " .. code

    local eb = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    eb:SetSize(280, 24)
    eb:SetPoint("TOP", title, "BOTTOM", 0, -8)
    eb:SetText(shareText)
    eb:SetCursorPosition(0)
    eb:HighlightText()
    eb:SetAutoFocus(true)
    -- Keep text selected and prevent editing.
    eb:SetScript("OnTextChanged", function(self)
        self:SetText(shareText)
        self:HighlightText()
    end)
    eb:SetScript("OnEscapePressed", function() popup:Hide() end)
    eb:SetScript("OnEnterPressed", function() popup:Hide() end)

    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    closeBtn:SetSize(60, 22)
    closeBtn:SetPoint("BOTTOM", popup, "BOTTOM", 0, 8)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() popup:Hide() end)
end

-- Starts a free play game with a specific challenged word.
-- Called by /wowdle play CODE.
local function startChallengeGame(code)
    local word = vigenere(code:upper(), false)
    if not ANSWER_SET[word] then
        print("|cffffcc00WoWdle|r: |cffff4444Invalid challenge code.|r")
        return
    end
    -- Silently replace any in-progress free play game.
    clearSlot("freeplay")
    state.answer       = applyWord(word)
    state.isDaily      = false
    state.guesses      = {}
    state.won          = false
    state.lost         = false
    state.currentInput = ""
    rebuildGrid()
    resetBoard()
    MainFrame.TitleText:SetText("WoWdle  |cffffcc00– Challenge|r")
    if refreshModeButtons then refreshModeButtons() end
    saveProgress()
    MainFrame:Show()
    print("|cffffcc00WoWdle|r: Challenge accepted! Good luck!")
end
local function createKeyButton(parent, letter, x, y)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(KEY_W, KEY_H)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetColorTexture(0.20, 0.20, 0.25)
    btn.bg:SetPoint("TOPLEFT",     btn, "TOPLEFT",      1, -1)
    btn.bg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1,  1)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetAllPoints()
    btn.text:SetJustifyH("CENTER")
    btn.text:SetJustifyV("MIDDLE")
    btn.text:SetText(letter)
    btn.text:SetTextColor(1, 1, 1)

    btn:SetScript("OnClick", function()
        if state.won or state.lost then return end
        if #state.currentInput < WORD_LENGTH then
            state.currentInput = state.currentInput .. letter
            updateCurrentRowDisplay()
        end
        InputBox:SetFocus()
    end)

    btn.status = nil
    KeyButtons[letter] = btn
    return btn
end

local function buildKeyboardRow(parent, letters, startX, startY)
    local x = startX
    for i = 1, #letters do
        createKeyButton(parent, letters:sub(i, i), x, startY)
        x = x + KEY_W + 4
    end
end

local function BuildUI()
    MainFrame = CreateFrame("Frame", "WoWdleFrame", UIParent, "BasicFrameTemplateWithInset")
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
    MainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position so it persists across sessions.
        local pos = WoWdle_SavedVars.windowPos or {}
        pos.point, pos.x, pos.y = "TOPLEFT", self:GetLeft(), self:GetTop() - UIParent:GetHeight()
        WoWdle_SavedVars.windowPos = pos
    end)

    -- Restore saved position or default to center.
    local pos = WoWdle_SavedVars and WoWdle_SavedVars.windowPos
    if pos and pos.point then
        MainFrame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    else
        MainFrame:SetPoint("CENTER")
    end

    MainFrame:Hide()
    MainFrame.TitleText:SetText("WoWdle")

    GridFrame = CreateFrame("Frame", nil, MainFrame)
    GridFrame:SetPoint("TOP", MainFrame, "TOP", 0, -40)

    MainFrame.msgText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    MainFrame.msgText:SetPoint("TOP", GridFrame, "BOTTOM", 0, -8)
    MainFrame.msgText:SetWidth(300)
    MainFrame.msgText:SetText("")

    -- Countdown to next daily reset (midnight local time).
    local countdownText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countdownText:SetPoint("TOP", MainFrame.msgText, "BOTTOM", 0, -4)
    countdownText:SetWidth(300)
    countdownText:SetText("")
    countdownText:SetTextColor(0.7, 0.7, 0.7)
    MainFrame.countdownText = countdownText

    -- Ticker frame — updates the countdown every second.
    local tickerFrame = CreateFrame("Frame", nil, MainFrame)
    local tickAccum   = 0
    local function updateCountdown()
        if not state.isDaily then
            countdownText:SetText("")
            return
        end
        local t    = date("*t")
        local secs = (23 - t.hour) * 3600 + (59 - t.min) * 60 + (59 - t.sec) + 1
        local h    = math.floor(secs / 3600)
        local m    = math.floor((secs % 3600) / 60)
        local s    = secs % 60
        countdownText:SetText(string.format(
            "|cffaaaaaaNext daily in:|r |cffffcc00%02d:%02d:%02d|r", h, m, s))
    end
    tickerFrame:SetScript("OnUpdate", function(self, elapsed)
        tickAccum = tickAccum + elapsed
        if tickAccum >= 1 then
            tickAccum = 0
            updateCountdown()
        end
    end)
    -- Run once immediately so there's no blank frame on first show.
    updateCountdown()
    MainFrame.updateCountdown = updateCountdown

    local kbFrame = CreateFrame("Frame", nil, MainFrame)
    MainFrame.kbFrame = kbFrame
    kbFrame:SetSize(320, (KEY_H + 5) * 3)
    kbFrame:SetPoint("TOP", countdownText, "BOTTOM", 0, -6)

    local row1X, row2X, row3X = 2, 16, 30
    buildKeyboardRow(kbFrame, "QWERTYUIOP", row1X, 0)
    buildKeyboardRow(kbFrame, "ASDFGHJKL",  row2X, -(KEY_H + 5))
    buildKeyboardRow(kbFrame, "ZXCVBNM",    row3X, -(KEY_H + 5) * 2)

    local enterBtn = CreateFrame("Button", nil, kbFrame, "UIPanelButtonTemplate")
    enterBtn:SetSize(52, KEY_H)
    enterBtn:SetPoint("TOPLEFT", kbFrame, "TOPLEFT",
                      row3X + 7 * (KEY_W + 4) + 4, -(KEY_H + 5) * 2)
    enterBtn:SetText("ENTER")
    enterBtn:SetScript("OnClick", function() submitGuess(); InputBox:SetFocus() end)

    local bsBtn = CreateFrame("Button", nil, kbFrame, "UIPanelButtonTemplate")
    bsBtn:SetSize(36, KEY_H)
    bsBtn:SetPoint("TOPLEFT", kbFrame, "TOPLEFT", row3X - 40, -(KEY_H + 5) * 2)
    bsBtn:SetText("Del")
    bsBtn:SetScript("OnClick", function()
        if #state.currentInput > 0 then
            state.currentInput = state.currentInput:sub(1, -2)
            updateCurrentRowDisplay()
        end
        InputBox:SetFocus()
    end)

    InputBox = CreateFrame("EditBox", "WoWdleInputBox", MainFrame)
    InputBox:SetSize(1, 1)
    InputBox:SetPoint("BOTTOM", MainFrame, "BOTTOM", 0, 8)
    InputBox:SetAutoFocus(false)

    InputBox:SetScript("OnTextChanged", function(self)
        if state.won or state.lost then self:SetText(""); return end
        local txt = self:GetText():upper():gsub("[^A-Z]", "")
        if #txt > WORD_LENGTH then txt = txt:sub(1, WORD_LENGTH) end
        state.currentInput = txt
        self:SetText(txt)
        updateCurrentRowDisplay()
    end)

    InputBox:SetScript("OnEnterPressed", function()
        submitGuess(); InputBox:SetFocus()
    end)

    InputBox:SetScript("OnKeyDown", function(self, key)
        if key == "BACKSPACE" and #state.currentInput > 0 then
            state.currentInput = state.currentInput:sub(1, -2)
            self:SetText(state.currentInput)
            updateCurrentRowDisplay()
        end
    end)

    -- Bottom button row 1 (always visible): [Mode Toggle]   [Stats] [Options]
    local modeBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    modeBtn:SetSize(90, 24)
    modeBtn:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 8, 8)
    modeBtn:SetScript("OnClick", function()
        if state.isDaily then
            switchToFreePlay()
        else
            switchToDaily()
        end
    end)
    MainFrame.modeBtn = modeBtn

    local optionsBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    optionsBtn:SetSize(70, 24)
    optionsBtn:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -8, 8)
    optionsBtn:SetText("Options")
    optionsBtn:SetScript("OnClick", function()
        if MainFrame.optionsPanel:IsShown() then
            MainFrame.optionsPanel:Hide()
        else
            if MainFrame.statsPanel:IsShown() then MainFrame.statsPanel:Hide() end
            MainFrame.optionsPanel:Show()
        end
    end)
    MainFrame.optionsBtn = optionsBtn

    local statsBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    statsBtn:SetSize(60, 24)
    statsBtn:SetPoint("BOTTOMRIGHT", optionsBtn, "BOTTOMLEFT", -4, 0)
    statsBtn:SetText("Stats")
    statsBtn:SetScript("OnClick", function()
        if MainFrame.statsPanel:IsShown() then
            MainFrame.statsPanel:Hide()
        else
            if MainFrame.optionsPanel:IsShown() then MainFrame.optionsPanel:Hide() end
            MainFrame.statsPanel:refreshAndShow()
        end
    end)
    MainFrame.statsBtn = statsBtn

    -- Bottom button row 2 (free play only): [New Word] [Challenge]  on left
    --                                        [____code____] [Go]     on right
    local newWordBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    newWordBtn:SetSize(80, 24)
    newWordBtn:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 8, 38)
    newWordBtn:SetText("New Word")
    newWordBtn:SetScript("OnClick", function()
        if #state.guesses > 0 and not state.won and not state.lost then
            recordSkip()
        end
        clearSlot("freeplay")
        startFreeGame()
        saveProgress()
    end)
    newWordBtn:Hide()
    MainFrame.newWordBtn = newWordBtn

    local challengeBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    challengeBtn:SetSize(80, 24)
    challengeBtn:SetPoint("BOTTOMLEFT", newWordBtn, "BOTTOMRIGHT", 4, 0)
    challengeBtn:SetText("Challenge")
    challengeBtn:SetScript("OnClick", function()
        showChallengePopup(vigenere(state.answer, true))
    end)
    challengeBtn:Hide()
    MainFrame.challengeBtn = challengeBtn

    -- Code input and Go button anchored from the RIGHT so they don't overflow
    local goBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    goBtn:SetSize(30, 24)
    goBtn:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -8, 38)
    goBtn:SetText("Go")
    goBtn:Hide()
    MainFrame.goBtn = goBtn

    local codeBox = CreateFrame("EditBox", "WoWdleChallengeInput", MainFrame, "InputBoxTemplate")
    codeBox:SetSize(80, 20)
    codeBox:SetPoint("BOTTOMRIGHT", goBtn, "BOTTOMLEFT", -4, 2)
    codeBox:SetMaxLetters(8)
    codeBox:SetAutoFocus(false)
    codeBox:SetText("")
    codeBox:Hide()
    MainFrame.codeBox = codeBox

    local function acceptChallengeCode()
        local code = codeBox:GetText():gsub("%s+", "")
        if code ~= "" then
            startChallengeGame(code)
            codeBox:SetText("")
        end
    end

    goBtn:SetScript("OnClick", acceptChallengeCode)
    codeBox:SetScript("OnEnterPressed", acceptChallengeCode)
    codeBox:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)
    codeBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Enter Challenge Code", 1, 1, 1)
        GameTooltip:AddLine("Ask a friend to share their Free Play word using the Challenge button. Paste their code here and press Enter or Go to play the same word.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    codeBox:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Updates mode toggle label, second row visibility, and frame height.
    refreshModeButtons = function()
        if state.isDaily then
            modeBtn:SetText("Free Play")
            newWordBtn:Hide()
            challengeBtn:Hide()
            codeBox:Hide()
            goBtn:Hide()
        else
            modeBtn:SetText("Daily")
            newWordBtn:Show()
            challengeBtn:Show()
            codeBox:Show()
            goBtn:Show()
        end
        MainFrame:SetSize(frameWidth(WORD_LENGTH), frameHeight(WORD_LENGTH, state.isDaily))
        if MainFrame.updateCountdown then MainFrame.updateCountdown() end
    end

    local function hideGameContent()
        GridFrame:Hide()
        MainFrame.kbFrame:Hide()
        MainFrame.msgText:Hide()
        MainFrame.countdownText:Hide()
    end

    local function showGameContent()
        GridFrame:Show()
        MainFrame.kbFrame:Show()
        MainFrame.msgText:Show()
        MainFrame.countdownText:Show()
    end

    -- ----------------------------------------------------------------
    -- STATS PANEL
    -- ----------------------------------------------------------------
    local sp = CreateFrame("Frame", "WoWdleStatsPanel", UIParent, "BackdropTemplate")
    sp:SetFrameStrata("FULLSCREEN_DIALOG")
    sp:SetFrameLevel(100)
    sp:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    sp:SetBackdropColor(0.05, 0.05, 0.08, 0.97)
    sp:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)
    sp:Hide()
    sp:SetScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT",     MainFrame, "TOPLEFT",      8, -28)
        self:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -8,  28)
        hideGameContent()
    end)
    sp:SetScript("OnHide", function()
        if not MainFrame.optionsPanel or not MainFrame.optionsPanel:IsShown() then
            showGameContent()
        end
    end)

    local spTitle = sp:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spTitle:SetPoint("TOP", sp, "TOP", 0, -16)
    spTitle:SetText("|cffffcc00Statistics|r")

    local statLabels = {"Played", "Win %", "Skipped", "Streak", "Best"}
    local statKeys   = {"gamesPlayed", "winPct", "gamesSkipped", "currentStreak", "bestStreak"}
    local statValues = {}
    local boxW       = 46
    local totalW     = #statLabels * boxW + (#statLabels - 1) * 6
    local startX     = -totalW / 2 + boxW / 2

    for i, label in ipairs(statLabels) do
        local bx  = startX + (i - 1) * (boxW + 6)
        local val = sp:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        val:SetPoint("TOP", sp, "TOP", bx, -50)
        val:SetJustifyH("CENTER")
        val:SetText("0")
        statValues[statKeys[i]] = val

        local lbl = sp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOP", val, "BOTTOM", 0, -2)
        lbl:SetText(label)
        lbl:SetTextColor(0.8, 0.8, 0.8)
    end

    local distHeader = sp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    distHeader:SetPoint("TOP", sp, "TOP", 0, -115)
    distHeader:SetText("|cffaaaaaaGuess Distribution|r")

    local barRows    = {}
    local barStartY  = -135
    local barH       = 20
    local barSpacing = 26
    local barMaxW    = 180

    for i = 1, 6 do
        local rowY = barStartY - (i - 1) * barSpacing
        local rc   = RARITY_COLORS[i]

        local numLbl = sp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        numLbl:SetPoint("TOPLEFT", sp, "TOPLEFT", 14, rowY)
        numLbl:SetText(tostring(i))
        numLbl:SetJustifyH("CENTER")
        numLbl:SetWidth(14)
        numLbl:SetTextColor(unpack(rc))

        local barBg = CreateFrame("Frame", nil, sp, "BackdropTemplate")
        barBg:SetHeight(barH)
        barBg:SetPoint("TOPLEFT", sp, "TOPLEFT", 34, rowY)
        barBg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        barBg:SetBackdropColor(0.15, 0.15, 0.18, 1)

        local barFill = CreateFrame("Frame", nil, barBg, "BackdropTemplate")
        barFill:SetPoint("TOPLEFT",    barBg, "TOPLEFT",    0, 0)
        barFill:SetPoint("BOTTOMLEFT", barBg, "BOTTOMLEFT", 0, 0)
        barFill:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        barFill:SetBackdropColor(unpack(COLOR_ABSENT))

        local countLbl = barFill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        countLbl:SetPoint("RIGHT", barFill, "RIGHT", -4, 0)
        countLbl:SetJustifyH("RIGHT")
        countLbl:SetText("0")

        barRows[i] = { bg = barBg, fill = barFill, count = countLbl }
    end

    local spClose = CreateFrame("Button", nil, sp, "UIPanelButtonTemplate")
    spClose:SetSize(80, 24)
    spClose:SetPoint("BOTTOM", sp, "BOTTOM", 0, 12)
    spClose:SetText("Close")
    spClose:SetScript("OnClick", function() sp:Hide() end)

    function sp:refreshAndShow()
        local s   = getStats()
        local decisive = s.gamesPlayed - s.gamesSkipped
        local pct = decisive > 0
                    and math.floor(s.gamesWon / decisive * 100)
                    or 0

        statValues["gamesPlayed"]:SetText(tostring(s.gamesPlayed))
        statValues["winPct"]:SetText(tostring(pct))
        statValues["gamesSkipped"]:SetText(tostring(s.gamesSkipped))
        statValues["currentStreak"]:SetText(tostring(s.currentStreak))
        statValues["bestStreak"]:SetText(tostring(s.bestStreak))

        local maxVal = 1
        for i = 1, 6 do
            if s.guessDistrib[i] > maxVal then maxVal = s.guessDistrib[i] end
        end

        local winRow = (state.won and #state.guesses >= 1 and #state.guesses <= 6)
                       and #state.guesses or nil

        for i = 1, 6 do
            local v    = s.guessDistrib[i]
            local frac = v / maxVal
            local w    = math.max(24, math.floor(frac * barMaxW))
            local rc   = RARITY_COLORS[i]

            barRows[i].bg:SetWidth(barMaxW)
            barRows[i].fill:SetWidth(w)
            barRows[i].count:SetText(tostring(v))

            if i == winRow then
                barRows[i].fill:SetBackdropColor(rc[1], rc[2], rc[3], 1)
                barRows[i].bg:SetBackdropColor(rc[1] * 0.35, rc[2] * 0.35, rc[3] * 0.35, 1)
            else
                barRows[i].fill:SetBackdropColor(rc[1] * 0.55, rc[2] * 0.55, rc[3] * 0.55, 1)
                barRows[i].bg:SetBackdropColor(0.15, 0.15, 0.18, 1)
            end
        end

        self:Show()
    end

    MainFrame.statsPanel = sp

    -- ----------------------------------------------------------------
    -- OPTIONS PANEL
    -- ----------------------------------------------------------------
    local op = CreateFrame("Frame", "WoWdleOptionsPanel", UIParent, "BackdropTemplate")
    op:SetFrameStrata("FULLSCREEN_DIALOG")
    op:SetFrameLevel(100)
    op:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    op:SetBackdropColor(0.05, 0.05, 0.08, 0.97)
    op:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)
    op:Hide()
    op:SetScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT",     MainFrame, "TOPLEFT",      8, -28)
        self:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -8,  36)
        hideGameContent()
    end)
    op:SetScript("OnHide", function()
        if not MainFrame.statsPanel or not MainFrame.statsPanel:IsShown() then
            showGameContent()
        end
    end)

    local opTitle = op:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    opTitle:SetPoint("TOP", op, "TOP", 0, -16)
    opTitle:SetText("|cffffcc00Options|r")

    local divider = op:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.3, 0.3, 0.35, 1)
    divider:SetSize(200, 1)
    divider:SetPoint("TOP", opTitle, "BOTTOM", 0, -6)

    local ROW_H      = 28
    local ROW_INDENT = 14
    local rowStartY  = -46

    for i, def in ipairs(OPTION_DEFS) do
        local rowY   = rowStartY - (i - 1) * (ROW_H + 4)
        local optKey = def.key

        local cb = CreateFrame("CheckButton", nil, op, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", op, "TOPLEFT", ROW_INDENT, rowY)
        cb:SetChecked(getOptions()[optKey])

        local lbl = op:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        lbl:SetJustifyH("LEFT")

        local hitZone = CreateFrame("Frame", nil, op)
        hitZone:SetPoint("TOPLEFT",     cb, "TOPLEFT",     0,   0)
        hitZone:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", 160, 0)
        hitZone:EnableMouse(true)
        hitZone:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(def.label, 1, 1, 1)
            GameTooltip:AddLine(def.desc, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        hitZone:SetScript("OnLeave", function() GameTooltip:Hide() end)

        local function refreshCB()
            local val    = getOptions()[optKey]
            local locked = (optKey == "hardMode" or optKey == "sixLetterWords" or optKey == "blizzardWords")
                           and (#state.guesses > 0)
                           and not (state.won or state.lost)
            cb:SetChecked(val)
            if locked then
                cb:Disable()
                lbl:SetTextColor(0.5, 0.5, 0.5)
                lbl:SetText(def.label .. " |cff666666(finish game to change)|r")
            else
                cb:Enable()
                lbl:SetTextColor(1, 1, 1)
                lbl:SetText(def.label)
            end
        end
        refreshCB()

        cb:SetScript("OnClick", function(self)
            getOptions()[optKey] = self:GetChecked()
            refreshCB()
            -- Apply minimap button visibility immediately.
            if optKey == "minimapButton" and MinimapBtn then
                if getOptions().minimapButton then
                    MinimapBtn:Show()
                else
                    MinimapBtn:Hide()
                end
            end
        end)

        op:HookScript("OnShow", refreshCB)
    end

    local opClose = CreateFrame("Button", nil, op, "UIPanelButtonTemplate")
    opClose:SetSize(80, 24)
    opClose:SetPoint("BOTTOM", op, "BOTTOM", 0, 10)
    opClose:SetText("Close")
    opClose:SetScript("OnClick", function() op:Hide() end)

    MainFrame.optionsPanel = op

    MainFrame:SetScript("OnShow", function() InputBox:SetFocus() end)
    MainFrame:SetScript("OnHide", function()
        sp:Hide()
        op:Hide()
        showGameContent()
    end)
end

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

local function BuildMinimapButton()
    local btn = CreateFrame("Button", "WoWdleMinimapButton", Minimap)
    btn:SetFrameStrata("MEDIUM")
    btn:SetWidth(31); btn:SetHeight(31)
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("anyUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Border: 53x53, anchored TOPLEFT of button with no offset (LibDBIcon standard)
    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(53); overlay:SetHeight(53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    -- Background: dark circle behind the icon
    local background = btn:CreateTexture(nil, "BACKGROUND")
    background:SetWidth(20); background:SetHeight(20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", 7, -5)

    -- Icon: TOPLEFT 7,-5 with texcoord trim (LibDBIcon standard)
    -- INV_Misc_Note_06 is a scroll/paper icon that has existed since vanilla
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(17); icon:SetHeight(17)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_06")
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", 7, -6)

    -- Positioning: angle saved in SavedVars, default 220 (bottom-right area)
    local angle = type(WoWdle_SavedVars.minimapAngle) == "number"
                  and WoWdle_SavedVars.minimapAngle or 220
    local radius = 105

    local function updatePos()
        local radian = math.rad(angle)
        btn:ClearAllPoints()
        btn:SetPoint("CENTER", Minimap, "CENTER",
                     math.cos(radian) * radius,
                     math.sin(radian) * radius)
    end
    updatePos()

    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local scale  = UIParent:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            cx, cy = cx / scale, cy / scale
            angle  = math.deg(math.atan2(cy - my, cx - mx))
            WoWdle_SavedVars.minimapAngle = angle
            updatePos()
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnClick", function()
        if MainFrame:IsShown() then
            MainFrame:Hide()
        else
            MainFrame:Show()
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("WoWdle")
        GameTooltip:AddLine("Click to play!", 1, 1, 1)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    MinimapBtn = btn
    return btn
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================
SLASH_WOWDLE1 = "/wowdle"
SlashCmdList["WOWDLE"] = function(msg)
    local arg, rest = msg and msg:match("^%s*(%S+)%s*(.-)%s*$")
    if arg == "stats" then
        MainFrame:Show()
        MainFrame.optionsPanel:Hide()
        MainFrame.statsPanel:refreshAndShow()
    elseif arg == "options" then
        MainFrame:Show()
        MainFrame.statsPanel:Hide()
        MainFrame.optionsPanel:Show()
    elseif arg == "play" then
        if rest and rest ~= "" then
            startChallengeGame(rest)
        else
            print("|cffffcc00WoWdle|r: Usage: /wowdle play <code>")
        end
    else
        if MainFrame:IsShown() then
            MainFrame:Hide()
        else
            MainFrame:Show()
        end
    end
end

-- ============================================================
-- INIT
-- ============================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    WoWdle_SavedVars = WoWdle_SavedVars or {}

    -- Clear any minimapAngle saved from old broken sessions.
    -- A valid angle is a number; anything else gets wiped so the default kicks in.
    if type(WoWdle_SavedVars.minimapAngle) ~= "number" then
        WoWdle_SavedVars.minimapAngle = nil
    end

    BuildUI()
    BuildMinimapButton()

    -- Respect the saved minimap button option.
    if not getOptions().minimapButton then
        MinimapBtn:Hide()
    end

    -- Try to restore an in-progress game first. If that fails (no save,
    -- stale daily, etc.) fall through to normal daily/free-play startup.
    if not restoreProgress() then
        if dailyAlreadyCompleted() then
            startFreeGame()
        else
            startDailyGame()
        end
    end

    -- Sync mode button highlights with whatever was restored/started.
    if refreshModeButtons then refreshModeButtons() end

    print("|cffffcc00WoWdle|r loaded! Type |cff00ccff/wowdle|r to play. "
        .. "Use |cff00ccff/wowdle stats|r to view statistics.")
end)
