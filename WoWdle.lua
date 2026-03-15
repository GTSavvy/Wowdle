-- WoWdle: A Wordle clone for World of Warcraft
-- A WoW-themed Wordle addon

local addonName, addon = ...

-- ============================================================
-- WORD LIST (WoW-themed 5-letter words)
-- ============================================================
local WORD_LIST = {
    "GNOME", "DWARF", "TROLL", "TAUREN", "DRUID",
    "ROGUE", "MAGE", "PRIEST", "SHAMAN", "PALADIN",
    "WARLOCK", "HUNTER", "WARRIOR",
    "STABS", "FROST", "ARCANE", "DEATH", "DEMON",
    "FERAL", "RESTO", "HAVOC", "BLOOD",
    "ORGRIMMAR", "IRONFORGE", "STORMWIND", "UNDERCITY",
    "THUNDER", "SILVERMOON", "DARNASSUS",
    -- Filtered to exactly 5 letters:
    "GNOME", "DWARF", "TROLL", "DRUID", "ROGUE",
    "FROST", "DEATH", "DEMON", "FERAL", "RESTO",
    "HAVOC", "BLOOD", "NIGHT", "AZERITE", "THRALL",
    "JAINA", "VELEN", "GARROSH", "SYLVANAS",
    "ARENA", "RAID", "DUNGEON",
    -- Strictly 5-letter WoW words:
    "GNOME", "DWARF", "TROLL", "DRUID", "ROGUE",
    "FROST", "DEATH", "FERAL", "BLOOD", "NIGHT",
    "ARENA", "TALON", "CRYPT", "PLAGUED", "CURSE",
    "ALTAR", "GOLEM", "DRAKE", "WYRM", "RUNE",
    "QUEST", "LOOT", "SHARD", "TOTEM", "SIGIL",
    "NEXUS", "VAULT", "FORGE", "ANVIL", "EMBER",
    "STORM", "FLAME", "BLADE", "SHIELD", "SPEAR",
    "ARROW", "STAFF", "CLOAK", "RINGS", "BOOTS",
    "CHEST", "HEALS", "MAGIC", "POWER", "FOCUS",
    "RANGE", "MELEE", "TANK", "BANISH", "CHARM",
    "GLYPH", "ELUNE", "KHAZ", "LIGHT", "GRACE",
    "HONOR", "VALOR", "BADGE", "TOKEN", "CREST",
    "BEAST", "DEMON", "HAVOC", "RESTO", "BEARS",
    "HORDE", "REALM", "GUILD", "RAID", "PATCH",
}

-- Deduplicate and filter to exactly 5 letters
local function buildWordList()
    local seen = {}
    local clean = {}
    for _, w in ipairs(WORD_LIST) do
        w = w:upper()
        if #w == 5 and not seen[w] then
            seen[w] = true
            table.insert(clean, w)
        end
    end
    return clean
end

local WORDS = buildWordList()

-- ============================================================
-- STATE
-- ============================================================
local state = {
    active = false,
    answer = "",
    guesses = {},      -- list of guess strings
    currentInput = "",
    maxGuesses = 6,
    won = false,
    lost = false,
}

-- ============================================================
-- FRAME REFERENCES (populated in BuildUI)
-- ============================================================
local MainFrame, InputBox
local TileFrames = {}   -- TileFrames[row][col]
local KeyButtons = {}   -- KeyButtons["A"] = button

-- ============================================================
-- COLORS
-- ============================================================
local COLOR_CORRECT  = {0.18, 0.65, 0.35, 1}   -- green
local COLOR_PRESENT  = {0.75, 0.60, 0.10, 1}   -- yellow
local COLOR_ABSENT   = {0.28, 0.28, 0.28, 1}   -- dark gray
local COLOR_EMPTY    = {0.10, 0.10, 0.10, 1}   -- near black
local COLOR_ACTIVE   = {0.30, 0.30, 0.35, 1}   -- slightly lit for current row
local COLOR_TEXT     = {1, 1, 1}

