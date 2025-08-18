local PCL, PCLcore = ...;

local PCL_Load = PCLcore.Main;

PCLcore.Frames = {};
local PCL_frames = PCLcore.Frames;

PCLcore.TabTable = {}
PCLcore.statusBarFrames  = {}

PCLcore.nav_width = 180
local nav_width = PCLcore.nav_width
-- Updated default main frame size (content area wider)
local main_frame_width = 800  -- default width
local main_frame_height = 600 -- default height

local r,g,b,a

-- Helper function to get localization safely
local function L(key)
    if PCLcore.L then
        return PCLcore.L[key] or key
    end
    return key
end

-- Helper function to style navigation buttons for both themes
local function StyleNavButton(button, isExpansionIcon)
    if not button then return end
    
    if PCL_SETTINGS.useBlizzardTheme then
        -- Blizzard theme styling with authentic textures
        if isExpansionIcon then
            -- Expansion icons get a Blizzard-style button frame
            button:SetBackdrop({
                bgFile = "Interface\\Buttons\\UI-Panel-Button-Up", 
                edgeFile = "Interface\\Buttons\\UI-Panel-Button-Border", 
                edgeSize = 8,
                insets = {left = 2, right = 2, top = 2, bottom = 2}
            })
            button:SetBackdropColor(0.9, 0.9, 1, 0.4)  -- Light blue-white background
            button:SetBackdropBorderColor(0.7, 0.7, 0.9, 1)  -- Blue border
        else
            -- Regular navigation buttons get Blizzard panel styling
            button:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
                edgeSize = 16,
                insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            button:SetBackdropColor(0.05, 0.05, 0.2, 0.9)  -- Dark blue background
            button:SetBackdropBorderColor(0.6, 0.6, 0.8, 1)  -- Blue-gray border
        end
        
        -- Blizzard-style text color
        if button.text then
            button.text:SetTextColor(1, 0.82, 0, 1)  -- Gold text
        end
    else
        -- Default theme styling (current)
        button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
        button:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
        button:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        
        if button.text then
            button.text:SetTextColor(1, 1, 1, 1)  -- White text
        end
    end
end

-- Function to update progress bar colors based on collection percentage
local function UpdateProgressBar(pBar, totalItems, collectedItems)
    if not pBar or not totalItems or not collectedItems then
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("UpdateProgressBar: Missing parameters", pBar and "pBar OK" or "pBar missing", totalItems and ("total=" .. totalItems) or "total missing", collectedItems and ("collected=" .. collectedItems) or "collected missing")
        end
        return
    end
    
    -- Ensure the progress bar has proper min/max values
    pBar:SetMinMaxValues(0, 100)
    
    if totalItems > 0 then
        local percentage = (collectedItems / totalItems) * 100
        
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("UpdateProgressBar: Setting progress bar", "total=" .. totalItems, "collected=" .. collectedItems, "percentage=" .. math.floor(percentage))
            print("  - Before SetValue: current value =", pBar:GetValue(), "min/max =", pBar:GetMinMaxValues())
        end
        
        -- Set the progress bar value (fill amount)
        pBar:SetValue(percentage)
        
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("  - After SetValue: current value =", pBar:GetValue())
        end
        
        -- Set the progress bar color based on percentage
        if percentage < 33 then
            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.low.r, PCL_SETTINGS.progressColors.low.g, PCL_SETTINGS.progressColors.low.b)
        elseif percentage < 66 then
            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.medium.r, PCL_SETTINGS.progressColors.medium.g, PCL_SETTINGS.progressColors.medium.b)
        elseif percentage < 100 then
            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.high.r, PCL_SETTINGS.progressColors.high.g, PCL_SETTINGS.progressColors.high.b)
        else
            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.complete.r, PCL_SETTINGS.progressColors.complete.g, PCL_SETTINGS.progressColors.complete.b)
        end
        
        -- Update text if it exists
        if pBar.Text then
            pBar.Text:SetText(string.format("%d/%d (%d%%)", collectedItems, totalItems, math.floor(percentage)))
        end
    else
        pBar:SetValue(0)
        pBar:SetStatusBarColor(0.5, 0.5, 0.5)  -- Gray for no data
        if pBar.Text then
            pBar.Text:SetText("0/0 (0%)")
        end
        
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("UpdateProgressBar: No data, setting to 0")
        end
    end
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 50);
	
	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end
	
	self:SetVerticalScroll(newValue);
end

-- Persist and restore main frame size
function PCL_frames:SaveFrameSize()
    if not PCL_mainFrame or not PCL_SETTINGS then return end
    PCL_SETTINGS.frameSize = PCL_SETTINGS.frameSize or {}
    local w, h = PCL_mainFrame:GetSize()
    -- Clamp to sane minimums
    if w < 600 then w = 600 end
    if h < 400 then h = 400 end
    PCL_SETTINGS.frameSize.width = w
    PCL_SETTINGS.frameSize.height = h
end

function PCL_frames:RestoreFrameSize()
    if not PCL_mainFrame or not PCL_SETTINGS then return end
    local s = PCL_SETTINGS.frameSize
    if s and s.width and s.height then
        PCL_mainFrame:SetSize(s.width, s.height)
    else
        -- Ensure default size is applied (in case other code changed before)
        PCL_mainFrame:SetSize(main_frame_width, main_frame_height)
    end
    if PCLcore.PCL_MF_Nav and PCL_mainFrame then
        local _, h = PCL_mainFrame:GetSize()
        PCLcore.PCL_MF_Nav:SetHeight(h + 1)
    end
end

-- Rebuild layout after size/theme changes
function PCL_frames:RefreshLayout()
    -- Don't refresh layout during combat or restricted situations to avoid protected function errors
    if InCombatLockdown() then
        return
    end
    
    if not PCL_mainFrame then return end
    -- Adjust nav height
    if PCLcore.PCL_MF_Nav then
        local _, h = PCL_mainFrame:GetSize()
        PCLcore.PCL_MF_Nav:SetHeight(h + 1)
    end
    -- Resize PetCard to match main window height
    if PCLcore.PetCard and PCLcore.PetCard.ResizePetCard then
        PCLcore.PetCard:ResizePetCard()
    end
    -- Remember currently selected tab name
    local currentName = nil
    if PCLcore.currentlySelectedTab and PCLcore.currentlySelectedTab.section then
        currentName = PCLcore.currentlySelectedTab.section.name
    end
    -- Rebuild tabs/content widths
    PCL_frames:SetTabs()
    -- Reselect previous tab if possible (fallback to Overview handled in SetTabs)
    if currentName then
        if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
            for _, tab in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                if tab.section and tab.section.name == currentName and tab:GetScript("OnClick") then
                    tab:GetScript("OnClick")(tab)
                    break
                end
            end
        end
    end
end

