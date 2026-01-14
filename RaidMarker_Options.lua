-- RaidMarker Options Panel

local optionsFrame = nil

function RaidMarker_OpenOptions()
    if not optionsFrame then
        optionsFrame = CreateFrame("Frame", "RaidMarkerOptions", UIParent)
        optionsFrame:SetWidth(480)
        optionsFrame:SetHeight(450)
        optionsFrame:SetPoint("CENTER", 0, 0)
        optionsFrame:SetMovable(true)
        optionsFrame:EnableMouse(true)
        optionsFrame:SetClampedToScreen(true)
        optionsFrame:SetFrameStrata("DIALOG")

        -- Background
        optionsFrame.bg = optionsFrame:CreateTexture(nil, "BACKGROUND")
        optionsFrame.bg:SetAllPoints(optionsFrame)
        optionsFrame.bg:SetColorTexture(0.05, 0.05, 0.05, 0.95)

        -- Border
        optionsFrame.border = CreateFrame("Frame", nil, optionsFrame)
        optionsFrame.border:SetAllPoints(optionsFrame)
        optionsFrame.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
        })
        optionsFrame.border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)

        -- Title
        optionsFrame.title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        optionsFrame.title:SetPoint("TOP", 0, -15)
        optionsFrame.title:SetText("|cff00ff00Raid Marker Options|r")

        -- Close button
        optionsFrame.closeBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
        optionsFrame.closeBtn:SetPoint("TOPRIGHT", -5, -5)
        optionsFrame.closeBtn:SetWidth(24)
        optionsFrame.closeBtn:SetHeight(24)
        optionsFrame.closeBtn:SetScript("OnClick", function()
            if not InCombatLockdown() then
                optionsFrame:Hide()
            else
                print("|cffff0000RaidMarker:|r Cannot close during combat")
            end
        end)

        -- Make draggable
        optionsFrame:RegisterForDrag("LeftButton")
        optionsFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        optionsFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)

        -- Scale section
        local scaleLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        scaleLabel:SetPoint("TOPLEFT", 20, -50)
        scaleLabel:SetText("Frame Scale:")

        local scaleSlider = CreateFrame("Slider", "RaidMarkerScaleSlider", optionsFrame, "OptionsSliderTemplate")
        scaleSlider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -10)
        scaleSlider:SetWidth(430)
        scaleSlider:SetMinMaxValues(0.5, 2.0)
        scaleSlider:SetValueStep(0.1)
        scaleSlider:SetValue(RaidMarkerDB.scale)
        getglobal(scaleSlider:GetName() .. 'Low'):SetText('0.5')
        getglobal(scaleSlider:GetName() .. 'High'):SetText('2.0')
        getglobal(scaleSlider:GetName() .. 'Text'):SetText('Scale: ' .. RaidMarkerDB.scale)

        scaleSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value * 10 + 0.5) / 10
            RaidMarkerDB.scale = value
            RaidMarkerFrame:SetScale(value)
            getglobal(self:GetName() .. 'Text'):SetText('Scale: ' .. value)
        end)

        -- Lock/Unlock section
        local lockLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lockLabel:SetPoint("TOPLEFT", 20, -120)
        lockLabel:SetText("Frame Lock:")

        local lockCheckbox = CreateFrame("CheckButton", "RaidMarkerLockCheck", optionsFrame, "UICheckButtonTemplate")
        lockCheckbox:SetPoint("LEFT", lockLabel, "RIGHT", 10, 0)
        lockCheckbox:SetWidth(24)
        lockCheckbox:SetHeight(24)
        lockCheckbox:SetChecked(RaidMarkerDB.locked)
        lockCheckbox:SetScript("OnClick", function(self)
            RaidMarkerDB.locked = self:GetChecked()
            if RaidMarkerDB.locked then
                print("|cff00ff00RaidMarker:|r Frame locked")
            else
                print("|cff00ff00RaidMarker:|r Frame unlocked")
            end
        end)

        local lockText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lockText:SetPoint("LEFT", lockCheckbox, "RIGHT", 5, 0)
        lockText:SetText("Lock frame position")

        -- Show only in group checkbox
        local groupCheckbox = CreateFrame("CheckButton", "RaidMarkerGroupCheck", optionsFrame, "UICheckButtonTemplate")
        groupCheckbox:SetPoint("TOPLEFT", lockLabel, "BOTTOMLEFT", 0, -10)
        groupCheckbox:SetWidth(24)
        groupCheckbox:SetHeight(24)
        groupCheckbox:SetChecked(RaidMarkerDB.showOnlyInGroup)
        groupCheckbox:SetScript("OnClick", function(self)
            RaidMarkerDB.showOnlyInGroup = self:GetChecked()
            RaidMarker:UpdateFrameVisibility()
            if RaidMarkerDB.showOnlyInGroup then
                print("|cff00ff00RaidMarker:|r Will only show in party/raid")
            else
                print("|cff00ff00RaidMarker:|r Will show everywhere")
            end
        end)

        local groupText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        groupText:SetPoint("LEFT", groupCheckbox, "RIGHT", 5, 0)
        groupText:SetText("Show only in Party / Raid")

        -- Show only in dungeon checkbox
        local dungeonCheckbox = CreateFrame("CheckButton", "RaidMarkerDungeonCheck", optionsFrame, "UICheckButtonTemplate")
        dungeonCheckbox:SetPoint("TOPLEFT", groupCheckbox, "BOTTOMLEFT", 0, -5)
        dungeonCheckbox:SetWidth(24)
        dungeonCheckbox:SetHeight(24)
        dungeonCheckbox:SetChecked(RaidMarkerDB.showOnlyInDungeon)
        dungeonCheckbox:SetScript("OnClick", function(self)
            RaidMarkerDB.showOnlyInDungeon = self:GetChecked()
            RaidMarker:UpdateFrameVisibility()
            if RaidMarkerDB.showOnlyInDungeon then
                print("|cff00ff00RaidMarker:|r Will only show in dungeons/raids")
            else
                print("|cff00ff00RaidMarker:|r Will show everywhere")
            end
        end)

        local dungeonText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dungeonText:SetPoint("LEFT", dungeonCheckbox, "RIGHT", 5, 0)
        dungeonText:SetText("Show only in Party / Raid [Dungeons]")

        -- Hide in combat checkbox
        local combatCheckbox = CreateFrame("CheckButton", "RaidMarkerCombatCheck", optionsFrame, "UICheckButtonTemplate")
        combatCheckbox:SetPoint("TOPLEFT", dungeonCheckbox, "BOTTOMLEFT", 0, -5)
        combatCheckbox:SetWidth(24)
        combatCheckbox:SetHeight(24)
        combatCheckbox:SetChecked(RaidMarkerDB.hideInCombat)
        combatCheckbox:SetScript("OnClick", function(self)
            RaidMarkerDB.hideInCombat = self:GetChecked()
            RaidMarker:UpdateFrameVisibility()
            if RaidMarkerDB.hideInCombat then
                print("|cff00ff00RaidMarker:|r Will hide in combat")
            else
                print("|cff00ff00RaidMarker:|r Will show in combat")
            end
        end)

        local combatText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        combatText:SetPoint("LEFT", combatCheckbox, "RIGHT", 5, 0)
        combatText:SetText("Hide in Combat")

        -- Info section
        local infoLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        infoLabel:SetPoint("TOPLEFT", 20, -250)
        infoLabel:SetText("How to use:")

        local infoText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        infoText:SetPoint("TOPLEFT", infoLabel, "BOTTOMLEFT", 0, -10)
        infoText:SetJustifyH("LEFT")
        infoText:SetWidth(360)
        infoText:SetText(
            "|cffffffff• Left Click:|r Place marker on ground\n" ..
            "|cffffffff• Right Click:|r Set marker on target\n" ..
            "|cffffffff• Shift+Click:|r Clear marker\n" ..
            "|cffffffff• Red X (Left):|r Clear all ground markers\n" ..
            "|cffffffff• Red X (Right):|r Clear target marker\n\n" ..
            "|cffffaa00Commands:|r\n" ..
            "|cffffffff/rm|r - Toggle marker window\n" ..
            "|cffffffff/rm options|r - Open this window\n" ..
            "|cffffffff/rm lock/unlock|r - Lock/unlock frame\n" ..
            "|cffffffff/rm scale [0.5-2.0]|r - Set scale\n" ..
            "|cffffffff/rm reset|r - Reset position"
        )

        -- Reset button
        local resetBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
        resetBtn:SetPoint("BOTTOM", 0, 15)
        resetBtn:SetWidth(120)
        resetBtn:SetHeight(25)
        resetBtn:SetText("Reset Position")
        resetBtn:SetScript("OnClick", function()
            RaidMarkerDB.position = {point = "CENTER", x = 0, y = 0}
            RaidMarkerDB.scale = 1.0
            RaidMarkerFrame:SetScale(1.0)
            RaidMarkerFrame:ClearAllPoints()
            RaidMarkerFrame:SetPoint("CENTER", 0, 0)
            scaleSlider:SetValue(1.0)
            print("|cff00ff00RaidMarker:|r Position and scale reset")
        end)

        optionsFrame:Hide()
    end

    if InCombatLockdown() then
        print("|cffff0000RaidMarker:|r Cannot open/close options during combat")
        return
    end

    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end