-- ============================================================
-- HELPERS
-- ============================================================
local function randomWord()
    return WORDS[math.random(1, #WORDS)]
end

local function scoreGuess(guess, answer)
    -- Returns table of "correct"/"present"/"absent" for each position
    local result = {"absent","absent","absent","absent","absent"}
    local answerCounts = {}

    -- First pass: mark correct
    for i = 1, 5 do
        local g = guess:sub(i,i)
        local a = answer:sub(i,i)
        if g == a then
            result[i] = "correct"
        else
            answerCounts[a] = (answerCounts[a] or 0) + 1
        end
    end

    -- Second pass: mark present
    for i = 1, 5 do
        if result[i] ~= "correct" then
            local g = guess:sub(i,i)
            if answerCounts[g] and answerCounts[g] > 0 then
                result[i] = "present"
                answerCounts[g] = answerCounts[g] - 1
            end
        end
    end

    return result
end

local function setTileColor(tile, r, g, b)
    tile.inner:SetBackdropColor(r, g, b, 1)
end

local function updateTile(row, col, letter, status)
    local tile = TileFrames[row][col]
    tile.text:SetText(letter or "")
    if status == "correct" then
        setTileColor(tile, unpack(COLOR_CORRECT))
    elseif status == "present" then
        setTileColor(tile, unpack(COLOR_PRESENT))
    elseif status == "absent" then
        setTileColor(tile, unpack(COLOR_ABSENT))
    else
        -- empty or active
        setTileColor(tile, unpack(COLOR_EMPTY))
    end
end

local function updateCurrentRowDisplay()
    local row = #state.guesses + 1
    if row > state.maxGuesses then return end
    for col = 1, 5 do
        local letter = state.currentInput:sub(col, col)
        updateTile(row, col, letter, nil)
    end
end

local function updateKeyboard(letter, status)
    local btn = KeyButtons[letter]
    if not btn then return end

    -- Priority: correct > present > absent
    local current = btn.status
    if current == "correct" then return end
    if status == "correct" then
        btn.bg:SetColorTexture(unpack(COLOR_CORRECT))
        btn.status = "correct"
    elseif status == "present" and current ~= "correct" then
        btn.bg:SetColorTexture(unpack(COLOR_PRESENT))
        btn.status = "present"
    elseif status == "absent" and not current then
        btn.bg:SetColorTexture(unpack(COLOR_ABSENT))
        btn.status = "absent"
    end
end

-- ============================================================
-- GAME LOGIC
-- ============================================================
local function startNewGame()
    state.answer = randomWord()
    state.guesses = {}
    state.currentInput = ""
    state.won = false
    state.lost = false

    -- Reset tiles
    for row = 1, 6 do
        for col = 1, 5 do
            updateTile(row, col, "", nil)
        end
    end

    -- Reset keyboard colors
    for letter, btn in pairs(KeyButtons) do
        btn.bg:SetColorTexture(0.20, 0.20, 0.25)
        btn.status = nil
    end

    -- Clear message
    if MainFrame.msgText then
        MainFrame.msgText:SetText("")
    end

    InputBox:SetText("")
    InputBox:SetFocus()
end

local function submitGuess()
    if state.won or state.lost then return end

    local guess = state.currentInput:upper()

    if #guess ~= 5 then
        MainFrame.msgText:SetText("|cffff4444Not enough letters!|r")
        return
    end

    -- Validate it's in word list (optional - allow any 5 letters for fun)
    -- Score the guess
    local row = #state.guesses + 1
    local result = scoreGuess(guess, state.answer)

    -- Reveal tiles
    for col = 1, 5 do
        updateTile(row, col, guess:sub(col,col), result[col])
        updateKeyboard(guess:sub(col,col), result[col])
    end

    table.insert(state.guesses, guess)
    state.currentInput = ""
    InputBox:SetText("")

    -- Check win
    local allCorrect = true
    for _, r in ipairs(result) do
        if r ~= "correct" then allCorrect = false; break end
    end

    if allCorrect then
        state.won = true
        MainFrame.msgText:SetText("|cff00ff7fFor the Horde! You got it!|r")
    elseif #state.guesses >= state.maxGuesses then
        state.lost = true
        MainFrame.msgText:SetText("|cffff4444Defeated! The word was: |cffffcc00" .. state.answer .. "|r")
    end
end

-- ============================================================
-- UI BUILDER
-- ============================================================
local TILE_SIZE = 46
local TILE_GAP  = 6
local KEY_W     = 28
local KEY_H     = 32

local function createTile(parent, row, col)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local x = (col - 1) * (TILE_SIZE + TILE_GAP)
    local y = -(row - 1) * (TILE_SIZE + TILE_GAP)
    f:SetSize(TILE_SIZE, TILE_SIZE)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    -- Outer border frame
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0.4, 0.4, 0.45, 1)

    -- Inner colored frame (inset 1px for border effect)
    local inner = CreateFrame("Frame", nil, f, "BackdropTemplate")
    inner:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    inner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    inner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    inner:SetBackdropColor(unpack(COLOR_EMPTY))
    inner:SetBackdropBorderColor(0, 0, 0, 0)
    f.inner = inner

    f.text = inner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.text:SetAllPoints()
    f.text:SetJustifyH("CENTER")
    f.text:SetJustifyV("MIDDLE")
    f.text:SetTextColor(unpack(COLOR_TEXT))

    return f
end

local function createKeyButton(parent, letter, x, y)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(KEY_W, KEY_H)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0.20, 0.20, 0.25)

    -- border
    btn.border = btn:CreateTexture(nil, "BORDER")
    btn.border:SetPoint("TOPLEFT", 1, -1)
    btn.border:SetPoint("BOTTOMRIGHT", -1, 1)
    btn.bg:SetPoint("TOPLEFT", 1, -1)
    btn.bg:SetPoint("BOTTOMRIGHT", -1, 1)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetAllPoints()
    btn.text:SetJustifyH("CENTER")
    btn.text:SetJustifyV("MIDDLE")
    btn.text:SetText(letter)
    btn.text:SetTextColor(1,1,1)

    btn:SetScript("OnClick", function()
        if state.won or state.lost then return end
        if #state.currentInput < 5 then
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
        createKeyButton(parent, letters:sub(i,i), x, startY)
        x = x + KEY_W + 4
    end
end

local function BuildUI()
    -- Main frame
    MainFrame = CreateFrame("Frame", "WoWdleFrame", UIParent, "BasicFrameTemplateWithInset")
    MainFrame:SetSize(340, 560)
    MainFrame:SetPoint("CENTER")
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
    MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)
    MainFrame:Hide()

    MainFrame.TitleText:SetText("WoWdle")

    -- Grid container
    local gridW = 5 * TILE_SIZE + 4 * TILE_GAP
    local gridH = 6 * TILE_SIZE + 5 * TILE_GAP
    local grid = CreateFrame("Frame", nil, MainFrame)
    grid:SetSize(gridW, gridH)
    grid:SetPoint("TOP", MainFrame, "TOP", 0, -40)

    for row = 1, 6 do
        TileFrames[row] = {}
        for col = 1, 5 do
            TileFrames[row][col] = createTile(grid, row, col)
        end
    end

    -- Message text
    MainFrame.msgText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    MainFrame.msgText:SetPoint("TOP", grid, "BOTTOM", 0, -8)
    MainFrame.msgText:SetWidth(300)
    MainFrame.msgText:SetText("")

    -- Keyboard
    local kbFrame = CreateFrame("Frame", nil, MainFrame)
    kbFrame:SetSize(300, 100)
    kbFrame:SetPoint("TOP", MainFrame.msgText, "BOTTOM", 0, -6)

    local row1X = 2
    local row2X = 16
    local row3X = 30
    buildKeyboardRow(kbFrame, "QWERTYUIOP", row1X, 0)
    buildKeyboardRow(kbFrame, "ASDFGHJKL",  row2X, -(KEY_H + 5))
    buildKeyboardRow(kbFrame, "ZXCVBNM",    row3X, -(KEY_H + 5)*2)

    -- Enter button
    local enterBtn = CreateFrame("Button", nil, kbFrame, "UIPanelButtonTemplate")
    enterBtn:SetSize(52, KEY_H)
    enterBtn:SetPoint("TOPLEFT", kbFrame, "TOPLEFT", row3X + 7*(KEY_W+4) + 4, -(KEY_H+5)*2)
    enterBtn:SetText("ENTER")
    enterBtn:SetScript("OnClick", function()
        submitGuess()
        InputBox:SetFocus()
    end)

    -- Backspace button
    local bsBtn = CreateFrame("Button", nil, kbFrame, "UIPanelButtonTemplate")
    bsBtn:SetSize(36, KEY_H)
    bsBtn:SetPoint("TOPLEFT", kbFrame, "TOPLEFT", row3X - 40, -(KEY_H+5)*2)
    bsBtn:SetText("←")
    bsBtn:SetScript("OnClick", function()
        if #state.currentInput > 0 then
            state.currentInput = state.currentInput:sub(1, -2)
            updateCurrentRowDisplay()
        end
        InputBox:SetFocus()
    end)

    -- Hidden EditBox to capture keyboard input
    InputBox = CreateFrame("EditBox", "WoWdleInputBox", MainFrame)
    InputBox:SetSize(1,1)
    InputBox:SetPoint("BOTTOM", MainFrame, "BOTTOM", 0, 8)
    InputBox:SetAutoFocus(false)
    InputBox:SetMaxLetters(5)

    InputBox:SetScript("OnTextChanged", function(self)
        if state.won or state.lost then self:SetText(""); return end
        local txt = self:GetText():upper():gsub("[^A-Z]", "")
        if #txt > 5 then txt = txt:sub(1,5) end
        state.currentInput = txt
        self:SetText(txt)
        updateCurrentRowDisplay()
    end)

    InputBox:SetScript("OnEnterPressed", function()
        submitGuess()
        InputBox:SetFocus()
    end)

    InputBox:SetScript("OnKeyDown", function(self, key)
        if key == "BACKSPACE" then
            if #state.currentInput > 0 then
                state.currentInput = state.currentInput:sub(1, -2)
                self:SetText(state.currentInput)
                updateCurrentRowDisplay()
            end
        end
    end)

    -- New Game button
    local newGameBtn = CreateFrame("Button", nil, MainFrame, "UIPanelButtonTemplate")
    newGameBtn:SetSize(100, 24)
    newGameBtn:SetPoint("BOTTOM", MainFrame, "BOTTOM", 0, 30)
    newGameBtn:SetText("New Game")
    newGameBtn:SetScript("OnClick", startNewGame)

    MainFrame:SetScript("OnShow", function()
        InputBox:SetFocus()
    end)
end

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================
local function BuildMinimapButton()
    local btn = CreateFrame("Button", "WoWdleMinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)

    -- Position on minimap edge
    local angle = 45
    local function updatePos()
        local rad = math.rad(angle)
        local x = math.cos(rad) * 80
        local y = math.sin(rad) * 80
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
    updatePos()

    -- Icon
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetAllPoints()
    btn.icon:SetTexture("Interface\\Icons\\inv_inscription_scroll")

    -- Border
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.border:SetSize(56, 56)
    btn.border:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 12)

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
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Draggable around minimap
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx/scale, cy/scale
            angle = math.deg(math.atan2(cy - my, cx - mx))
            updatePos()
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================
SLASH_WOWDLE1 = "/wordle"
SLASH_WOWDLE2 = "/wowdle"
SlashCmdList["WOWDLE"] = function(msg)
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
    BuildUI()
    BuildMinimapButton()
    startNewGame()
    print("|cffffcc00WoWdle|r loaded! Type |cff00ccff/wordle|r or click the minimap button to play.")
end)