function PCL_frames:CreateMainFrame()
    local frameTemplate = PCL_SETTINGS.useBlizzardTheme and "PCLBlizzardFrameTemplate" or "PCLFrameTemplateWithInset"
    PCL_mainFrame = CreateFrame("Frame", "PCLFrame", UIParent, frameTemplate);
    -- Ensure initial default size BEFORE restore so restore can override
    PCL_mainFrame:SetSize(main_frame_width, main_frame_height)
    if PCL_SETTINGS.useBlizzardTheme then
        if PCL_mainFrame.NineSlice then PCL_mainFrame.NineSlice:Hide() end
        if PCL_mainFrame.PCLFrameTopLeft then PCL_mainFrame.PCLFrameTopLeft:Hide() end
        if PCL_mainFrame.PCLFrameTopRight then PCL_mainFrame.PCLFrameTopRight:Hide() end
        if PCL_mainFrame.PCLFrameBottomLeft then PCL_mainFrame.PCLFrameBottomLeft:Hide() end
        if PCL_mainFrame.PCLFrameBottomRight then PCL_mainFrame.PCLFrameBottomRight:Hide() end
        if PCL_mainFrame.PCLFrameTop then PCL_mainFrame.PCLFrameTop:Hide() end
        if PCL_mainFrame.PCLFrameBottom then PCL_mainFrame.PCLFrameBottom:Hide() end
        if PCL_mainFrame.PCLFrameLeft then PCL_mainFrame.PCLFrameLeft:Hide() end
        if PCL_mainFrame.PCLFrameRight then PCL_mainFrame.PCLFrameRight:Hide() end
    end
    if not PCL_SETTINGS.useBlizzardTheme then
        if PCL_mainFrame.Bg then
            PCL_mainFrame.Bg:SetVertexColor(0,0,0,PCL_SETTINGS.opacity)
        end
        if PCL_mainFrame.TitleBg then
            PCL_mainFrame.TitleBg:SetVertexColor(0.1,0.1,0.1,0.95)
        end
    end
    PCL_mainFrame:Show()
    
    -- Create the main frame title
    PCL_mainFrame.title = PCL_mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    
    -- Settings button
    PCL_mainFrame.settings = CreateFrame("Button", nil, PCL_mainFrame);
    PCL_mainFrame.settings:SetSize(14, 14)
    if PCL_SETTINGS.useBlizzardTheme then
        PCL_mainFrame.settings:SetPoint("TOPRIGHT", PCL_mainFrame, "TOPRIGHT", -40, -8)
    else
        PCL_mainFrame.settings:SetPoint("TOPRIGHT", PCL_mainFrame, "TOPRIGHT", -30, 0)
    end
    PCL_mainFrame.settings.tex = PCL_mainFrame.settings:CreateTexture()
    PCL_mainFrame.settings.tex:SetAllPoints(PCL_mainFrame.settings)
    PCL_mainFrame.settings.tex:SetTexture("Interface\\AddOns\\PCL\\icons\\settings.blp")
    PCL_mainFrame.settings:SetScript("OnClick", function()PCL_frames:openSettings()end)

    -- Refresh button
    PCL_mainFrame.refresh = CreateFrame("Button", nil, PCL_mainFrame);
    PCL_mainFrame.refresh:SetSize(14, 14)
    if PCL_SETTINGS.useBlizzardTheme then
        PCL_mainFrame.refresh:SetPoint("TOPRIGHT", PCL_mainFrame.settings, "TOPLEFT", -5, 0)
    else
        PCL_mainFrame.refresh:SetPoint("TOPRIGHT", PCL_mainFrame.settings, "TOPLEFT", -5, 0)
    end
    PCL_mainFrame.refresh.tex = PCL_mainFrame.refresh:CreateTexture()
    PCL_mainFrame.refresh.tex:SetAllPoints(PCL_mainFrame.refresh)
    PCL_mainFrame.refresh.tex:SetTexture("Interface\\Buttons\\UI-RefreshButton")
    PCL_mainFrame.refresh:SetScript("OnClick", function()
        if PCL_frames and PCL_frames.RefreshLayout then
            PCL_frames:RefreshLayout()
        end
    end)
    
    -- Add tooltip for refresh button
    PCL_mainFrame.refresh:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Refresh Layout", 1, 1, 1)
        GameTooltip:AddLine("Refreshes the mount collection display", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    PCL_mainFrame.refresh:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- SA button
    PCL_mainFrame.sa = CreateFrame("Button", nil, PCL_mainFrame);
    PCL_mainFrame.sa:SetSize(60, 15)
    if PCL_SETTINGS.useBlizzardTheme then
        PCL_mainFrame.sa:SetPoint("TOPRIGHT", PCL_mainFrame, "TOPRIGHT", -80, -8)
    else
        PCL_mainFrame.sa:SetPoint("TOPRIGHT", PCL_mainFrame, "TOPRIGHT", -80, -1)
    end
    PCL_mainFrame.sa.tex = PCL_mainFrame.sa:CreateTexture()
    PCL_mainFrame.sa.tex:SetAllPoints(PCL_mainFrame.sa)
    PCL_mainFrame.sa.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    PCL_mainFrame.sa.tex:SetVertexColor(0.1,0.1,0.1,0.95, PCL_SETTINGS.opacity)
    PCL_mainFrame.sa.text = PCL_mainFrame.sa:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    PCL_mainFrame.sa.text:SetPoint("CENTER", PCL_mainFrame.sa, "CENTER", 0, 0);
    PCL_mainFrame.sa.text:SetText("SA")
    -- Use Purple color for SA button
    PCL_mainFrame.sa.text:SetTextColor(0.6, 0.2, 0.8, 1)
    PCL_mainFrame.sa:SetScript("OnClick", function()PCLcore.Function:simplearmoryLink()end)

    -- DFA button
    PCL_mainFrame.dfa = CreateFrame("Button", nil, PCL_mainFrame);
    PCL_mainFrame.dfa:SetSize(60, 15)
    if PCL_SETTINGS.useBlizzardTheme then
        PCL_mainFrame.dfa:SetPoint("TOPRIGHT", PCL_mainFrame, "TOPRIGHT", -125, -8)
    else
        PCL_mainFrame.dfa:SetPoint("TOPRIGHT", PCL_mainFrame, "TOPRIGHT", -125, -1)
    end
    PCL_mainFrame.dfa.tex = PCL_mainFrame.dfa:CreateTexture()
    PCL_mainFrame.dfa.tex:SetAllPoints(PCL_mainFrame.dfa)
    PCL_mainFrame.dfa.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    PCL_mainFrame.dfa.tex:SetVertexColor(0.1,0.1,0.1,0.95, PCL_SETTINGS.opacity)
    PCL_mainFrame.dfa.text = PCL_mainFrame.dfa:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    PCL_mainFrame.dfa.text:SetPoint("CENTER", PCL_mainFrame.dfa, "CENTER", 0, 0);
    PCL_mainFrame.dfa.text:SetText("DFA")
    -- Use purple color for DFA button
    PCL_mainFrame.dfa.text:SetTextColor(0.6, 0.2, 0.8, 1)	
    PCL_mainFrame.dfa:SetScript("OnClick", function()PCLcore.Function:dfaLink()end)


	--PCL Frame settings
	PCL_mainFrame:SetSize(main_frame_width, main_frame_height); -- width, height (reset once more in case template changed it)
	PCL_mainFrame:SetPoint("CENTER", UIParent, "CENTER"); -- point, relativeFrame, relativePoint, xOffset, yOffset
	PCL_mainFrame:SetHyperlinksEnabled(true)
	PCL_mainFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
	
	-- Restore saved frame size if available
	PCL_frames:RestoreFrameSize()

	PCL_mainFrame:SetMovable(true)
	PCL_mainFrame:EnableMouse(true)
	PCL_mainFrame:RegisterForDrag("LeftButton")
	PCL_mainFrame:SetScript("OnDragStart", PCL_mainFrame.StartMoving)
	PCL_mainFrame:SetScript("OnDragStop", PCL_mainFrame.StopMovingOrSizing)
	
	-- Make frame resizable
	PCL_mainFrame:SetResizable(true)
	PCL_mainFrame:SetResizeBounds(600, 400, 1600, 1000)  -- updated min size
	
	-- Create resize grip
	PCL_mainFrame.resizeGrip = CreateFrame("Button", nil, PCL_mainFrame)
	PCL_mainFrame.resizeGrip:SetSize(16, 16)
	PCL_mainFrame.resizeGrip:SetPoint("BOTTOMRIGHT", PCL_mainFrame, "BOTTOMRIGHT", -2, 2)
	PCL_mainFrame.resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	PCL_mainFrame.resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	PCL_mainFrame.resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	PCL_mainFrame.resizeGrip:SetScript("OnMouseDown", function(self)
		PCL_mainFrame:StartSizing("BOTTOMRIGHT")
	end)
	PCL_mainFrame.resizeGrip:SetScript("OnMouseUp", function(self)
		PCL_mainFrame:StopMovingOrSizing()
		-- Save the new size and trigger layout update after resize
		PCL_frames:SaveFrameSize()
		PCL_frames:RefreshLayout()
	end)
	
	-- Add resize event handler to continuously update PetCard during resize
	PCL_mainFrame:SetScript("OnSizeChanged", function(self, width, height)
		-- Resize PetCard immediately when main frame size changes
		if PCLcore.PetCard and PCLcore.PetCard.ResizePetCard then
			PCLcore.PetCard:ResizePetCard()
			
			-- Also schedule a delayed resize to handle timing issues
			C_Timer.After(0.1, function()
				if PCLcore.PetCard and PCLcore.PetCard.ResizePetCard then
					PCLcore.PetCard:ResizePetCard()
				end
			end)
		end
		-- Also update nav frame height
		if PCLcore.PCL_MF_Nav then
			PCLcore.PCL_MF_Nav:SetHeight(height + 1)
		end
	end)    

	-- Move title to top center
    if PCL_mainFrame.title then
        PCL_mainFrame.title:ClearAllPoints()
		-- if blizzard theme
		if PCL_SETTINGS.useBlizzardTheme then
			PCL_mainFrame.title:SetPoint("TOPLEFT", PCL_mainFrame, "TOPLEFT", 10, -8)  -- Moved down 10px from the very top
		else
			PCL_mainFrame.title:SetPoint("TOPLEFT", PCL_mainFrame, "TOPLEFT", 10, -2)  -- Moved down 5px from the very top
		end
        PCL_mainFrame.title:SetText(L("Pet Collection Log"))
        -- Use Purple colour
        PCL_mainFrame.title:SetTextColor(0.6, 0.2, 0.8, 1)  -- Purple color
    end
    
    -- Scroll Frame for Main Window
	PCL_mainFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, PCL_mainFrame, "MinimalScrollFrameTemplate");
	-- Anchor scroll frame to the main frame, not Bg
    PCL_mainFrame.ScrollFrame:ClearAllPoints()
    PCL_mainFrame.ScrollFrame:SetPoint("TOPLEFT", PCL_mainFrame, "TOPLEFT", 10, -40)
    PCL_mainFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", PCL_mainFrame, "BOTTOMRIGHT", -10, 10)
	PCL_mainFrame.ScrollFrame:SetClipsChildren(true);
	PCL_mainFrame.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
	PCL_mainFrame.ScrollFrame:EnableMouse(true)
    
	PCL_mainFrame.ScrollFrame.ScrollBar:ClearAllPoints();
	PCL_mainFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", PCL_mainFrame.ScrollFrame, "TOPRIGHT", -8, -19);
	PCL_mainFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", PCL_mainFrame.ScrollFrame, "BOTTOMRIGHT", -8, 17);

    -- Create and assign a dedicated scroll child frame
    if not PCL_mainFrame.ScrollChild then
        PCL_mainFrame.ScrollChild = CreateFrame("Frame", nil, PCL_mainFrame.ScrollFrame)
        PCL_mainFrame.ScrollChild:SetSize(main_frame_width, main_frame_height)
        PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
    end

	PCL_mainFrame:SetFrameStrata("HIGH")
    if not PCL_SETTINGS.useBlizzardTheme then
        if PCLcore.Function and PCLcore.Function.CreateFullBorder then
            PCLcore.Function:CreateFullBorder(PCL_mainFrame)
        end
    end

    tinsert(UISpecialFrames, "PCLFrame")
    
    -- Add OnShow handler to show navigation when main frame is shown
    PCL_mainFrame:SetScript("OnShow", function()
        if PCLcore.PCL_MF_Nav then
            PCLcore.PCL_MF_Nav:Show()
        end
        
        -- Don't refresh layout during combat or restricted situations to avoid protected function errors
        if InCombatLockdown() then
            return
        end
        
        -- Refresh layout when opening the main window to ensure everything is up to date
        -- Check if overview content is ready first, defer if not
        if PCLcore.overviewFrames and #PCLcore.overviewFrames > 0 and PCLcore.stats then
            -- Overview frames exist and stats are available, refresh immediately
            if PCL_frames and PCL_frames.RefreshLayout then
                PCL_frames:RefreshLayout()
            end
        else
            -- Overview content not ready yet, defer the refresh
            C_Timer.After(1.5, function()
                -- Check again for combat when the timer fires
                if not InCombatLockdown() and PCL_frames and PCL_frames.RefreshLayout then
                    PCL_frames:RefreshLayout()
                end
            end)
        end
    end)
    
    -- Add OnHide handler to hide navigation when main frame is closed
    PCL_mainFrame:SetScript("OnHide", function()
        if PCLcore.PCL_MF_Nav then
            PCLcore.PCL_MF_Nav:Hide()
        end
        -- Also hide the pet card when main window is closed
        if PCLcore.PetCard and PCLcore.PetCard.Hide then
            PCLcore.PetCard:Hide()
        end
    end)
    
    -- Create the navigation frame
    if not PCLcore.PCL_MF_Nav then
        PCLcore.PCL_MF_Nav = PCL_frames:createNavFrame(PCL_mainFrame, L("Pet Collection Log"))
    end
    
    PCL_frames:RefreshLayout()
    return PCL_mainFrame
end


local function Tab_OnClick(self)
	-- Check if we need to refresh layout when switching away from pinned section
	if PCLcore.Function and PCLcore.Function.CheckAndRefreshAfterPinnedChanges then
		local newSectionName = self.section and self.section.name or "Unknown"
		PCLcore.Function:CheckAndRefreshAfterPinnedChanges(newSectionName)
	end
	
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = PCL_mainFrame.ScrollFrame:GetScrollChild();
	if(scrollChild) then
		scrollChild:Hide();
	end

	PCL_mainFrame.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
	PCL_mainFrame.ScrollFrame:SetVerticalScroll(0);
end


-- Build a nav-ordered list of sections for consistent tab/content mapping
function PCLcore:BuildSectionsOrdered()
    local pinned, overview, expansions, others = nil, nil, {}, {}
    local playerFaction = UnitFactionGroup("player")
    local isClassic = false  -- Default to false if Function module not available
    
    -- Safely check if Function module is available
    if PCLcore.Function and PCLcore.Function.IsClassicWoW then
        isClassic = PCLcore.Function:IsClassicWoW()
    end
    
    for i = 1, #PCLcore.sectionNames do
        local v = PCLcore.sectionNames[i]
        
        -- Skip sections not compatible with Classic if we're on Classic
        if isClassic and v.includeInClassic == false then
            -- skip sections not available in Classic
        elseif v.name == "Pinned" then
            pinned = v
        elseif v.name == "Horde" and playerFaction == "Alliance" then
            -- skip Horde for Alliance players
        elseif v.name == "Alliance" and playerFaction == "Horde" then
            -- skip Alliance for Horde players
        elseif v.name == "Overview" then
            overview = v
        elseif v.isExpansion then
            table.insert(expansions, v)
        else
            table.insert(others, v)
        end
    end
    local ordered = {}
    if overview then table.insert(ordered, overview) end
    for _, v in ipairs(expansions) do table.insert(ordered, v) end
    for _, v in ipairs(others) do table.insert(ordered, v) end
    if pinned then table.insert(ordered, pinned) end
    PCLcore.sectionsOrdered = ordered
end

