-- RaidMarker Main File
RaidMarker = {}
RaidMarker.version = "1.0"

-- Helper function to safely hide frame (works in combat too)
local function SafeHideFrame(frame)
    if not InCombatLockdown() then
        frame:Hide()
    else
        -- During combat, make it invisible and non-interactive instead
        frame:SetAlpha(0)
        frame:EnableMouse(false)
    end
end

-- Helper function to safely show frame
local function SafeShowFrame(frame)
    if not InCombatLockdown() then
        frame:Show()
    else
        -- During combat, just make it visible and interactive
        frame:SetAlpha(1)
        frame:EnableMouse(true)
    end
end

-- Default settings
local defaults = {
    scale = 1.0,
    locked = false,
    showOnlyInGroup = false,
    showOnlyInDungeon = false,
    hideInCombat = false,
    position = {
        point = "CENTER",
        x = 0,
        y = 0,
    },
    keybindings = {
        star = "",
        circle = "",
        diamond = "",
        triangle = "",
        moon = "",
        square = "",
        cross = "",
        skull = "",
        remove = "",
    }
}

-- Initialize saved variables
function RaidMarker:InitDB()
    if not RaidMarkerDB then
        RaidMarkerDB = {}
    end
    for k, v in pairs(defaults) do
        if RaidMarkerDB[k] == nil then
            RaidMarkerDB[k] = v
        end
    end
end

