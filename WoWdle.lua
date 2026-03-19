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
local WORDS = (function()
    local pool = {}
    for _, w in ipairs(loadAndValidate(5)) do table.insert(pool, w) end
    for _, w in ipairs(loadAndValidate(6)) do table.insert(pool, w) end
    return pool
end)()

-- ============================================================
-- SAVED VARIABLES  (declare in .toc: ## SavedVariables: WoWdle_SavedVars)
-- ============================================================
WoWdle_SavedVars = WoWdle_SavedVars or {}

-- ============================================================
-- DAILY WORD HELPERS
-- ============================================================

local function todayStamp()
    local t = date("*t")
    return t.year * 10000 + t.month * 100 + t.day
end

local function dailyIndex(stamp)
    local h = (stamp * 2654435761) % (2^32)
    return (h % #WORDS) + 1
end

local function getDailyWord()
    return WORDS[dailyIndex(todayStamp())]
end

local function dailyAlreadyCompleted()
    return WoWdle_SavedVars.lastCompletedDate == todayStamp()
end

local function markDailyCompleted()
    WoWdle_SavedVars.lastCompletedDate = todayStamp()
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

-- ============================================================
-- HELPERS
-- ============================================================
local function randomWord()
    return WORDS[math.random(1, #WORDS)]
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

local function submitGuess()
    if state.won or state.lost then return end

    local guess = state.currentInput:upper()
    if #guess ~= WORD_LENGTH then
        MainFrame.msgText:SetText("|cffff4444Need " .. WORD_LENGTH .. " letters!|r")
        return
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

    -- Free Play / New Word button (centered, hidden until daily is done)
    local newGameBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    newGameBtn:SetSize(100, 24)
    newGameBtn:SetPoint("BOTTOM", MainFrame, "BOTTOM", 0, 30)
    newGameBtn:SetText("Free Play")
    newGameBtn:SetScript("OnClick", startFreeGame)
    newGameBtn:Hide()
    MainFrame.newGameBtn = newGameBtn

    MainFrame:SetScript("OnShow", function() InputBox:SetFocus() end)
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================
SLASH_WOWDLE1 = "/wowdle"
SlashCmdList["WOWDLE"] = function()
    if MainFrame:IsShown() then
        MainFrame:Hide()
    else
        MainFrame:Show()
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

    print("|cffffcc00WoWdle|r loaded! Type |cff00ccff/wowdle|r to play.")
end)
