-- WoWdle: A Wordle clone for World of Warcraft
-- A WoW-themed Wordle addon

local addonName, addon = ...

-- ============================================================
-- WORD LIST
-- Loaded from WoWdle_Words5.lua and WoWdle_Words6.lua.
-- Both files must be listed before this one in the .toc.
-- Words of both lengths are merged into one flat pool.
-- Each game picks randomly from the full pool; the UI resizes
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

-- Single flat list containing all 5- and 6-letter words.
-- ANSWER_SET is a hash for O(1) membership checks during guess validation.
local WORDS      = {}
local ANSWER_SET = {}   -- ANSWER_SET[word] = true
do
    for _, w in ipairs(loadAndValidate(5)) do
        table.insert(WORDS, w)
        ANSWER_SET[w] = true
    end
    for _, w in ipairs(loadAndValidate(6)) do
        table.insert(WORDS, w)
        ANSWER_SET[w] = true
    end
end

-- ============================================================
-- VALID GUESS SETS
-- Loaded from WoWdle_ValidGuesses5.lua and WoWdle_ValidGuesses6.lua.
-- These words are accepted as guesses but are never chosen as answers.
-- Stored as hash sets for O(1) lookup.
-- ============================================================

local function loadValidGuesses(letterCount)
    local source = WoWdle_ValidGuesses and WoWdle_ValidGuesses[letterCount]
    if not source then
        -- Valid guesses files are optional — just warn rather than error.
        print("|cffffcc00WoWdle|r: WoWdle_ValidGuesses[" .. letterCount .. "] not found. "
              .. "All " .. letterCount .. "-letter words will be accepted as guesses.")
        return {}
    end
    local set = {}
    for _, w in ipairs(source) do
        w = w:upper()
        if #w == letterCount then
            set[w] = true
        end
    end
    return set
end

local VALID_GUESSES = {
    [5] = loadValidGuesses(5),
    [6] = loadValidGuesses(6),
}