-- Marker data
-- groundIndex = PlaceRaidMarker index, targetIndex = SetRaidTarget index
local markers = {
    {name = "Star", groundIndex = 5, targetIndex = 1, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"},
    {name = "Circle", groundIndex = 6, targetIndex = 2, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"},
    {name = "Diamond", groundIndex = 3, targetIndex = 3, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"},
    {name = "Triangle", groundIndex = 2, targetIndex = 4, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4"},
    {name = "Moon", groundIndex = 7, targetIndex = 5, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"},
    {name = "Square", groundIndex = 1, targetIndex = 6, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"},
    {name = "Cross", groundIndex = 4, targetIndex = 7, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"},
    {name = "Skull", groundIndex = 8, targetIndex = 8, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"},
}

-- Create main frame
local function CreateMainFrame()
    local frame = CreateFrame("Frame", "RaidMarkerFrame", UIParent)
    frame:SetWidth(430)
    frame:SetHeight(60)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")

    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints(frame)
    frame.bg:SetColorTexture(0, 0, 0, 0.8)

    -- Border
    frame.border = CreateFrame("Frame", nil, frame)
    frame.border:SetAllPoints(frame)
    frame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    frame.border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    -- Close button
    frame.closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeBtn:SetPoint("TOPRIGHT", -2, -2)
    frame.closeBtn:SetWidth(20)
    frame.closeBtn:SetHeight(20)
    frame.closeBtn:SetScript("OnClick", function()
        SafeHideFrame(RaidMarkerFrame)
    end)

    -- Make draggable
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not RaidMarkerDB.locked then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        RaidMarkerDB.position.point = point
        RaidMarkerDB.position.x = x
        RaidMarkerDB.position.y = y
    end)

    frame:Hide()
    return frame
end

-- Create marker button
local function CreateMarkerButton(parent, marker, col, row)
    local btn = CreateFrame("Button", "RaidMarkerBtn_"..marker.name, parent)
    btn:SetWidth(40)
    btn:SetHeight(40)
    btn:SetPoint("TOPLEFT", 10 + (col * 45), -10 - (row * 45))

    -- Icon
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints(btn)
    btn.icon:SetTexture(marker.icon)

    -- Highlight
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    btn:GetHighlightTexture():SetBlendMode("ADD")

    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(marker.name, 1, 1, 1)
        GameTooltip:AddLine("Left Click: Place on ground", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right Click: Set on target", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Click handlers
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            -- Place on ground
            PlaceRaidMarker(marker.groundIndex)
            print("|cff00ff00RaidMarker:|r Placed " .. marker.name .. " on ground")
        elseif button == "RightButton" then
            -- Set on target
            if UnitExists("target") then
                SetRaidTarget("target", marker.targetIndex)
                print("|cff00ff00RaidMarker:|r Set " .. marker.name .. " on target")
            else
                print("|cffff0000RaidMarker:|r No target selected")
            end
        end
    end)

    return btn
end

-- Create clear all button
local function CreateClearButton(parent)
    local btn = CreateFrame("Button", "RaidMarkerClearBtn", parent, "SecureActionButtonTemplate")
    btn:SetWidth(40)
    btn:SetHeight(40)
    btn:SetPoint("TOPLEFT", 10 + (8 * 45), -10)

    -- Icon (red X)
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints(btn)
    btn.icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    btn:GetHighlightTexture():SetBlendMode("ADD")

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Clear All", 1, 0.2, 0.2)
        GameTooltip:AddLine("Left Click: Clear all ground markers", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right Click: Clear target marker", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Configure secure attributes for left click (cast spell 499587)
    btn:SetAttribute("type1", "spell")
    btn:SetAttribute("spell1", 499587)

    -- Register clicks
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- PostClick handler for right click (clear all target markers)
    btn:SetScript("PostClick", function(self, button)
        if button == "RightButton" then
            -- Clear all target markers by setting them on player then removing
            for i = 1, 8 do
                SetRaidTarget("player", i)
                SetRaidTarget("player", 0)
            end
            print("|cff00ff00RaidMarker:|r Cleared all target markers")
        end
    end)

    return btn
end

-- Initialize addon
function RaidMarker:Initialize()
    self:InitDB()

    -- Create main frame
    local frame = CreateMainFrame()

    -- Create marker buttons (1 row, 8 columns)
    for i, marker in ipairs(markers) do
        local col = (i - 1)
        CreateMarkerButton(frame, marker, col, 0)
    end

    -- Create clear button
    CreateClearButton(frame)

    -- Apply saved settings
    frame:SetScale(RaidMarkerDB.scale)
    frame:ClearAllPoints()
    frame:SetPoint(RaidMarkerDB.position.point, UIParent, RaidMarkerDB.position.point,
                   RaidMarkerDB.position.x, RaidMarkerDB.position.y)

    print("|cff00ff00RaidMarker|r v" .. self.version .. " loaded. Type |cffff8800/rm|r to toggle.")
end

-- Check if player has group leader/assistant permissions (Classic compatible)
function RaidMarker:HasGroupPermissions()
    local numGroupMembers = GetNumGroupMembers()

    -- Solo player always has permission
    if numGroupMembers == 0 then
        return true
    end

    -- Check if in raid
    if IsInRaid() then
        -- In raid: must be leader or assistant
        if IsRaidLeader() or IsRaidOfficer() then
            return true
        end
        return false
    else
        -- In party: check if leader (Classic compatible way)
        -- In Classic, we check if we can assign roles (only leader can)
        -- For regular dungeon groups, all can place markers, so we only restrict in raids
        return true
    end
end

-- Check if frame should be shown based on settings
function RaidMarker:UpdateFrameVisibility()
    if not RaidMarkerFrame then return end

    -- Determine if we should show the frame
    local shouldShow = true

    -- Check if player has permission to use markers in a group
    if not self:HasGroupPermissions() then
        shouldShow = false
    end

    -- Check if we should hide in combat
    if shouldShow and RaidMarkerDB.hideInCombat and InCombatLockdown() then
        shouldShow = false
    end

    -- Check if we should only show in dungeon
    if shouldShow and RaidMarkerDB.showOnlyInDungeon then
        local inInstance, instanceType = IsInInstance()
        if not (inInstance and (instanceType == "party" or instanceType == "raid")) then
            shouldShow = false
        end
    end

    -- Check if we should only show in group
    if shouldShow and RaidMarkerDB.showOnlyInGroup then
        local inGroup = GetNumGroupMembers() > 0
        if not inGroup then
            shouldShow = false
        end
    end

    -- Apply visibility
    if shouldShow then
        SafeShowFrame(RaidMarkerFrame)
    else
        SafeHideFrame(RaidMarkerFrame)
    end
end

-- Slash commands
SLASH_RAIDMARKER1 = "/rm"
SLASH_RAIDMARKER2 = "/raidmarker"
SlashCmdList["RAIDMARKER"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "" or msg == "toggle" then
        if RaidMarkerFrame:IsShown() or (InCombatLockdown() and RaidMarkerFrame:GetAlpha() > 0) then
            SafeHideFrame(RaidMarkerFrame)
        else
            -- Check if any restrictive options are enabled
            if RaidMarkerDB.showOnlyInDungeon or RaidMarkerDB.showOnlyInGroup or RaidMarkerDB.hideInCombat then
                print("|cffff8800RaidMarker:|r Auto-show options are enabled. Use /rm options to change settings")
                return
            end
            SafeShowFrame(RaidMarkerFrame)
        end
    elseif msg == "options" or msg == "config" then
        RaidMarker_OpenOptions()
    elseif msg == "lock" then
        RaidMarkerDB.locked = true
        print("|cff00ff00RaidMarker:|r Frame locked")
    elseif msg == "unlock" then
        RaidMarkerDB.locked = false
        print("|cff00ff00RaidMarker:|r Frame unlocked")
    elseif msg:match("^scale") then
        local scale = tonumber(msg:match("scale%s+([%d%.]+)"))
        if scale and scale >= 0.5 and scale <= 2.0 then
            RaidMarkerDB.scale = scale
            RaidMarkerFrame:SetScale(scale)
            print("|cff00ff00RaidMarker:|r Scale set to " .. scale)
        else
            print("|cffff0000RaidMarker:|r Invalid scale. Use 0.5 to 2.0")
        end
    elseif msg == "reset" then
        RaidMarkerDB.position = defaults.position
        RaidMarkerDB.scale = defaults.scale
        RaidMarkerFrame:SetScale(defaults.scale)
        RaidMarkerFrame:ClearAllPoints()
        RaidMarkerFrame:SetPoint("CENTER", 0, 0)
        print("|cff00ff00RaidMarker:|r Position and scale reset")
    elseif msg == "help" then
        print("|cff00ff00RaidMarker Commands:|r")
        print("  /rm - Toggle marker window")
        print("  /rm options - Open options menu")
        print("  /rm lock - Lock frame position")
        print("  /rm unlock - Unlock frame position")
        print("  /rm scale [0.5-2.0] - Set frame scale")
        print("  /rm reset - Reset position and scale")
    else
        print("|cffff0000RaidMarker:|r Unknown command. Type /rm help for help")
    end
end

-- Event handler
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")  -- Entering combat
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Leaving combat
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")    -- Group changes
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- Zone/Instance changes
eventFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "RaidMarker" then
        RaidMarker:Initialize()
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat
        RaidMarker:UpdateFrameVisibility()
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leaving combat - restore proper Hide() state if needed
        if RaidMarkerFrame and RaidMarkerFrame:GetAlpha() == 0 then
            RaidMarkerFrame:Hide()
            RaidMarkerFrame:SetAlpha(1)
            RaidMarkerFrame:EnableMouse(true)
        end
        RaidMarker:UpdateFrameVisibility()
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Group changed
        RaidMarker:UpdateFrameVisibility()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Zone/Instance changed
        RaidMarker:UpdateFrameVisibility()
    end
end)