function PCL_frames:SetTabs()
    -- Always update stats before building tabs/UI
    if PCLcore.Function and PCLcore.Function.UpdateCollection then
        PCLcore.Function:UpdateCollection()
    end
    if PCLcore.BuildSectionsOrdered then
        PCLcore:BuildSectionsOrdered()
    end
    -- Remove direct stats calculation during initialization to prevent timeout
    -- Stats will be calculated later via UpdateCollection's deferred mechanism
    -- if PCLcore.Function and PCLcore.Function.CalculateSectionStats then
    --     PCLcore.Function:CalculateSectionStats()
    -- end
    
    -- Refresh overview stats after calculation
    if PCLcore.overviewFrames then
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("Refreshing overview stats for", #PCLcore.overviewFrames, "frames")
        end
        for _, overviewFrame in ipairs(PCLcore.overviewFrames) do
            local sectionName = overviewFrame.name
            local pBar = overviewFrame.frame
            local sectionStats = PCLcore.stats and PCLcore.stats[sectionName]
            
            if PCL_SETTINGS and PCL_SETTINGS.debug then
                print("Checking section:", sectionName, "stats available:", sectionStats and "yes" or "no")
                if sectionStats then
                    print("  - collected:", sectionStats.collected, "total:", sectionStats.total)
                end
            end
            
            if sectionStats and sectionStats.collected and sectionStats.total then
                UpdateProgressBar(pBar, sectionStats.total, sectionStats.collected)
            end
        end
    else
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("No overview frames to refresh")
        end
    end

    local tabFrame
    if PCL_SETTINGS.useBlizzardTheme then
        -- Blizzard theme should ALSO use the separate navigation frame
        tabFrame = PCLcore.PCL_MF_Nav
    else
        tabFrame = PCLcore.PCL_MF_Nav
    end

    -- Ensure navigation frame exists before proceeding
    if not tabFrame then
        if PCL_SETTINGS and PCL_SETTINGS.debug then
            print("PCL: Navigation frame not found, creating it now")
        end
        PCLcore.PCL_MF_Nav = PCL_frames:createNavFrame(PCL_mainFrame, L("Pet Collection Log"))
        tabFrame = PCLcore.PCL_MF_Nav
    end

    -- Store reference for overview navigation
    if not tabFrame.tabs then
        tabFrame.tabs = {}
    end

    local sections = PCLcore.sectionsOrdered or PCLcore.sections
    -- Find Overview, Pinned, expansions, and others
    local overviewSection, pinnedSection, expansionSections, otherSections = nil, nil, {}, {}
    for _, v in ipairs(sections) do
        if v.name == "Overview" then
            overviewSection = v
        elseif v.name == "Pinned" then
            pinnedSection = v
        elseif v.isExpansion then
            table.insert(expansionSections, v)
        else
            table.insert(otherSections, v)
        end
    end

    if tabFrame.tabs then
        for _, tab in ipairs(tabFrame.tabs) do
            tab:Hide()
            if tab.content then tab.content:Hide() end
        end
    end
    tabFrame.tabs = {}
    PCLcore.sectionFrames = {}

    local navYOffset = -55  -- Adjusted to account for search bar
    local tabIndex = 1
    local selectedTab = nil

    local function HideAllTabContents()
        -- Hide all tab content frames
        for _, t in ipairs(tabFrame.tabs) do
            if t.content then 
                t.content:Hide() 
            end
        end
        
        -- Hide all section frames that might be stored globally
        if PCLcore.sectionFrames then
            for _, contentFrame in ipairs(PCLcore.sectionFrames) do
                if contentFrame and contentFrame.Hide then
                    contentFrame:Hide()
                end
            end
        end
        
        -- Hide overview frame specifically
        if PCLcore.overview then
            PCLcore.overview:Hide()
        end
        
        -- Also properly destroy search results content if it exists
        if PCLcore.Search and PCLcore.Search.DestroySearchResultsFrame then
            PCLcore.Search:DestroySearchResultsFrame()
        end
    end
    
    -- Expose HideAllTabContents globally for access from other files
    PCLcore.HideAllTabContents = HideAllTabContents
    local function DeselectAllTabs()
        for _, t in ipairs(tabFrame.tabs) do
            t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end
    local function SelectTab(tab)
        -- Check if we need to refresh layout when switching away from pinned section
        if PCLcore.Function and PCLcore.Function.CheckAndRefreshAfterPinnedChanges then
            local newSectionName = tab.section and tab.section.name or "Unknown"
            PCLcore.Function:CheckAndRefreshAfterPinnedChanges(newSectionName)
        end
        
        DeselectAllTabs()
        HideAllTabContents()
        
        -- Clear any active search when switching tabs manually
        if PCLcore.Search and PCLcore.Search.isSearchActive then
            -- Clear search state without restoring previous tab
            PCLcore.Search.currentSearchTerm = ""
            PCLcore.Search.isSearchActive = false
            PCLcore.Search.searchResults = {}
            
            -- Clear any highlighting
            if PCLcore.Search.ClearHighlighting then
                PCLcore.Search:ClearHighlighting()
            end
            
            -- Properly destroy search results content frame
            if PCLcore.Search.DestroySearchResultsFrame then
                PCLcore.Search:DestroySearchResultsFrame()
            end
            
            -- Clear search box text
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.searchBox then
                PCLcore.PCL_MF_Nav.searchBox:SetText("")
                if PCLcore.PCL_MF_Nav.searchPlaceholder then
                    PCLcore.PCL_MF_Nav.searchPlaceholder:Show()
                end
            end
            
            -- Clear the previously selected tab reference
            PCLcore.Search.previouslySelectedTab = nil
        end
        
        tab:SetBackdropBorderColor(1, 0.82, 0, 1)
        
        -- Always ensure the main scroll child is the scroll child
        if PCL_mainFrame.ScrollChild then
            PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
        end
        
        -- Show only the selected tab's content
        if tab.content then
            tab.content:Show()
        end
        
        PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
        -- Store the currently selected tab globally for search functionality
        PCLcore.currentlySelectedTab = tab
    end

    -- 1. Overview tab (always first)
    if overviewSection then
        local tab = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
        tab:SetSize(nav_width + 8, 32)  -- Use nav width for sidebar tabs
        tab:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 1, navYOffset)
        StyleNavButton(tab, false)  -- Use our styling function
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tab.text:SetPoint("LEFT", 10, 0)
        tab.text:SetText(L(overviewSection.name) or overviewSection.name)
        tab.section = overviewSection
        
        -- Create content frame for overview
        if not PCLcore.overview then
            PCLcore.overview = PCL_frames:createContentFrame(PCL_mainFrame.ScrollChild, overviewSection.name)
        end
        tab.content = PCLcore.overview
        
        -- Populate overview content
        if PCLcore.sections and PCL_frames.createOverviewCategory then
            PCL_frames:createOverviewCategory(PCLcore.sections, PCLcore.overview)
            
            -- Immediately refresh overview progress bars after creation
            if PCLcore.overviewFrames then
                if PCL_SETTINGS and PCL_SETTINGS.debug then
                    print("Immediately refreshing overview stats after creation for", #PCLcore.overviewFrames, "frames")
                end
                for _, overviewFrame in ipairs(PCLcore.overviewFrames) do
                    local sectionName = overviewFrame.name
                    local pBar = overviewFrame.frame
                    local sectionStats = PCLcore.stats and PCLcore.stats[sectionName]
                    
                    if PCL_SETTINGS and PCL_SETTINGS.debug then
                        print("Immediate refresh - section:", sectionName, "stats available:", sectionStats and "yes" or "no")
                        if sectionStats then
                            print("  - collected:", sectionStats.collected, "total:", sectionStats.total)
                        end
                    end
                    
                    if sectionStats and sectionStats.collected and sectionStats.total then
                        UpdateProgressBar(pBar, sectionStats.total, sectionStats.collected)
                    end
                end
            end
        end
        
        if tab.content then tab.content:Hide() end
        tab:SetScript("OnClick", function(self)
            SelectTab(self)
        end)
        tab:EnableMouse(true)
        tab:SetFrameStrata("HIGH")
        tab:SetFrameLevel(100)
        tab:Show()
        table.insert(tabFrame.tabs, tab)
        -- Also store in navigation frame for overview navigation
        if PCLcore.PCL_MF_Nav and not PCLcore.PCL_MF_Nav.tabs then
            PCLcore.PCL_MF_Nav.tabs = {}
        end
        if PCLcore.PCL_MF_Nav then
            table.insert(PCLcore.PCL_MF_Nav.tabs, tab)
        end
        table.insert(PCLcore.sectionFrames, tab.content)
        tabIndex = tabIndex + 1
        navYOffset = navYOffset - 36
        selectedTab = tab
        -- Store globally for search functionality
        PCLcore.currentlySelectedTab = tab
    end
    -- 2. Expansion grid (icon-only, 3 per row)
    local gridCols, iconSize, iconPad = 3, 36, 8
    local gridStartY = navYOffset - 10  -- Add spacing between Overview and expansion grid
    
    -- Calculate centering for expansion icons within the nav sidebar
    local totalGridWidth = gridCols * iconSize + (gridCols - 1) * iconPad
    local navFrameWidth = nav_width + 10  -- Use the nav frame width
    local gridStartX = math.floor((navFrameWidth - totalGridWidth) / 2) + 1  -- Center within nav frame, add 1px offset for better alignment
    
    for i, v in ipairs(expansionSections) do
        local col = ((i-1) % gridCols)
        local row = math.floor((i-1) / gridCols)
        local btn = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
        btn:SetSize(iconSize, iconSize)
        btn:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", gridStartX + col * (iconSize + iconPad), gridStartY - row * (iconSize + iconPad))
        StyleNavButton(btn, true)  -- Use our styling function for expansion icons
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetAllPoints(btn)
        btn.icon:SetTexture(v.icon)
        btn.section = v
        btn.content = PCL_frames:createContentFrame(PCL_mainFrame.ScrollChild, v.name)
        -- Populate expansion tab content
        if v.pets and v.pets.categories then
            if v.pets.categories.categories then
                PCL_frames:createCategoryFrame(v.pets.categories.categories, btn.content, v.name)
            else
                PCL_frames:createCategoryFrame(v.pets.categories, btn.content, v.name)
            end
        end
        btn.content:Hide()
        btn:SetScript("OnClick", function(self)
            SelectTab(self)
        end)
        btn:EnableMouse(true)
        btn:SetFrameStrata("HIGH")
        btn:SetFrameLevel(100)
        btn:Show()
        table.insert(tabFrame.tabs, btn)
        -- Also store in navigation frame for overview navigation
        if PCLcore.PCL_MF_Nav then
            table.insert(PCLcore.PCL_MF_Nav.tabs, btn)
        end
        table.insert(PCLcore.sectionFrames, btn.content)
        tabIndex = tabIndex + 1
    end
    -- Correct grid height calculation: rows*iconSize + (rows-1)*iconPad
    do
        local rows = math.ceil(#expansionSections / gridCols)
        local gridHeight = rows > 0 and (rows * iconSize + (rows - 1) * iconPad) or 0
        navYOffset = gridStartY - gridHeight - 15  -- Add more spacing after expansion grid
    end
    -- 3. Remaining full-width tabs
    for _, v in ipairs(otherSections) do
        local tab = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
        tab:SetSize(nav_width + 8, 32)  -- Use nav width for sidebar tabs
        tab:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 1, navYOffset)
        StyleNavButton(tab, false)  -- Use our styling function
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tab.text:SetPoint("LEFT", 10, 0)
        tab.text:SetText(L(v.name) or v.name)
        tab.section = v
        tab.content = PCL_frames:createContentFrame(PCL_mainFrame.ScrollChild, v.name)
        -- Populate other tab content if available
        if v.pets and v.pets.categories then
            if v.pets.categories.categories then
                PCL_frames:createCategoryFrame(v.pets.categories.categories, tab.content, v.name)
            else
                PCL_frames:createCategoryFrame(v.pets.categories, tab.content, v.name)
            end
        end
        tab.content:Hide()
        tab:SetScript("OnClick", function(self)
            SelectTab(self)
        end)
        tab:EnableMouse(true)
        tab:SetFrameStrata("HIGH")
        tab:SetFrameLevel(100)
        tab:Show()
        table.insert(tabFrame.tabs, tab)
        -- Also store in navigation frame for overview navigation (other sections)
        if PCLcore.PCL_MF_Nav then
            table.insert(PCLcore.PCL_MF_Nav.tabs, tab)
        end
        table.insert(PCLcore.sectionFrames, tab.content)
        tabIndex = tabIndex + 1
        navYOffset = navYOffset - 36  -- was 28, caused 4px overlap (32 height - 28 step)
    end
    -- 4. Pinned tab (always last)
    if pinnedSection then
        local tab = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
        tab:SetSize(nav_width + 8, 32)  -- Use nav width for sidebar tabs
        tab:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 1, navYOffset)
        StyleNavButton(tab, false)  -- Use our styling function
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tab.text:SetPoint("LEFT", 10, 0)
        tab.text:SetText(L(pinnedSection.name) or pinnedSection.name)
        tab.section = pinnedSection
        tab.content = PCL_frames:createContentFrame(PCL_mainFrame.ScrollChild, pinnedSection.name)
        
        -- Set global reference for pinned content frame (used by functions.lua)
        _G["PinnedFrame"] = tab.content
        _G["PinnedTab"] = tab
        
        -- Populate pinned tab content after creating the frame
        -- Initialize PCL_PINNED if it doesn't exist
        if not PCL_PINNED then
            PCL_PINNED = {}
        end
        
        if PCL_PINNED and next(PCL_PINNED) then
            -- Clear any existing pet frames for pinned section
            if not PCLcore.petFrames then
                PCLcore.petFrames = {}
            end
            if not PCLcore.petFrames[1] then
                PCLcore.petFrames[1] = {}
            else
                PCLcore.petFrames[1] = {}
            end
            -- Create the pinned section content
            local overflow, petFrame = PCLcore.Function:CreatePetsForCategory(PCL_PINNED, _G["PinnedFrame"], 30, _G["PinnedTab"], true, true)
            PCLcore.petFrames[1] = petFrame
        end
        
        tab.content:Hide()
        tab:SetScript("OnClick", function(self)
            SelectTab(self)
        end)
        tab:EnableMouse(true)
        tab:SetFrameStrata("HIGH")
        tab:SetFrameLevel(100)
        tab:Show()
        table.insert(tabFrame.tabs, tab)
        -- Also store in navigation frame for overview navigation (pinned)
        if PCLcore.PCL_MF_Nav then
            table.insert(PCLcore.PCL_MF_Nav.tabs, tab)
        end
        table.insert(PCLcore.sectionFrames, tab.content)
        tabIndex = tabIndex + 1
        navYOffset = navYOffset - 36  -- maintain consistent spacing
    end
    -- 5. Settings tab (always last)
    do
        local tab = CreateFrame("Button", nil, tabFrame, "BackdropTemplate")
        tab:SetSize(nav_width + 8, 32)
        tab:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 1, navYOffset)
        StyleNavButton(tab, false)
        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tab.text:SetPoint("LEFT", 10, 0)
        tab.text:SetText(L("Settings") or "Settings")
        tab.section = { name = "Settings" }
        tab.content = PCL_frames:createSettingsFrame(PCL_mainFrame.ScrollChild)
        tab.content:Hide()
        tab:SetScript("OnClick", function(self) SelectTab(self) end)
        tab:EnableMouse(true)
        tab:SetFrameStrata("HIGH")
        tab:SetFrameLevel(100)
        tab:Show()
        table.insert(tabFrame.tabs, tab)
        if PCLcore.PCL_MF_Nav then table.insert(PCLcore.PCL_MF_Nav.tabs, tab) end
        table.insert(PCLcore.sectionFrames, tab.content)
        tabIndex = tabIndex + 1
        navYOffset = navYOffset - 36  -- maintain consistent spacing
    end
    -- Select Overview by default
    if selectedTab then
        SelectTab(selectedTab)
    elseif tabFrame.tabs[1] then
        SelectTab(tabFrame.tabs[1])
    end
    return PCLcore.sectionFrames, #tabFrame.tabs