-- Returns true if word is an acceptable guess for the current game length.
local function isValidGuess(word)
    return ANSWER_SET[word] == true
        or (VALID_GUESSES[#word] and VALID_GUESSES[#word][word] == true)
end

-- ============================================================
-- SAVED VARIABLES  (declare in .toc: ## SavedVariables: WoWdle_SavedVars)
-- ============================================================
WoWdle_SavedVars = WoWdle_SavedVars or {}

-- ============================================================
-- OPTIONS
-- Stored in WoWdle_SavedVars.options.
-- Must be defined before daily helpers so activePool() is available.
-- ============================================================

local OPTION_DEFS = {
    -- Each entry: { key, default, label, desc }
    -- Add new options here; the panel builds itself from this table.
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

-- Returns the answer pool filtered by current options.
-- Called at game-start so option changes take effect on the next game.
local function activePool()
    if getOptions().sixLetterWords then
        return WORDS   -- full pool, no filtering needed
    end
    local pool = {}
    for _, w in ipairs(WORDS) do
        if #w == 5 then table.insert(pool, w) end
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
    local pool = activePool()
    local h    = (todayStamp() * 2654435761) % (2^32)
    return pool[(h % #pool) + 1]
end

local function dailyAlreadyCompleted()
    return WoWdle_SavedVars.lastCompletedDate == todayStamp()
end

local function markDailyCompleted()
    WoWdle_SavedVars.lastCompletedDate = todayStamp()
end


-- ============================================================
-- STATS
-- Stored in WoWdle_SavedVars.stats.
-- Streaks are daily-only; free play counts toward played/won/distribution.
-- ============================================================

local function getStats()
    if not WoWdle_SavedVars.stats then
        WoWdle_SavedVars.stats = {
            gamesPlayed      = 0,
            gamesWon         = 0,
            currentStreak    = 0,
            bestStreak       = 0,
            lastDailyWonDate = 0,
            guessDistrib     = {0, 0, 0, 0, 0, 0},
        }
    end
    if not WoWdle_SavedVars.stats.guessDistrib then
        WoWdle_SavedVars.stats.guessDistrib = {0, 0, 0, 0, 0, 0}
    end
    return WoWdle_SavedVars.stats
end

-- Returns yesterday's date stamp.
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

-- ============================================================
-- ACTIVE WORD LENGTH  (derived from state.answer, never set manually)
-- ============================================================
local WORD_LENGTH = 5   -- updated by applyWord() before any UI call

local function applyWord(word)
    -- Set the answer and sync WORD_LENGTH from it.
    -- Must be called before resetBoard() or rebuildGrid().
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
local TileFrames = {}
local KeyButtons = {}

-- ============================================================
-- LAYOUT
-- ============================================================
local FRAME_PADDING = 20
local MAX_GRID_W    = 300
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

local function frameHeight(len)
    return gridHeight(len) + 30 + (KEY_H + 5) * 3 + 60 + 40
end

-- ============================================================
-- COLORS
-- ============================================================
local COLOR_CORRECT = {0.18, 0.65, 0.35, 1}
local COLOR_PRESENT = {0.75, 0.60, 0.10, 1}
local COLOR_ABSENT  = {0.28, 0.28, 0.28, 1}
local COLOR_EMPTY   = {0.10, 0.10, 0.10, 1}
local COLOR_TEXT    = {1, 1, 1}

-- WoW item rarity colors mapped to guess count (1=Legendary ... 6=Poor/Junk)
local RARITY_COLORS = {
    [1] = {1.00, 0.50, 0.00, 1},   -- Legendary (orange)
    [2] = {0.64, 0.21, 0.93, 1},   -- Epic      (purple)
    [3] = {0.00, 0.44, 0.87, 1},   -- Rare      (blue)
    [4] = {0.12, 1.00, 0.00, 1},   -- Uncommon  (green)
    [5] = {1.00, 1.00, 1.00, 1},   -- Common    (white)
    [6] = {0.62, 0.62, 0.62, 1},   -- Poor/Junk (grey)
}

-- ============================================================
-- HELPERS
-- ============================================================
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
-- GRID REBUILD  (called after applyWord() sets WORD_LENGTH)
-- ============================================================
local function rebuildGrid()
    local len = WORD_LENGTH
    local ts  = tileSize(len)

    MainFrame:SetSize(frameWidth(len), frameHeight(len))

    -- Destroy old tiles
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
-- GAME LOGIC
-- ============================================================
local function resetBoard()
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
    state.answer  = applyWord(getDailyWord())
    state.isDaily = true
    rebuildGrid()
    resetBoard()
    if MainFrame then
        MainFrame.TitleText:SetText("WoWdle  |cff8888ff– Daily|r")
        if MainFrame.newGameBtn then MainFrame.newGameBtn:Hide() end
    end
end

local function startFreeGame()
    state.answer  = applyWord(randomWord())
    state.isDaily = false
    rebuildGrid()
    resetBoard()
    if MainFrame then
        MainFrame.TitleText:SetText("WoWdle  |cffffcc00– Free Play|r")
        if MainFrame.newGameBtn then
            MainFrame.newGameBtn:Show()
            MainFrame.newGameBtn:SetText("New Word")
        end
    end
end

-- Returns an error message string if the guess violates hard mode constraints,
-- or nil if the guess is acceptable. Derives required hints from prior guesses.
local function checkHardMode(guess)
    for _, prev in ipairs(state.guesses) do
        local result = scoreGuess(prev, state.answer)
        -- Correct letters must stay in the same position
        for i = 1, WORD_LENGTH do
            if result[i] == "correct" and guess:sub(i,i) ~= prev:sub(i,i) then
                return "Position " .. i .. " must be " .. prev:sub(i,i) .. "!"
            end
        end
        -- Present letters must appear somewhere in the new guess
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

    local allCorrect = true
    for _, r in ipairs(result) do
        if r ~= "correct" then allCorrect = false; break end
    end

    if allCorrect then
        state.won = true
        recordResult(true, #state.guesses, state.isDaily)
        if state.isDaily then
            markDailyCompleted()
            local noun = #state.guesses == 1 and "guess" or "guesses"
            MainFrame.msgText:SetText(
                "|cff00ff7fFor the Horde! Daily word solved in " ..
                #state.guesses .. " " .. noun .. "!|r\n" ..
                "|cffaaaaaaFree Play is now unlocked for today.|r")
            if MainFrame.newGameBtn then
                MainFrame.newGameBtn:SetText("Free Play")
                MainFrame.newGameBtn:Show()
            end
        else
            MainFrame.msgText:SetText("|cff00ff7fFor the Horde! You got it!|r")
        end
    elseif #state.guesses >= state.maxGuesses then
        state.lost = true
        recordResult(false, #state.guesses, state.isDaily)
        if state.isDaily then
            markDailyCompleted()
            MainFrame.msgText:SetText(
                "|cffff4444Defeated! The word was: |cffffcc00" .. state.answer .. "|r\n" ..
                "|cffaaaaaaFree Play is now unlocked for today.|r")
            if MainFrame.newGameBtn then
                MainFrame.newGameBtn:SetText("Free Play")
                MainFrame.newGameBtn:Show()
            end
        else
            MainFrame.msgText:SetText(
                "|cffff4444Defeated! The word was: |cffffcc00" .. state.answer .. "|r")
        end
    end
end

-- ============================================================
-- UI BUILDER  (called once; grid rebuilt per game via rebuildGrid)
-- ============================================================
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
    MainFrame:SetPoint("CENTER")
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
    MainFrame:SetScript("OnDragStop",  MainFrame.StopMovingOrSizing)
    MainFrame:Hide()
    MainFrame.TitleText:SetText("WoWdle")

    -- Grid container — size set by rebuildGrid() each game
    GridFrame = CreateFrame("Frame", nil, MainFrame)
    GridFrame:SetPoint("TOP", MainFrame, "TOP", 0, -40)

    -- Message text, anchored below the grid
    MainFrame.msgText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    MainFrame.msgText:SetPoint("TOP", GridFrame, "BOTTOM", 0, -8)
    MainFrame.msgText:SetWidth(300)
    MainFrame.msgText:SetText("")

    -- Keyboard, anchored below message
    local kbFrame = CreateFrame("Frame", nil, MainFrame)
    MainFrame.kbFrame = kbFrame
    kbFrame:SetSize(300, (KEY_H + 5) * 3)
    kbFrame:SetPoint("TOP", MainFrame.msgText, "BOTTOM", 0, -6)

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
    bsBtn:SetText("←")
    bsBtn:SetScript("OnClick", function()
        if #state.currentInput > 0 then
            state.currentInput = state.currentInput:sub(1, -2)
            updateCurrentRowDisplay()
        end
        InputBox:SetFocus()
    end)

    -- Hidden EditBox for keyboard capture
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

    -- Bottom button row: [Free Play]  [Stats]  [Options]
    --
    -- Free Play / New Word (far left, hidden until daily done)
    local newGameBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    newGameBtn:SetSize(90, 24)
    newGameBtn:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 8, 8)
    newGameBtn:SetText("Free Play")
    newGameBtn:SetScript("OnClick", startFreeGame)
    newGameBtn:Hide()
    MainFrame.newGameBtn = newGameBtn

    -- Options button (far right, always visible)
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

    -- Stats button (left of Options, always visible)
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

    -- Helpers to hide/restore the game content when a panel is shown.
    local function hideGameContent()
        GridFrame:Hide()
        MainFrame.kbFrame:Hide()
        MainFrame.msgText:Hide()
    end

    local function showGameContent()
        GridFrame:Show()
        MainFrame.kbFrame:Show()
        MainFrame.msgText:Show()
    end

    -- ----------------------------------------------------------------
    -- STATS PANEL  (child of UIParent, anchored to MainFrame on show)
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

    -- Title
    local spTitle = sp:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spTitle:SetPoint("TOP", sp, "TOP", 0, -16)
    spTitle:SetText("|cffffcc00Statistics|r")

    -- Top stat boxes: Played / Win% / Streak / Best Streak
    local statLabels = {"Played", "Win %", "Streak", "Best"}
    local statKeys   = {"gamesPlayed", "winPct", "currentStreak", "bestStreak"}
    local statValues = {}
    local boxW, boxH = 58, 50
    local totalW     = #statLabels * boxW + (#statLabels - 1) * 6
    local startX     = -totalW / 2 + boxW / 2

    for i, label in ipairs(statLabels) do
        local bx = startX + (i - 1) * (boxW + 6)

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

    -- Guess distribution header
    local distHeader = sp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    distHeader:SetPoint("TOP", sp, "TOP", 0, -115)
    distHeader:SetText("|cffaaaaaaGuess Distribution|r")

    -- Distribution bars
    local barRows   = {}
    local barStartY = -135
    local barH      = 20
    local barSpacing = 26
    local barMaxW   = 180

    for i = 1, 6 do
        local rowY = barStartY - (i - 1) * barSpacing

        -- Row number label, coloured by rarity
        local numLbl = sp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        numLbl:SetPoint("TOPLEFT", sp, "TOPLEFT", 14, rowY)
        numLbl:SetText(tostring(i))
        numLbl:SetJustifyH("CENTER")
        numLbl:SetWidth(14)
        numLbl:SetTextColor(unpack(RARITY_COLORS[i]))

        -- Bar background
        local barBg = CreateFrame("Frame", nil, sp, "BackdropTemplate")
        barBg:SetHeight(barH)
        barBg:SetPoint("TOPLEFT", sp, "TOPLEFT", 34, rowY)
        barBg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        barBg:SetBackdropColor(0.15, 0.15, 0.18, 1)

        -- Bar fill
        local barFill = CreateFrame("Frame", nil, barBg, "BackdropTemplate")
        barFill:SetPoint("TOPLEFT",  barBg, "TOPLEFT",  0, 0)
        barFill:SetPoint("BOTTOMLEFT", barBg, "BOTTOMLEFT", 0, 0)
        barFill:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        barFill:SetBackdropColor(unpack(COLOR_ABSENT))

        -- Count label inside bar
        local countLbl = barFill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        countLbl:SetPoint("RIGHT", barFill, "RIGHT", -4, 0)
        countLbl:SetJustifyH("RIGHT")
        countLbl:SetText("0")

        barRows[i] = { bg = barBg, fill = barFill, count = countLbl }
    end

    -- Close button
    local closeBtn = CreateFrame("Button", nil, sp, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 24)
    closeBtn:SetPoint("BOTTOM", sp, "BOTTOM", 0, 12)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() sp:Hide() end)

    -- Populate panel with live data
    function sp:refreshAndShow()
        local s   = getStats()
        local pct = s.gamesPlayed > 0
                    and math.floor(s.gamesWon / s.gamesPlayed * 100)
                    or 0

        statValues["gamesPlayed"]:SetText(tostring(s.gamesPlayed))
        statValues["winPct"]:SetText(tostring(pct))
        statValues["currentStreak"]:SetText(tostring(s.currentStreak))
        statValues["bestStreak"]:SetText(tostring(s.bestStreak))

        -- Find max for bar scaling (min 1 to avoid divide-by-zero)
        local maxVal = 1
        for i = 1, 6 do
            if s.guessDistrib[i] > maxVal then maxVal = s.guessDistrib[i] end
        end

        -- Determine winning row (last game's guess count, if won)
        local winRow = (state.won and #state.guesses >= 1 and #state.guesses <= 6)
                       and #state.guesses or nil

        for i = 1, 6 do
            local v    = s.guessDistrib[i]
            local frac = v / maxVal
            local w    = math.max(24, math.floor(frac * barMaxW))  -- min width so "0" is visible

            barRows[i].bg:SetWidth(barMaxW)
            barRows[i].fill:SetWidth(w)
            barRows[i].count:SetText(tostring(v))

            local rc = RARITY_COLORS[i]
            if i == winRow then
                -- Brighten the winning bar slightly so it stands out
                barRows[i].fill:SetBackdropColor(rc[1], rc[2], rc[3], 1)
                barRows[i].bg:SetBackdropColor(rc[1] * 0.35, rc[2] * 0.35, rc[3] * 0.35, 1)
            else
                -- Dimmed version of the rarity color for non-winning bars
                barRows[i].fill:SetBackdropColor(rc[1] * 0.55, rc[2] * 0.55, rc[3] * 0.55, 1)
                barRows[i].bg:SetBackdropColor(0.15, 0.15, 0.18, 1)
            end
        end

        self:Show()
    end

    MainFrame.statsPanel = sp

    -- ----------------------------------------------------------------
    -- OPTIONS PANEL  (child of MainFrame, same overlay style as stats)
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

    -- Title
    local opTitle = op:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    opTitle:SetPoint("TOP", op, "TOP", 0, -16)
    opTitle:SetText("|cffffcc00Options|r")

    -- Divider line under title
    local divider = op:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.3, 0.3, 0.35, 1)
    divider:SetSize(200, 1)
    divider:SetPoint("TOP", opTitle, "BOTTOM", 0, -6)

    -- Option rows built from OPTION_DEFS.
    -- Each row: checkbox on left, label to its right, description on hover.
    local ROW_H      = 28   -- compact single-line height
    local ROW_INDENT = 14
    local rowStartY  = -46

    if #OPTION_DEFS == 0 then
        local placeholder = op:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        placeholder:SetPoint("TOP", op, "TOP", 0, rowStartY - 10)
        placeholder:SetText("|cff888888No options available yet.|r")
    else
        for i, def in ipairs(OPTION_DEFS) do
            local rowY = rowStartY - (i - 1) * (ROW_H + 4)
            local optKey = def.key

            -- Checkbox (native WoW UICheckButtonTemplate: 26x26, has SetChecked/GetChecked)
            local cb = CreateFrame("CheckButton", nil, op, "UICheckButtonTemplate")
            cb:SetSize(24, 24)
            cb:SetPoint("TOPLEFT", op, "TOPLEFT", ROW_INDENT, rowY)
            cb:SetChecked(getOptions()[optKey])

            -- Label to the right of the checkbox
            local lbl = op:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            lbl:SetJustifyH("LEFT")

            -- Invisible hit area covering checkbox + label for tooltip.
            -- Sized explicitly from the checkbox top-left so it doesn't
            -- drift across rows.
            local hitZone = CreateFrame("Frame", nil, op)
            hitZone:SetPoint("TOPLEFT",     cb, "TOPLEFT",     0,  0)
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
                local locked = (optKey == "hardMode" or optKey == "sixLetterWords")
                               and (#state.guesses > 0)
                               and not (state.won or state.lost)
                cb:SetChecked(val)
                if locked then
                    cb:Disable()
                    lbl:SetTextColor(0.5, 0.5, 0.5)
                else
                    cb:Enable()
                    lbl:SetTextColor(1, 1, 1)
                end
                -- Show lock hint in label when disabled mid-game
                if locked then
                    lbl:SetText(def.label .. " |cff666666(finish game to change)|r")
                else
                    lbl:SetText(def.label)
                end
            end
            refreshCB()

            cb:SetScript("OnClick", function(self)
                local o = getOptions()
                o[optKey] = self:GetChecked()
                refreshCB()
            end)

            op:HookScript("OnShow", refreshCB)
        end
    end

    -- Close button
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
        showGameContent()   -- restore so content is visible when window reopens
    end)
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================
SLASH_WOWDLE1 = "/wowdle"
SlashCmdList["WOWDLE"] = function(msg)
    local arg = msg and msg:match("^%s*(%S+)%s*$")
    if arg == "stats" then
        MainFrame:Show()
        MainFrame.optionsPanel:Hide()
        MainFrame.statsPanel:refreshAndShow()
    elseif arg == "options" then
        MainFrame:Show()
        MainFrame.statsPanel:Hide()
        MainFrame.optionsPanel:Show()
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

    BuildUI()

    if dailyAlreadyCompleted() then
        startFreeGame()
    else
        startDailyGame()
    end

    print("|cffffcc00WoWdle|r loaded! Type |cff00ccff/wowdle|r to play. "
        .. "Use |cff00ccff/wowdle stats|r to view statistics.")
end)