end


function PCL_frames:createNavFrame(relativeFrame, title)
    -- Nav frame is parented to the main frame so it opens/closes together
    -- Don't use insetFrameTemplate for default theme as it has its own styling that conflicts
    local frameTemplate = PCL_SETTINGS.useBlizzardTheme and "PCLBlizzardNavTemplate" or "BackdropTemplate"
    local frame = CreateFrame("Frame", "Nav", relativeFrame, frameTemplate);
    frame:SetWidth(nav_width + 10)  -- Keep original nav width as sidebar
    
    -- Set height to match current main frame height
    local _, currentHeight = PCL_frames:GetCurrentFrameDimensions()
    frame:SetHeight(currentHeight+1)
    
    frame:ClearAllPoints()
    
    -- Consistent positioning for both themes - account for any frame insets
    local xOffset = -1
    local yOffset = 2


    if PCL_SETTINGS.useBlizzardTheme then
        -- Blizzard theme has a different inset, adjust accordingly
        xOffset = 3  -- Adjusted for Blizzard theme
        yOffset = -5
        frame:SetHeight(currentHeight-9)
    end

    
    -- Get the actual frame dimensions and adjust for any template differences
    if PCL_SETTINGS.useBlizzardTheme then
        -- UIPanelDialogTemplate frames have different insets, get actual boundaries
        local left, bottom, width, height = relativeFrame:GetRect()
        if left then
            -- Position relative to the actual frame boundaries
            frame:SetPoint("TOPRIGHT", relativeFrame, "TOPLEFT", xOffset, yOffset)
        else
            -- Fallback positioning
            frame:SetPoint("TOPRIGHT", relativeFrame, "TOPLEFT", xOffset, yOffset)
        end
    else
        -- Default theme - standard positioning
        frame:SetPoint("TOPRIGHT", relativeFrame, "TOPLEFT", xOffset, yOffset)
    end
    
    -- Apply styling after frame creation to ensure it sticks
    if PCL_SETTINGS.useBlizzardTheme then
        -- Blizzard-style backdrop with proper textures
        if frame.SetBackdrop then
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", 
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
                edgeSize = 16,
                insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            frame:SetBackdropColor(0.05, 0.05, 0.15, 0.95)  -- Dark blue tint with higher opacity
            frame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)  -- Blue-gray border
        end
    else
        -- Default theme - dark background with proper opacity
        if frame.SetBackdrop then
            frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
            frame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)  -- Increased opacity to ensure visibility
            frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        end
    end
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -8)
    frame.title:SetText(title or "")
    
    -- Style the title text for Blizzard theme
    if PCL_SETTINGS.useBlizzardTheme then
        frame.title:SetTextColor(1, 0.82, 0, 1)  -- Gold color like Blizzard UI
    else
        frame.title:SetTextColor(1, 1, 1, 1)  -- White for default theme
    end
    
    -- Create search bar
    frame.searchContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.searchContainer:SetSize(nav_width - 10, 25)
    frame.searchContainer:SetPoint("TOP", frame.title, "BOTTOM", 0, -5)
    frame.searchContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 2
    })
    frame.searchContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    frame.searchContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    -- Create search editbox
    frame.searchBox = CreateFrame("EditBox", nil, frame.searchContainer)
    frame.searchBox:SetSize(nav_width - 20, 20)
    frame.searchBox:SetPoint("CENTER", frame.searchContainer, "CENTER", 0, 0)
    frame.searchBox:SetFontObject("GameFontHighlightSmall")
    frame.searchBox:SetTextColor(1, 1, 1, 1)
    frame.searchBox:SetAutoFocus(false)
    frame.searchBox:SetMaxLetters(50)
    frame.searchBox:EnableMouse(true)
    frame.searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        PCLcore.Search:PerformSearch(self:GetText())
    end)
    frame.searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText("")
        PCLcore.Search:ClearSearchAndGoToOverview()
    end)
    frame.searchBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            local text = self:GetText()
            if text == "" then
                PCLcore.Search:ClearSearchAndGoToOverview()
            end
        end
    end)
    
    -- Create search placeholder text
    frame.searchPlaceholder = frame.searchContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.searchPlaceholder:SetPoint("LEFT", frame.searchBox, "LEFT", 5, 0)
    frame.searchPlaceholder:SetText(L("Search pets..."))
    frame.searchPlaceholder:SetTextColor(0.6, 0.6, 0.6, 1)
    
    -- Show/hide placeholder based on editbox focus and content
    frame.searchBox:SetScript("OnEditFocusGained", function(self)
        frame.searchPlaceholder:Hide()
    end)
    frame.searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            frame.searchPlaceholder:Show()
        end
    end)
    
    -- Create clear search button
    frame.clearButton = CreateFrame("Button", nil, frame.searchContainer)
    frame.clearButton:SetSize(16, 16)
    frame.clearButton:SetPoint("RIGHT", frame.searchContainer, "RIGHT", -3, 0)
    frame.clearButton:SetNormalTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
    frame.clearButton:SetScript("OnClick", function()
        frame.searchBox:SetText("")
        frame.searchBox:ClearFocus()
        PCLcore.Search:ClearSearchAndGoToOverview()
        frame.searchPlaceholder:Show()
    end)
    frame.clearButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L("Clear Search"), 1, 1, 1)
        GameTooltip:Show()
    end)
    frame.clearButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Ensure the frame is visible and at the correct strata
    frame:SetFrameStrata("HIGH")
    frame:Show()
    
    return frame;
end

-- IMPORTANT: Ensure SetTabs is called before any code that uses PCLcore.overview

function PCL_frames:progressBar(relativeFrame, top)
    MyStatusBar = CreateFrame("StatusBar", nil, relativeFrame, "BackdropTemplate")
    -- Set statusbar texture with fallback if LibSharedMedia is not available
    if PCLcore.media and PCL_SETTINGS.statusBarTexture then
        local texture = PCLcore.media:Fetch("statusbar", PCL_SETTINGS.statusBarTexture)
        if texture then
            MyStatusBar:SetStatusBarTexture(texture)
        else
            MyStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-Status-Bar")
        end
    else
        MyStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-Status-Bar")
    end
    if not PCLcore.statusBarFrames then PCLcore.statusBarFrames = {} end
    -- Insert only once (previous duplicate removed)
    table.insert(PCLcore.statusBarFrames, MyStatusBar)
    MyStatusBar:GetStatusBarTexture():SetHorizTile(false)
    MyStatusBar:SetMinMaxValues(0, 100)
    MyStatusBar:SetValue(0)
    MyStatusBar:SetWidth(150)
    MyStatusBar:SetHeight(15)
    MyStatusBar:SetPoint("BOTTOMLEFT", relativeFrame, "BOTTOMLEFT", 0, 10)
    MyStatusBar:SetStatusBarColor(0.1, 0.9, 0.1)
    MyStatusBar.bg = MyStatusBar:CreateTexture(nil, "BACKGROUND")
    MyStatusBar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-Status-Bar")
    MyStatusBar.bg:SetAllPoints(true)
    MyStatusBar.bg:SetVertexColor(0.843, 0.874, 0.898, 0.5)
    MyStatusBar.Text = MyStatusBar:CreateFontString()
    MyStatusBar.Text:SetFontObject(GameFontWhite)
    MyStatusBar.Text:SetPoint("CENTER")
    MyStatusBar.Text:SetJustifyH("CENTER")
    MyStatusBar.Text:SetText()
    return MyStatusBar
end

function PCL_frames:createContentFrame(relativeFrame, title)
    -- Calculate dynamic width based on current main frame width
    local currentWidth, _ = PCL_frames:GetCurrentFrameDimensions()
    local availableWidth = currentWidth - 60  -- 60px for padding
    
    local frame = CreateFrame("Frame", nil, relativeFrame, "BackdropTemplate")
    frame:SetWidth(availableWidth)  -- Use current available width
    frame:SetHeight(50)  -- Increased height to accommodate title padding
    frame:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", 30, 0)  -- Remove nav_width since nav is outside
    
    -- Set opaque background for search results to prevent bleed-through
    if title == "Search Results" then
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame:SetBackdropColor(0.05, 0.05, 0.05, 1)  -- Opaque dark background
        frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    else
        frame:SetBackdropColor(0, 0, 0, 0)  -- Transparent background for other content
    end
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)  -- Added padding: 15px from left and top
    frame.title:SetText(L(title)) -- Localized for display
    frame.name = title -- Store non-localized name

    -- Add pin instructions for all sections except Overview
    if title == "Pinned" then
        local instructionsFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        instructionsFrame:SetSize(availableWidth - 30, 20)  -- Smaller height for compact display
        instructionsFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)  -- Position below title
        instructionsFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 2
        })
        instructionsFrame:SetBackdropColor(0.1, 0.1, 0.2, 0.6)  -- Subtle background
        instructionsFrame:SetBackdropBorderColor(0.4, 0.4, 0.6, 0.8)  -- Subtle border
        
        -- Create the instruction text with color formatting
        local instructionsText = instructionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        instructionsText:SetPoint("LEFT", instructionsFrame, "LEFT", 10, 0)
        -- Use color codes to make "Ctrl + Right Click" bold and orange
        instructionsText:SetText(L("Pin Instructions Text") or "|cffFF8800|TInterface\\GossipFrame\\AvailableQuestIcon:0:0:0:0:32:32:0:32:0:32|t Ctrl + Right Click|r to pin/unpin mounts")
        instructionsText:SetTextColor(0.9, 0.9, 1, 1)  -- Light blue-white for the rest of the text
        
        -- Adjust frame height to accommodate instructions
        frame:SetHeight(85)  -- Increased to make room for instructions
    end

    if title ~= "Pinned" then
        frame.pBar = PCLcore.Frames:progressBar(frame)
        local yOffset = title == "Overview" and -15 or -55  -- Adjust based on whether instructions are present
        frame.pBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, yOffset)  -- Aligned with title padding
        frame.pBar:SetWidth(availableWidth - 30)  -- Account for padding on both sides
        frame.pBar:SetHeight(20)
    end

    return frame
end


function PCL_frames:createOverviewCategory(set, relativeFrame)
    if not set or not relativeFrame then
        return
    end

    -- Clear the status bar tracking array to prevent memory leaks
    if not PCLcore.statusBarFrames then
        PCLcore.statusBarFrames = {}
    else
        -- Clear the existing array
        for i = #PCLcore.statusBarFrames, 1, -1 do
            PCLcore.statusBarFrames[i] = nil
        end
    end

    -- Clear existing content to prevent duplicates
    if relativeFrame.children then
        for _, child in pairs(relativeFrame.children) do
            if child and child:GetParent() == relativeFrame then
                child:Hide()
                child:SetParent(nil)
            end
        end
    end
    
    -- Clear all children of the relativeFrame
    local children = {relativeFrame:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Use the same layout calculations as createCategoryFrame for consistency
    local currentWidth, _ = PCL_frames:GetCurrentFrameDimensions()
    local availableWidth = currentWidth - 60  -- Total content width
    local columnSpacing = 25  -- Spacing between columns
    local numColumns = 2
    local columnWidth = math.floor((availableWidth - columnSpacing * (numColumns - 1)) / numColumns)
    
    local leftColumnX = -10  -- Start with padding from left edge
    local rightColumnX = leftColumnX + columnWidth + columnSpacing
    
    local leftColumnY = -30  -- Reduced from -60 for tighter spacing
    local rightColumnY = -30
    local sectionIndex = 0

    -- Create sections similar to how categories are created in other tabs
    for k, v in pairs(set) do
        if (v.name ~= "Overview") and (v.name ~= "Pinned") then
            sectionIndex = sectionIndex + 1
            
            -- Determine which column to use (alternate left/right)
            local isLeftColumn = (sectionIndex % 2 == 1)
            local xPos = isLeftColumn and leftColumnX or rightColumnX
            local yPos = isLeftColumn and leftColumnY or rightColumnY
            
            -- Get actual stats for this section
            local sectionStats = PCLcore.stats and PCLcore.stats[v.name]
            local totalMounts = (sectionStats and sectionStats.total) or 0
            local collectedMounts = (sectionStats and sectionStats.collected) or 0
            
            -- Create section frame without background
            local sectionFrame = CreateFrame("Frame", nil, relativeFrame)
            sectionFrame:SetWidth(columnWidth)  -- Use calculated column width
            sectionFrame:SetHeight(50)  -- Reduced from 65 to 50 for even tighter spacing
            sectionFrame:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", xPos, yPos)
            
            -- Section title with smaller font
            sectionFrame.title = sectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            sectionFrame.title:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 5, -2)  -- Reduced padding
            sectionFrame.title:SetText(L(v.name) or v.name)
            sectionFrame.title:SetTextColor(1, 1, 1, 1)
            
            -- Create progress bar container with dynamic width based on column width
            local progressContainer = CreateFrame("Frame", nil, sectionFrame)
            progressContainer:SetWidth(columnWidth - 10)  -- Use column width with padding
            progressContainer:SetHeight(16)  -- Smaller height
            progressContainer:SetPoint("TOPLEFT", sectionFrame.title, "BOTTOMLEFT", 0, -5)  -- Reduced spacing
            
            -- Create progress bar with background
            local pBar = CreateFrame("StatusBar", nil, progressContainer, "BackdropTemplate")
            
            -- Add dark background to the progress bar
            pBar:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 1
            })
            pBar:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
            pBar:SetBackdropBorderColor(0.6,0.2,0.8,0)
            
            -- Use settings texture if available, otherwise fallback to TargetingFrame
            local textureToUse = "Interface\\TargetingFrame\\UI-Status-Bar"  -- Good default that colors well
            if PCL_SETTINGS and PCL_SETTINGS.statusBarTexture and PCLcore.media then
                local settingsTexture = PCLcore.media:Fetch("statusbar", PCL_SETTINGS.statusBarTexture)
                if settingsTexture then
                    textureToUse = settingsTexture
                end
            end
            
            pBar:SetStatusBarTexture(textureToUse)
            pBar:GetStatusBarTexture():SetHorizTile(false)
            pBar:GetStatusBarTexture():SetVertTile(false)
            pBar:SetMinMaxValues(0, 100)
            pBar:SetValue(0)
            pBar:SetAllPoints(progressContainer)
            
            -- Text for progress bar
            pBar.Text = pBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            pBar.Text:SetPoint("CENTER", pBar, "CENTER", 0, 0)
            pBar.Text:SetJustifyH("CENTER")
            pBar.Text:SetTextColor(1, 1, 1, 1)
            
            -- Update progress bar with actual data
            if totalMounts > 0 then
                local percentage = (collectedMounts / totalMounts) * 100
                pBar:SetValue(percentage)
                pBar.Text:SetText(string.format("%d/%d (%d%%)", collectedMounts, totalMounts, math.floor(percentage)))
                
                -- Use the same color logic as other progress bars
                pBar.val = percentage
                UpdateProgressBar(pBar, totalMounts, collectedMounts)
            else
                pBar:SetValue(0)
                pBar.Text:SetText("0/0 (0%)")
                pBar:SetStatusBarColor(0.5, 0.5, 0.5)  -- Gray for no data
            end
            
            -- Store this in the same way other progress bars are stored
            -- Check if this progress bar is already in the table to prevent duplicates
            local alreadyExists = false
            if PCLcore.statusBarFrames then
                for _, existingBar in ipairs(PCLcore.statusBarFrames) do
                    if existingBar == pBar then
                        alreadyExists = true
                        break
                    end
                end
            end
            if not alreadyExists then
                table.insert(PCLcore.statusBarFrames, pBar)
            end
            
            -- Add hover effects like other sections
            pBar:HookScript("OnEnter", function()
                -- Store the current color before changing to hover color
                local r, g, b, a = pBar:GetStatusBarColor()
                pBar.originalR = r
                pBar.originalG = g
                pBar.originalB = b
                pBar:SetStatusBarColor(0.8, 0.5, 0.9, 1)  -- Purple hover color
            end)
            pBar:HookScript("OnLeave", function()
                -- Restore the stored original color
                if pBar.originalR and pBar.originalG and pBar.originalB then
                    pBar:SetStatusBarColor(pBar.originalR, pBar.originalG, pBar.originalB)
                else
                    -- Fallback: recalculate the color if we don't have stored values
                    if totalMounts > 0 then
                        local percentage = (collectedMounts / totalMounts) * 100
                        if percentage < 33 then
                            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.low.r, PCL_SETTINGS.progressColors.low.g, PCL_SETTINGS.progressColors.low.b)
                        elseif percentage < 66 then
                            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.medium.r, PCL_SETTINGS.progressColors.medium.g, PCL_SETTINGS.progressColors.medium.b)
                        elseif percentage < 100 then
                            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.high.r, PCL_SETTINGS.progressColors.high.g, PCL_SETTINGS.progressColors.high.b)
                        else
                            pBar:SetStatusBarColor(PCL_SETTINGS.progressColors.complete.r, PCL_SETTINGS.progressColors.complete.g, PCL_SETTINGS.progressColors.complete.b)
                        end
                    else
                        pBar:SetStatusBarColor(0.5, 0.5, 0.5)  -- Gray for no data
                    end
                end
            end)
            
            -- Add click functionality to navigate to the section
            pBar:SetScript("OnMouseDown", function(self, button)
                if button == 'LeftButton' then
                    -- Find the corresponding tab and select it
                    local navFrame = PCLcore.PCL_MF_Nav
                    if navFrame and navFrame.tabs then
                        for _, tab in ipairs(navFrame.tabs) do
                            if tab.section and tab.section.name == v.name then
                                -- Use the same selection logic as in SetTabs
                                for _, t in ipairs(navFrame.tabs) do
                                    if t.content then t.content:Hide() end
                                    if t.SetBackdropBorderColor then
                                        t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                                    end
                                end
                                if tab.SetBackdropBorderColor then
                                    tab:SetBackdropBorderColor(1, 0.82, 0, 1)
                                end
                                if PCL_mainFrame and PCL_mainFrame.ScrollFrame then
                                    -- Always keep the main scroll child as the scroll child
                                    PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                                    if tab.content then
                                        tab.content:Show()
                                    end
                                    PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
                                end
                                break
                            end
                        end
                    end
                end
            end)
            
            -- Store frame reference for updates
            local t = {
                name = v.name, -- Use non-localized name for identification
                frame = pBar
            }
            
            -- Initialize overviewFrames if it doesn't exist
            if not PCLcore.overviewFrames then
                PCLcore.overviewFrames = {}
            end
            
            -- Check for duplicates before adding
            local alreadyExists = false
            for _, existingFrame in ipairs(PCLcore.overviewFrames) do
                if existingFrame.name == v.name then
                    alreadyExists = true
                    break
                end
            end
            
            if not alreadyExists then
                table.insert(PCLcore.overviewFrames, t)
            end
            
            -- Update column positions for next section
            if isLeftColumn then
                leftColumnY = leftColumnY - 55  -- Reduced from 75 to 55 (section height 50 + 5 spacing)
            else
                rightColumnY = rightColumnY - 55
            end
        end
    end
    
    -- Adjust parent frame height to accommodate all sections with proper padding
    local maxY = math.min(leftColumnY, rightColumnY)
    local requiredHeight = math.abs(maxY) + 40  -- Add more padding for better spacing
    relativeFrame:SetHeight(requiredHeight)
end

function PCL_frames:createCategoryFrame(set, relativeFrame, sectionName)
    -- Don't create pet frames during combat or restricted situations to avoid protected function errors
    if InCombatLockdown() then
        return
    end
    
    if not set then
        return
    end

    -- Check if set has any data
    local hasData = false
    for k, v in pairs(set) do
        hasData = true
        break
    end
    
    if not hasData then
        return
    end

    -- CRITICAL: Clear existing category frames from this relativeFrame before creating new ones
    -- This prevents coordinate accumulation when the function is called multiple times
    if relativeFrame then
        local children = {relativeFrame:GetChildren()}
        for _, child in ipairs(children) do
            -- Only remove category frames, not the title or progress bar
            if child and child:GetName() and string.find(child:GetName() or "", "Category") then
                child:Hide()
                child:SetParent(nil)
            elseif child and not child.title and not child.pBar then
                -- Remove unnamed frames that are likely category frames (don't have title or pBar)
                child:Hide()
                child:SetParent(nil)
            end
        end
    end

    -- Debug: Show what's in the set to understand the structure
    if PCLcore and PCLcore.Debug then
        print(string.format("[PCL Debug] === FUNCTION CALL: createCategoryFrame for section: %s ===", sectionName or "Unknown"))
        local setCount = 0
        for k, v in pairs(set) do
            setCount = setCount + 1
            if type(v) == "table" then
                print(string.format("[PCL Debug] - Category %d: %s (table)", setCount, k))
            else
                print(string.format("[PCL Debug] - Category %d: %s (%s)", setCount, k, type(v)))
            end
        end
        print(string.format("[PCL Debug] Total categories in set: %d", setCount))
    end

    -- Dynamic layout calculation based on current frame width
    local currentWidth, _ = PCL_frames:GetCurrentFrameDimensions()
    local availableWidth = currentWidth - 60  -- Total content width
    local columnSpacing = 25  -- Reduced spacing between columns to use more space
    local numColumns = 2
    local columnWidth = math.floor((availableWidth - columnSpacing * (numColumns - 1)) / numColumns)
    
    local leftColumnX = -10  -- Start with proper padding from left edge (consistent with overview)
    local rightColumnX = leftColumnX + columnWidth + columnSpacing
    
    -- RESET Y positions for each section - this was the missing piece!
    local leftColumnY = -50
    local rightColumnY = -50
    local categoryIndex = 0

    -- Debug output for section start
    if PCLcore and PCLcore.Debug then
        print(string.format("[PCL Debug] Reset Y positions: leftY=%d, rightY=%d", leftColumnY, rightColumnY))
    end

    -- Get sorted category names
    local sortedCategoryNames = {}
    for k, v in pairs(set) do
        if type(v) == "table" then
            table.insert(sortedCategoryNames, k)
        end
    end
    table.sort(sortedCategoryNames)

    for _, categoryName in ipairs(sortedCategoryNames) do
        local categoryData = set[categoryName]
        -- Calculate mount stats for this category first (needed for dynamic height)
        local totalMounts = 0
        local collectedMounts = 0
        local displayedMounts = 0  -- Track mounts that will actually be displayed
        
        -- Combine both mounts and mountID arrays
        local mountList = {}
        if categoryData.pets then
            for _, pet in ipairs(categoryData.pets) do
                table.insert(mountList, pet)
            end
        end
        if categoryData.mountID then
            for _, mount in ipairs(categoryData.mountID) do
                table.insert(mountList, mount)
            end
        end
        
        for _, mountId in ipairs(mountList) do
            local mount_Id = PCLcore.Function:GetPetID(mountId)
            if mount_Id and (type(mount_Id) == "number" or type(mount_Id) == "string") and tonumber(mount_Id) and tonumber(mount_Id) > 0 then
                local petSpeciesID = tonumber(mount_Id)
                
                -- Validate pet exists and is obtainable before counting
                local petName, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID)
                if obtainable ~= nil and petName then
                    -- Faction check: Only count pets that are not faction-specific or match the player's faction
                    local faction, faction_specific = PCLcore.Function.IsPetFactionSpecific(mountId)
                    local playerFaction = UnitFactionGroup("player")
                    local allowed = false
                    if faction_specific == false then
                        allowed = true
                    elseif faction_specific == true then
                        if faction == 0 then faction = "Horde" elseif faction == 1 then faction = "Alliance" end
                        allowed = (faction == playerFaction)
                    end
                    if allowed then
                        local isCollected = IsPetCollected(petSpeciesID)
                        totalMounts = totalMounts + 1
                        if isCollected then
                            collectedMounts = collectedMounts + 1
                        end
                        if not (PCL_SETTINGS.hideCollectedPets and isCollected) then
                            displayedMounts = displayedMounts + 1
                        end
                    end
                end
            end
        end

        -- Only increment categoryIndex if the category is actually displayed (e.g., displayedMounts > 0)
        if displayedMounts > 0 then
            categoryIndex = categoryIndex + 1
            -- Determine which column to use (alternate left/right)
            local isLeftColumn = (categoryIndex % 2 == 1)
            local xPos = isLeftColumn and leftColumnX or rightColumnX
            local yPos = isLeftColumn and leftColumnY or rightColumnY
            
            -- Calculate optimal pets per row based on column width (same calculation as later)
            local categoryPadding = 20  -- Total padding (10px on each side)
            local availableMountWidth = columnWidth - categoryPadding
            
            -- Start with user's preferred pets per row
            local mountsPerRow = PCL_SETTINGS.PetsPerRow or 12  -- Use setting or default to 12
            -- Ensure it's within bounds
            mountsPerRow = math.max(6, math.min(mountsPerRow, 24))
            
            -- Calculate mount size to fit exactly within available width
            local desiredSpacing = 4  -- Fixed spacing between mounts
            local minMountSize = 16  -- Absolute minimum mount size (reduced from 24)
            local maxMountSize = 48  -- Maximum mount size
            
            -- Try the preferred mounts per row first
            local totalSpacingWidth = desiredSpacing * (mountsPerRow - 1)
            local availableForMounts = availableMountWidth - totalSpacingWidth
            local mountSize = math.floor(availableForMounts / mountsPerRow)
            
            -- If mount size is too small, reduce mounts per row until we get acceptable size
            while mountSize < minMountSize and mountsPerRow > 6 do
                mountsPerRow = mountsPerRow - 1
                totalSpacingWidth = desiredSpacing * (mountsPerRow - 1)
                availableForMounts = availableMountWidth - totalSpacingWidth
                mountSize = math.floor(availableForMounts / mountsPerRow)
            end
            
            -- Ensure mount size is within bounds
            mountSize = math.max(minMountSize, math.min(mountSize, maxMountSize))
            
            -- Recalculate actual spacing to center the grid
            local actualMountWidth = mountSize * mountsPerRow
            local actualSpacing = mountsPerRow > 1 and math.floor((availableMountWidth - actualMountWidth) / (mountsPerRow - 1)) or 0
            actualSpacing = math.max(1, actualSpacing)  -- Minimum 1px spacing (reduced from 2)
            
            -- Calculate dynamic height based on actual mount layout
            local numRows = math.ceil(displayedMounts / mountsPerRow)
            local baseHeight = 80  -- Base height (title + progress bar + padding)
            local rowSpacing = 4  -- Minimal Y-axis spacing between rows (reduced)
            local rowHeight = mountSize + rowSpacing  -- Actual row height based on calculated mount size
            local categoryHeight = baseHeight + (numRows * rowHeight) + 10  -- Reduced bottom padding
            
            -- Debug output for category height calculation
            if PCLcore and PCLcore.Debug then
                print(string.format("[PCL Debug] Category: %s", categoryData.name or categoryName or "Unknown"))
                print(string.format("[PCL Debug] - displayedMounts: %d, mountsPerRow: %d", displayedMounts, mountsPerRow))
                print(string.format("[PCL Debug] - numRows: %d, mountSize: %d", numRows, mountSize))
                print(string.format("[PCL Debug] - baseHeight: %d, rowHeight: %d", baseHeight, rowHeight))
                print(string.format("[PCL Debug] - categoryHeight: %d", categoryHeight))
                print(string.format("[PCL Debug] - Position: x=%d, y=%d", xPos, yPos))
            end
            
            -- Create category frame with dynamic height
            local categoryFrame = CreateFrame("Frame", nil, relativeFrame, "BackdropTemplate")

            categoryFrame:SetWidth(columnWidth)
            categoryFrame:SetHeight(categoryHeight)  -- Dynamic height
            categoryFrame:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", xPos, yPos)
            categoryFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 8
            })
            categoryFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
            categoryFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

            -- Category title
            categoryFrame.title = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            categoryFrame.title:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", 10, -8)
            categoryFrame.title:SetText(L(categoryData.name) or L(categoryName) or categoryData.name or categoryName)
            categoryFrame.title:SetTextColor(1, 1, 1, 1)
            
            -- CRITICAL FIX: Immediately update the column Y position so subsequent categories use the correct anchor.
            -- Previously this was deferred until the end of the loop, causing overlap because
            -- the loop continued positioning later categories before the Y offsets were adjusted.
            if isLeftColumn then
                leftColumnY = leftColumnY - (categoryHeight + 8)  -- Reduced spacing between categories
                if PCLcore and PCLcore.Debug then
                    print(string.format("[PCL Debug] Left column Y: %d -> %d (moved %d)", yPos, leftColumnY, categoryHeight + 8))
                end
            else
                rightColumnY = rightColumnY - (categoryHeight + 8)  -- Reduced spacing between categories
                
                -- After placing a right column category, both columns should move to the next row
                -- Set both to the position that allows the next pair to be placed with minimal spacing
                local nextRowY = math.min(leftColumnY, rightColumnY) - 8  -- Small gap between rows
                if PCLcore and PCLcore.Debug then
                    print(string.format("[PCL Debug] Right column Y: %d -> %d (moved %d)", yPos, rightColumnY, categoryHeight + 8))
                    print(string.format("[PCL Debug] Row sync: leftY=%d, rightY=%d -> nextRowY=%d", leftColumnY, rightColumnY, nextRowY))
                end
                leftColumnY = nextRowY
                rightColumnY = nextRowY
            end
            
            -- Create progress bar container
            local progressContainer = CreateFrame("Frame", nil, categoryFrame)
            progressContainer:SetWidth(columnWidth - 20)  -- Now 500px wide
            progressContainer:SetHeight(18)
            progressContainer:SetPoint("TOPLEFT", categoryFrame.title, "BOTTOMLEFT", 0, -5)
            
            -- Create progress bar using proper texture fallback
            local pBar = CreateFrame("StatusBar", nil, progressContainer, "BackdropTemplate")
            
            -- Use settings texture if available, otherwise fallback to TargetingFrame
            local textureToUse = "Interface\\TargetingFrame\\UI-Status-Bar"  -- Good default that colors well
            if PCL_SETTINGS and PCL_SETTINGS.statusBarTexture and PCLcore.media then
                local settingsTexture = PCLcore.media:Fetch("statusbar", PCL_SETTINGS.statusBarTexture)
                if settingsTexture then
                    textureToUse = settingsTexture
                end
            end
            
            pBar:SetStatusBarTexture(textureToUse)
            pBar:GetStatusBarTexture():SetHorizTile(false)
            pBar:GetStatusBarTexture():SetVertTile(false)
            pBar:SetMinMaxValues(0, 100)
            pBar:SetValue(0)
            pBar:SetAllPoints(progressContainer)
            
            -- Background for progress bar
            pBar:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 1
            })
            pBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            pBar:SetBackdropBorderColor(0.6,0.2,0.8,0)
            
            -- Text for progress bar
            pBar.Text = pBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            pBar.Text:SetPoint("CENTER", pBar, "CENTER", 0, 0)
            pBar.Text:SetTextColor(1, 1, 1, 1)
            
            -- Update progress bar
            local percentage = totalMounts > 0 and (collectedMounts / totalMounts) * 100 or 0
            pBar:SetValue(percentage)
            pBar.Text:SetText(string.format("%d/%d (%d%%)", collectedMounts, totalMounts, percentage))
            
            -- Use the UpdateProgressBar function for consistent coloring
            pBar.val = percentage
            UpdateProgressBar(pBar, totalMounts, collectedMounts)
            
            -- Mount grid within category - positioned below progress bar
            local mountStartY = -60  -- More padding below progress bar
            
            -- Use the same calculations as in height calculation for consistency
            local categoryPadding = 20  -- Total padding (10px on each side)
            local availableMountWidth = columnWidth - categoryPadding
            
            -- Start with user's preferred pets per row
            local mountsPerRow = PCL_SETTINGS.PetsPerRow or 12  -- Use setting or default to 12
            -- Ensure it's within bounds
            mountsPerRow = math.max(6, math.min(mountsPerRow, 24))
            
            -- Calculate mount size to fit exactly within available width
            local desiredSpacing = 4  -- Fixed spacing between mounts
            local minMountSize = 16  -- Absolute minimum mount size (reduced from 24)
            local maxMountSize = 48  -- Maximum mount size
            
            -- Try the preferred mounts per row first
            local totalSpacingWidth = desiredSpacing * (mountsPerRow - 1)
            local availableForMounts = availableMountWidth - totalSpacingWidth
            local mountSize = math.floor(availableForMounts / mountsPerRow)
            
            -- If mount size is too small, reduce mounts per row until we get acceptable size
            while mountSize < minMountSize and mountsPerRow > 6 do
                mountsPerRow = mountsPerRow - 1
                totalSpacingWidth = desiredSpacing * (mountsPerRow - 1)
                availableForMounts = availableMountWidth - totalSpacingWidth
                mountSize = math.floor(availableForMounts / mountsPerRow)
            end
            
            -- Ensure mount size is within bounds
            mountSize = math.max(minMountSize, math.min(mountSize, maxMountSize))
            
            -- Recalculate actual spacing to center the grid
            local actualMountWidth = mountSize * mountsPerRow
            local actualSpacing = mountsPerRow > 1 and math.floor((availableMountWidth - actualMountWidth) / (mountsPerRow - 1)) or 0
            actualSpacing = math.max(1, actualSpacing)  -- Minimum 1px spacing (reduced from 2)
            
            -- Y-axis spacing (only affected by height changes)
            local rowSpacing = 4  -- Minimal Y-axis spacing between rows
            
            local maxDisplayMounts = displayedMounts  -- Show all displayed mounts instead of limiting to 24
            local mountStartX = 10
            local displayedIndex = 0  -- Track the actual displayed position
            
            for i, mountId in ipairs(mountList) do
                -- Check if we should skip this mount due to hide collected mounts setting
                local mount_Id = PCLcore.Function:GetPetID(mountId)
                -- Faction check: Only display pets that are not faction-specific or match the player's faction
                local faction, faction_specific = PCLcore.Function.IsPetFactionSpecific(mountId)
                local playerFaction = UnitFactionGroup("player")
                local allowed = false
                if faction_specific == false then
                    allowed = true
                elseif faction_specific == true then
                    if faction == 0 then faction = "Horde" elseif faction == 1 then faction = "Alliance" end
                    allowed = (faction == playerFaction)
                end
                if allowed and not (mount_Id and PCL_SETTINGS.hideCollectedPets and IsPetCollected(tonumber(mount_Id))) then
                    displayedIndex = displayedIndex + 1
                    if displayedIndex <= maxDisplayMounts then
                    local col = ((displayedIndex-1) % mountsPerRow)
                    local row = math.floor((displayedIndex-1) / mountsPerRow)
                    
                    -- Calculate exact position for this icon
                    local iconX = mountStartX + col * (mountSize + actualSpacing)
                    local iconY = mountStartY - row * (mountSize + rowSpacing)  -- Use rowSpacing for Y
                    
                    -- Get pet info first to check if pet exists before creating any frames
                    if mount_Id and (type(mount_Id) == "number" or type(mount_Id) == "string") and tonumber(mount_Id) and tonumber(mount_Id) > 0 then
                        local petSpeciesID = tonumber(mount_Id)
                        local petName, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID)
                        -- Skip pets that don't exist (return nil from GetPetInfoBySpeciesID)
                        if obtainable ~= nil then
                            -- Create backdrop frame first (smaller than spacing to create visual gaps) - only if pet exists
                            local backdropSize = mountSize + 2  -- Only 1px overhang on each side for visual separation
                            local backdropFrame = CreateFrame("Frame", nil, categoryFrame, "BackdropTemplate")
                            backdropFrame:SetSize(backdropSize, backdropSize)
                            backdropFrame:SetPoint("TOPLEFT", categoryFrame, "TOPLEFT", 
                                iconX - 1, -- Minimal offset for overhang
                                iconY + 1) -- Minimal offset for overhang
                            
                            -- Store the pet ID for search functionality
                            backdropFrame.petID = mountId
                            -- Create pet frame (for icon) centered in backdrop only if pet exists
                            local petFrame = CreateFrame("Button", nil, backdropFrame)
                            petFrame:SetSize(mountSize, mountSize)
                            petFrame:SetPoint("CENTER", backdropFrame, "CENTER", 0, 0)
                            
                            -- Store the pet ID for search functionality
                            petFrame.petID = mountId
                            
                            -- Set category and section for pinning functionality
                            petFrame.category = categoryData.name or categoryName
                            petFrame.section = sectionName or "Unknown"
                            
                            if icon then
                                -- Create the icon texture
                                petFrame.tex = petFrame:CreateTexture(nil, "ARTWORK")
                                petFrame.tex:SetAllPoints(petFrame)
                                petFrame.tex:SetTexture(icon)
                                
                                -- Create pin icon for this mount frame
                                petFrame.pin = petFrame:CreateTexture(nil, "OVERLAY")
                                petFrame.pin:SetWidth(16)
                                petFrame.pin:SetHeight(16)
                                petFrame.pin:SetTexture("Interface\\AddOns\\PCL\\icons\\pin.blp")
                                petFrame.pin:SetPoint("TOPRIGHT", petFrame, "TOPRIGHT", 6, 6)
                                
                                -- Check if this pet is pinned and set pin visibility
                                local pin_check = PCLcore.Function:CheckIfPinned("p"..petSpeciesID)
                                if pin_check == true then
                                    petFrame.pin:SetAlpha(1)
                                else
                                    petFrame.pin:SetAlpha(0)
                                end
                                
                                -- Check if pet is collected and style backdrop accordingly
                                if IsPetCollected(petSpeciesID) then
                                    -- Collected pet styling - green background with thick border
                                    petFrame.tex:SetVertexColor(1, 1, 1, 1)
                                    backdropFrame:SetBackdrop({
                                        bgFile = "Interface\\Buttons\\WHITE8x8",
                                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                                        edgeSize = 3  -- Thicker border
                                    })
                                    backdropFrame:SetBackdropColor(0, 0.8, 0, 0.6)  -- Brighter green background
                                    backdropFrame:SetBackdropBorderColor(0, 1, 0, 1)  -- Bright green border
                                else
                                    -- Uncollected pet styling - red/dark background
                                    petFrame.tex:SetVertexColor(0.4, 0.4, 0.4, 0.7)
                                    backdropFrame:SetBackdrop({
                                        bgFile = "Interface\\Buttons\\WHITE8x8",
                                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                                        edgeSize = 2  -- Slightly thinner border for uncollected
                                    })
                                    backdropFrame:SetBackdropColor(0.3, 0.1, 0.1, 0.4)  -- Reddish background
                                    backdropFrame:SetBackdropBorderColor(0.6, 0.2, 0.2, 0.8)  -- Red border
                                end
                                
                                -- Add pet interaction to the pet frame
                                if PCLcore.Function and PCLcore.Function.LinkPetItem then
                                    -- Ensure we pass the proper pet ID format with "p" prefix
                                    local petID = "p" .. petSpeciesID
                                    PCLcore.Function:LinkPetItem(petID, petFrame, false)
                                end

                                -- Attach PetCard hover handlers (once) so hovering an icon shows the PetCard
                                if petFrame and not petFrame._petCardHooked then
                                    petFrame.speciesID = petSpeciesID
                                    petFrame:HookScript("OnEnter", function(self)
                                        if PCL_SETTINGS and PCL_SETTINGS.enablePetCardOnHover and PCLcore and PCLcore.PetCard and PCLcore.PetCard.ShowAsTooltip then
                                            PCLcore.PetCard:ShowAsTooltip(self.speciesID, self)
                                        end
                                    end)
                                    petFrame._petCardHooked = true
                                end
                            end -- Close if icon
                        end -- Close if petName (pet exists)
                    end -- Close if mount_Id validation
                else
                    -- Debug logging for skipped mounts
                    if PCLcore.Debug then
                        local isCollected = mount_Id and IsPetCollected(tonumber(mount_Id))
                        local reason = ""
                        if not allowed then
                            reason = "Faction restriction"
                        elseif mount_Id and PCL_SETTINGS.hideCollectedPets and isCollected then
                            reason = "Hidden collected pet"
                        else
                            reason = "Unknown reason"
                        end
                    end
                end
            end  -- Close the for loop
            
        end
    end
end
    -- Adjust parent frame height to accommodate all categories with proper padding
    local maxY = math.min(leftColumnY, rightColumnY)
    local requiredHeight = math.abs(maxY) + 20  -- Reduced padding for tighter layout
    
    -- Debug final frame sizing
    if PCLcore and PCLcore.Debug then
        print(string.format("[PCL Debug] Final frame sizing:"))
        print(string.format("[PCL Debug] - leftColumnY: %d, rightColumnY: %d", leftColumnY, rightColumnY))
        print(string.format("[PCL Debug] - maxY: %d, requiredHeight: %d", maxY, requiredHeight))
    end
    
    relativeFrame:SetHeight(requiredHeight)
end

function PCL_frames:createSettingsFrame(relativeFrame)
    local currentWidth = select(1, PCL_frames:GetCurrentFrameDimensions())
    local availableWidth = currentWidth - 60
    local frame = CreateFrame("Frame", nil, relativeFrame, "BackdropTemplate")
    frame:SetWidth(availableWidth)
    frame:SetHeight(900)
    frame:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", 30, 0)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -15)
    frame.title:SetText(L("Settings"))
    -- Updated to purple theme
    frame.title:SetTextColor(0.6,0.2,0.8,1)
    frame.name = "Settings"

    -- Two columns (match MCL spacing)
    local columnWidth = math.floor((availableWidth - 80) / 2) -- give more gutter
    local leftColumn = CreateFrame("Frame", nil, frame)
    leftColumn:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -50)
    leftColumn:SetSize(columnWidth, 820)
    local rightColumn = CreateFrame("Frame", nil, frame)
    rightColumn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -50)
    rightColumn:SetSize(columnWidth, 820)

    local leftY, rightY = 0, 0
    local sectionSpacing = 10

    local function AddSectionHeader(parent, text, isRight)
        local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, isRight and rightY or leftY)
        fs:SetText(text)
        -- Purple instead of cyan
        fs:SetTextColor(0.6,0.2,0.8,1)
        if isRight then rightY = rightY - 30 else leftY = leftY - 30 end
        return fs
    end

    -- Checkbox style similar to MCL (white text, optional highlight color when checked)
    local function StyleCheckBox(cb, textFS)
        if not cb then return end
        -- Avoid starting a statement with a parenthesized expression to prevent
        -- 'ambiguous syntax (function call x new statement)' parser error.
        local target = textFS or cb.Text
        if not target then return end
        target:SetFontObject(GameFontHighlight)
        target:SetTextColor(0.9,0.9,0.9,1)
    end

    local function AddCheckbox(parent, label, key, tooltip, onChange, isRight)
        local yRef = isRight and rightY or leftY
        local cb = CreateFrame("CheckButton", nil, parent)
        cb:SetSize(20,20)
        cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yRef)
        cb:SetChecked(PCL_SETTINGS[key])
        cb.bg = cb:CreateTexture(nil, "BACKGROUND")
        cb.bg:SetAllPoints(cb)
        -- Base (off) color dark gray
        cb.bg:SetColorTexture(0.2,0.2,0.2,1)
        -- When checked fill purple (no tick texture)
        local function UpdateFill()
            if cb:GetChecked() then
                cb.bg:SetColorTexture(0.6,0.2,0.8,1)
            else
                cb.bg:SetColorTexture(0.2,0.2,0.2,1)
            end
        end
        UpdateFill()
        local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 8, 0)
        text:SetText(label)
        StyleCheckBox(cb, text)
        cb:SetScript("OnClick", function(self)
            local v = self:GetChecked() and true or false
            PCL_SETTINGS[key] = v
            UpdateFill()
            if onChange then onChange(v) end
        end)
        if tooltip then
            cb:HookScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(label,1,1,1)
                GameTooltip:AddLine(tooltip,0.8,0.8,0.8,true)
                GameTooltip:Show()
            end)
            cb:HookScript("OnLeave", function() GameTooltip:Hide() end)
        end
        if isRight then rightY = rightY - 35 else leftY = leftY - 35 end
        return cb
    end

    -- MCL-like slider (label above with current value, grey track, cyan thumb area, min/max underneath, optional input box)
    local function AddSlider(parent, label, key, minV, maxV, step, isRight, isPercent, withInputBox, onChange)
        local yRef = isRight and rightY or leftY
        local current = PCL_SETTINGS[key] or minV
        if current < minV then current = minV elseif current > maxV then current = maxV end
        PCL_SETTINGS[key] = current

        local valueText = isPercent and (math.floor(current*100+0.5).."%") or tostring(math.floor(current))
        local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yRef)
        lbl:SetText((label or "") .. ": " .. valueText)
        lbl:SetTextColor(0.9,0.9,0.9,1)
        yRef = yRef - 25

        local slider = CreateFrame("Slider", nil, parent)
        slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yRef)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(minV, maxV)
        slider:SetValue(current)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetWidth(200)
        slider:SetHeight(20)

        -- Track (transparent now, remove gray background)
        local track = slider:CreateTexture(nil, "BACKGROUND")
        track:SetAllPoints(slider)
        track:SetColorTexture(0,0,0,0)

        -- Fill now purple
        local fill = slider:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("LEFT", slider, "LEFT", 0, 0)
        fill:SetHeight(4)
        fill:SetColorTexture(0.6,0.2,0.8,1)
        fill:SetPoint("CENTER", slider, "CENTER", 0, 0) -- center thin line

        local thumb = slider:CreateTexture(nil, "OVERLAY")
        thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        thumb:SetSize(24,24)
        slider:SetThumbTexture(thumb)

        -- Min/Max labels
        local minLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        minLabel:SetPoint("LEFT", slider, "LEFT", 0, -20)
        minLabel:SetText(isPercent and (math.floor(minV*100).."%") or tostring(minV))
        minLabel:SetTextColor(0.7,0.7,0.7,1)
        local maxLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        maxLabel:SetPoint("RIGHT", slider, "RIGHT", 0, -20)
        maxLabel:SetText(isPercent and (math.floor(maxV*100).."%") or tostring(maxV))
        maxLabel:SetTextColor(0.7,0.7,0.7,1)

        local edit
        if withInputBox then
            edit = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
            edit:SetSize(40,20)
            edit:SetPoint("LEFT", slider, "RIGHT", 10, 0)
            edit:SetAutoFocus(false)
            edit:SetFontObject(GameFontHighlightSmall)
            edit:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8 })
            edit:SetBackdropColor(0.07,0.07,0.07,0.95)
            edit:SetBackdropBorderColor(0.4,0.6,0.8,0.8)
            local function setEdit(val)
                if isPercent then edit:SetText(math.floor(val*100+0.5)) else edit:SetText(math.floor(val)) end
            end
            setEdit(current)
            edit:SetScript("OnEscapePressed", function(self) self:ClearFocus(); setEdit(slider:GetValue()) end)
            edit:SetScript("OnEnterPressed", function(self)
                local txt = self:GetText():gsub("%%", "")
                local num = tonumber(txt)
                if num then
                    if isPercent then num = num/100 end
                    if num < minV then num = minV elseif num > maxV then num = maxV end
                    if step and step>0 then num = math.floor((num-minV)/step+0.5)*step + minV end
                    slider:SetValue(num)
                end
                self:ClearFocus()
            end)
        end

        local function UpdateFill(val)
            local pct = (val - minV)/(maxV - minV)
            if pct < 0 then pct = 0 elseif pct > 1 then pct = 1 end
            fill:ClearAllPoints()
            fill:SetPoint("LEFT", slider, "LEFT", 0, 0)
            fill:SetPoint("RIGHT", slider, "LEFT", slider:GetWidth()*pct, 0)
        end
        slider:SetScript("OnValueChanged", function(self, val)
            if isPercent then
                lbl:SetText(label .. ": " .. math.floor(val*100+0.5) .. "%")
            else
                lbl:SetText(label .. ": " .. math.floor(val))
            end
            PCL_SETTINGS[key] = val
            if edit then if isPercent then edit:SetText(math.floor(val*100+0.5)) else edit:SetText(math.floor(val)) end end
            UpdateFill(val)
            if onChange then onChange(val) end
        end)
        slider:SetScript("OnSizeChanged", function(self) UpdateFill(self:GetValue()) end)
        UpdateFill(current)

        if isRight then rightY = yRef - 45 else leftY = yRef - 45 end
        return slider
    end

    ------------------------------------------------------------------
    -- LEFT COLUMN
    ------------------------------------------------------------------
    AddSectionHeader(leftColumn, L("Theme"), false)
    AddCheckbox(leftColumn, L("Use Blizzard Theme"), "useBlizzardTheme", L("Switches the window to a Blizzard styled theme"), function()
        if PCL_frames.RefreshLayout then PCL_frames:RefreshLayout() end
    end, false)

    AddSectionHeader(leftColumn, L("Display Options"), false)
    AddCheckbox(leftColumn, L("Hide Collected Pets"), "hideCollectedPets", L("Do not show pets you have already collected"), function()
        if PCL_frames.RefreshLayout then PCL_frames:RefreshLayout() end
    end, false)
    AddCheckbox(leftColumn, L("Enable Pet Card on Hover"), "enablePetCardOnHover", L("Show pet card when hovering pet icons"), nil, false)
    
    -- Add default for showMinimapIcon if not set
    if PCL_SETTINGS.showMinimapIcon == nil then
        PCL_SETTINGS.showMinimapIcon = true
    end
    
    AddCheckbox(leftColumn, L("Show Minimap Icon"), "showMinimapIcon", L("Toggle the display of the Minimap Icon."), function(value)
        -- Initialize minimapIcon table if needed
        if not PCL_SETTINGS.minimapIcon then
            PCL_SETTINGS.minimapIcon = {}
        end
        PCL_SETTINGS.minimapIcon.hide = not value
        
        -- Update the minimap icon if LibDBIcon is available
        local LibDBIcon = LibStub("LibDBIcon-1.0", true)
        if LibDBIcon then
            if value then
                LibDBIcon:Show("PCL")
            else
                LibDBIcon:Hide("PCL")
            end
        end
    end, false)

    AddSectionHeader(leftColumn, L("Layout Options"), false)
    AddSlider(leftColumn, L("Pets Per Row"), "PetsPerRow", 6, 24, 1, false, false, true, function()
        if PCL_frames.RefreshLayout then PCL_frames:RefreshLayout() end
    end)

    ------------------------------------------------------------------
    -- RIGHT COLUMN
    ------------------------------------------------------------------
    AddSectionHeader(rightColumn, L("Progress Bar Options"), true)

    -- (Texture dropdown retained)
    -- Try to acquire LibSharedMedia dynamically if not already cached
    if not PCLcore.media and LibStub then
        local ok, lib = pcall(LibStub, "LibSharedMedia-3.0")
        if ok and lib then PCLcore.media = lib end
    end
    if not PCLcore.media and not PCLcore._lsmListenerCreated then
        local lsmWaiter = CreateFrame("Frame")
        lsmWaiter:RegisterEvent("ADDON_LOADED")
        lsmWaiter:SetScript("OnEvent", function(self)
            if LibStub then
                local ok, lib = pcall(LibStub, "LibSharedMedia-3.0")
                if ok and lib then
                    PCLcore.media = lib
                    PCLcore._lsmListenerCreated = true
                    if PCL_frames.RefreshLayout then PCL_frames:RefreshLayout() end
                    self:UnregisterEvent("ADDON_LOADED")
                end
            end
        end)
        PCLcore._lsmListenerCreated = true
    end

    if PCLcore.media then
        -- Existing advanced texture dropdown code retained
        local containerWidth = rightColumn:GetWidth()
        local dropdownContainer = CreateFrame("Button", nil, rightColumn, "BackdropTemplate")
        dropdownContainer:SetPoint("TOPLEFT", rightColumn, "TOPLEFT", 0, rightY)
        dropdownContainer:SetSize(containerWidth - 10, 40)
        dropdownContainer:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        dropdownContainer:SetBackdropColor(0.08,0.08,0.08,0.9)
        dropdownContainer:SetBackdropBorderColor(0.3,0.5,0.7,1)

        local selectedPreview = dropdownContainer:CreateTexture(nil, "ARTWORK")
        selectedPreview:SetPoint("LEFT", dropdownContainer, "LEFT", 8, 0)
        selectedPreview:SetSize(containerWidth - 120, 18)
        local selectedText = dropdownContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        selectedText:SetPoint("CENTER", selectedPreview, "CENTER", 0, 0)
        selectedText:SetTextColor(1,1,1,1)

        local dropdownArrow = dropdownContainer:CreateTexture(nil, "OVERLAY")
        dropdownArrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        dropdownArrow:SetSize(16,16)
        dropdownArrow:SetPoint("RIGHT", dropdownContainer, "RIGHT", -8, 0)

        local dropdownList = CreateFrame("Frame", nil, rightColumn, "BackdropTemplate")
        dropdownList:SetSize(containerWidth - 10, 230)
        dropdownList:SetPoint("TOPLEFT", dropdownContainer, "BOTTOMLEFT", 0, -2)
        dropdownList:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        dropdownList:SetBackdropColor(0.05,0.05,0.05,0.95)
        dropdownList:SetBackdropBorderColor(0.3,0.5,0.7,1)
        dropdownList:Hide()
        dropdownList:SetFrameStrata("DIALOG")

        local scrollFrame = CreateFrame("ScrollFrame", nil, dropdownList, "BackdropTemplate")
        scrollFrame:SetPoint("TOPLEFT", dropdownList, "TOPLEFT", 8, -8)
        scrollFrame:SetSize(containerWidth - 36, 214)
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollFrame:SetScrollChild(scrollChild)

        local textures = PCLcore.media:List("statusbar") or {}
        table.sort(textures)
        local buttonHeight = 28
        scrollChild:SetSize(containerWidth - 60, math.max(#textures * buttonHeight + 10, 214))

        scrollFrame:EnableMouseWheel(true)
        scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            local cur = self:GetVerticalScroll()
            local max = math.max(0, scrollChild:GetHeight() - self:GetHeight())
            self:SetVerticalScroll(math.max(0, math.min(max, cur - delta*30)))
        end)

        for i, texName in ipairs(textures) do
            local btn = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")
            btn:SetSize(scrollChild:GetWidth()-10, buttonHeight-2)
            btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -(i-1)*buttonHeight - 5)
            btn:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
            btn:SetBackdropColor(0.1,0.1,0.1,0.3)
            local preview = btn:CreateTexture(nil, "ARTWORK")
            preview:SetPoint("LEFT", btn, "LEFT", 6, 0)
            preview:SetSize(scrollChild:GetWidth()-140, 14)
            local file = PCLcore.media:Fetch("statusbar", texName)
            if file then preview:SetTexture(file) end
            local nameText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            nameText:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
            nameText:SetText(texName)
            btn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.2,0.5,0.8,0.5) end)
            btn:SetScript("OnLeave", function(self)
                if PCL_SETTINGS.statusBarTexture == texName then
                    self:SetBackdropColor(0.2,0.6,1,0.4)
                else
                    self:SetBackdropColor(0.1,0.1,0.1,0.3)
                end
            end)
            btn:SetScript("OnClick", function()
                PCL_SETTINGS.statusBarTexture = texName
                selectedText:SetText(texName)
                if file then selectedPreview:SetTexture(file) end
                dropdownList:Hide()
                -- Update all progress bars instantly
                if PCLcore.statusBarFrames then
                    for _, bar in ipairs(PCLcore.statusBarFrames) do
                        if bar and bar.SetStatusBarTexture then
                            local newFile = PCLcore.media:Fetch("statusbar", texName)
                            if newFile then bar:SetStatusBarTexture(newFile) end
                        end
                    end
                end
            end)
            if PCL_SETTINGS.statusBarTexture == texName then
                btn:SetBackdropColor(0.2,0.6,1,0.4)
            end
        end
        local currentTex = PCL_SETTINGS.statusBarTexture
        selectedText:SetText(currentTex)
        local curFile = PCLcore.media:Fetch("statusbar", currentTex)
        if curFile then selectedPreview:SetTexture(curFile) end
        dropdownContainer:SetScript("OnMouseDown", function()
            if dropdownList:IsShown() then dropdownList:Hide() else dropdownList:Show() end
        end)
        frame:HookScript("OnMouseDown", function() if dropdownList:IsShown() then dropdownList:Hide() end end)
        rightY = rightY - 60
    else
        local note = rightColumn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        note:SetPoint("TOPLEFT", rightColumn, "TOPLEFT", 5, rightY)
        note:SetText(L("LibSharedMedia not available - using default texture"))
        note:SetTextColor(0.8,0.4,0.4,1)
        rightY = rightY - 30
    end

    AddSectionHeader(rightColumn, L("Window Opacity"), true)
    AddSlider(rightColumn, L("Opacity"), "opacity", 0.1, 1.0, 0.05, true, true, true, function(val)
        if PCL_mainFrame and PCL_mainFrame.Bg then PCL_mainFrame.Bg:SetVertexColor(0,0,0,val) end
    end)

    AddSectionHeader(rightColumn, L("Utilities"), true)
    -- (Reset button retained)
    -- Styled reset button with confirmation popup
    local resetBtn = CreateFrame("Button", nil, rightColumn, "BackdropTemplate")
    resetBtn:SetSize(150, 34)
    resetBtn:SetPoint("TOPLEFT", rightColumn, "TOPLEFT", 0, rightY)
    resetBtn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    resetBtn:SetBackdropColor(0.6,0.1,0.1,0.85)
    resetBtn:SetBackdropBorderColor(0.8,0.2,0.2,1)
    local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    resetText:SetPoint("CENTER", resetBtn, "CENTER")
    resetText:SetText(L("Reset Settings"))

    resetBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.8,0.2,0.2,0.9) end)
    resetBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.6,0.1,0.1,0.85) end)
    resetBtn:SetScript("OnMouseDown", function(self) self:SetBackdropColor(0.4,0.1,0.1,0.9) end)
    resetBtn:SetScript("OnMouseUp", function(self) self:SetBackdropColor(0.8,0.2,0.2,0.9) end)

    resetBtn:SetScript("OnClick", function() 
        -- Create the popup dialog only when needed to avoid tainting StaticPopupDialogs during initialization
        StaticPopupDialogs = StaticPopupDialogs or {}
        StaticPopupDialogs["PCL_RESET_SETTINGS"] = {
            text = L("Are you sure you want to reset all PCL settings?"),
            button1 = YES,
            button2 = NO,
            OnAccept = function()
                PCL_SETTINGS.useBlizzardTheme = false
                PCL_SETTINGS.hideCollectedPets = false
                PCL_SETTINGS.PetsPerRow = 12
                PCL_SETTINGS.opacity = 0.95
                PCL_SETTINGS.statusBarTexture = "Blizzard"
                PCL_SETTINGS.enablePetCardOnHover = true
                PCL_SETTINGS.showMinimapIcon = true
                PCL_SETTINGS.minimapIcon = { hide = false }
                
                -- Update minimap icon visibility
                local LibDBIcon = LibStub("LibDBIcon-1.0", true)
                if LibDBIcon then
                    LibDBIcon:Show("PCL")
                end
                
                if PCL_frames.RefreshLayout then PCL_frames:RefreshLayout() end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("PCL_RESET_SETTINGS") 
    end)
    rightY = rightY - 50

    return frame
end

-- Utility: current frame dimensions (fallback to defaults if not yet created)
function PCL_frames:GetCurrentFrameDimensions()
    if PCL_mainFrame and PCL_mainFrame.GetSize then
        local w, h = PCL_mainFrame:GetSize()
        if w and h and w > 0 and h > 0 then
            return w, h
        end
    end
    return main_frame_width, main_frame_height
end

-- Open internal Settings tab (fallback to Blizzard Settings if tab unavailable)
function PCL_frames:openSettings()
    -- Ensure main frame exists and is visible
    if not PCL_mainFrame then
        if self.CreateMainFrame then self:CreateMainFrame() end
    end
    if PCL_mainFrame and not PCL_mainFrame:IsShown() then
        PCL_mainFrame:Show()
    end
    -- Build tabs if not yet built
    if (not PCLcore.PCL_MF_Nav) or (not PCLcore.PCL_MF_Nav.tabs) or (#PCLcore.PCL_MF_Nav.tabs == 0) then
        if self.SetTabs then self:SetTabs() end
    end
    -- Try to locate Settings tab
    if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
        for _, tab in ipairs(PCLcore.PCL_MF_Nav.tabs) do
            if tab.section and tab.section.name == "Settings" and tab:GetScript("OnClick") then
                tab:GetScript("OnClick")(tab)
                return
            end
        end
    end
    -- Fallback: open Blizzard's Settings category if available
    if Settings and Settings.OpenToCategory and PCLcore.addon_name then
        pcall(Settings.OpenToCategory, PCLcore.addon_name)
    end
end