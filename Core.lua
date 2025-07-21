local _, PCLcore = ...;

-- Initialize LibSharedMedia for statusbar textures
local function InitializeLibSharedMedia()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        PCLcore.media = LSM
    else
        PCLcore.media = nil
    end
end

-- Initialize DataBroker and minimap functionality when addon loads
local function InitializeMinimapIcon()
    -- This will be called from main.lua after settings are initialized
    if PCLcore.Function and PCLcore.Function.AddonSettings then
        -- Settings initialization will handle minimap icon registration
        return true
    end
    return false
end

-- Initialize search functionality when the addon loads
local function InitializeSearch()
    if not PCLcore.Search then
        -- Search functionality namespace
        PCLcore.Search = {}

        -- Search state
        PCLcore.Search.searchResults = {}
        PCLcore.Search.currentSearchTerm = ""
        PCLcore.Search.isSearchActive = false

        -- Search functionality
        function PCLcore.Search:PerformSearch(searchTerm)
            if not searchTerm or searchTerm == "" then
                self:ClearSearch()
                return
            end
            
            -- Remove leading and trailing whitespace
            searchTerm = searchTerm:gsub("^%s*(.-)%s*$", "%1")
            if searchTerm == "" then
                self:ClearSearch()
                return
            end
            
            self.currentSearchTerm = searchTerm:lower()
            self.isSearchActive = true
            self.searchResults = {}
            
            local isClassic = PCLcore.Function:IsClassicWoW()
            
            -- Search through all pets in all sections
            for sectionIndex, section in ipairs(PCLcore.sectionNames) do
                -- Skip sections not compatible with Classic if we're on Classic
                if isClassic and section.includeInClassic == false then
                    -- skip sections not available in Classic
                else
                    -- Check if section has pets data
                    if section.pets and section.pets.categories then
                        local categories = section.pets.categories
                        if categories then
                            for categoryName, categoryData in pairs(categories) do
                                if type(categoryData) == "table" and categoryData.pets then
                                    -- Use the pets array from the category data
                                    local petList = categoryData.pets or {}
                                    
                                    for _, petId in ipairs(petList) do
                                        local pet_Id = PCLcore.Function:GetPetID(petId)
                                        if pet_Id then
                                            local petName, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoBySpeciesID(pet_Id)
                                            
                                            -- Skip pets that don't exist (return nil from GetPetInfoBySpeciesID)
                                            if not petName then
                                                -- Pet doesn't exist in this version of WoW, skip it
                                            else
                                                local isCollected = IsPetCollected(pet_Id)
                                            
                                                -- Skip collected pets if the setting is enabled
                                                if PCL_SETTINGS.hideCollectedPets and isCollected then
                                                    -- Skip this pet entirely
                                                else
                                            -- Search both pet name and item name (if applicable)
                                            local matchFound = false
                                            local matchedName = nil
                                            local searchTerm = self.currentSearchTerm
                                            
                                            -- Check pet name
                                            if petName and petName:lower():find(searchTerm, 1, true) then
                                                matchFound = true
                                                matchedName = petName
                                            end
                                            
                                            -- If pet has an item ID, also check the item name
                                            if not matchFound and type(petId) == "number" then
                                                local itemName = GetItemInfo(petId)
                                                if itemName and itemName:lower():find(searchTerm, 1, true) then
                                                    matchFound = true
                                                    matchedName = itemName
                                                end
                                            end
                                            
                                            if matchFound then
                                                table.insert(self.searchResults, {
                                                    PetId = petId,
                                                    PetName = petName,
                                                    matchedName = matchedName,
                                                    icon = icon,
                                                    petType = petType,
                                                    section = section.name,
                                                    category = categoryData.name or categoryName,
                                                    isCollected = isCollected
                                                })
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                end
            end
            end
            
            -- Display search results
            self:DisplaySearchResults()
        end        function PCLcore.Search:ClearSearch()
            self.currentSearchTerm = ""
            self.isSearchActive = false
            self.searchResults = {}
            
            -- Clear any highlighting
            self:ClearHighlighting()
            
            -- Properly destroy search results content frame
            self:DestroySearchResultsFrame()
            
            -- Clear search text in navigation frame
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.searchBox then
                PCLcore.PCL_MF_Nav.searchBox:SetText("")
                if PCLcore.PCL_MF_Nav.searchPlaceholder then
                    PCLcore.PCL_MF_Nav.searchPlaceholder:Show()
                end
            end
            
            -- Restore the previously selected tab using the proper SelectTab function
            if self.previouslySelectedTab then
                -- We need to call the SelectTab function from frames.lua
                -- Since it's local, we'll replicate its logic here
                if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
                    -- Deselect all tabs first
                    for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                        if t.SetBackdropBorderColor then
                            t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                        end
                    end
                    -- Hide all tab contents
                    for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                        if t.content then
                            t.content:Hide()
                        end
                    end
                    -- Restore the selected tab
                    if self.previouslySelectedTab.SetBackdropBorderColor then
                        self.previouslySelectedTab:SetBackdropBorderColor(1, 0.82, 0, 1)
                    end
                    if self.previouslySelectedTab.content and PCL_mainFrame.ScrollFrame then
                        -- Always keep the main scroll child as the scroll child
                        PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                        self.previouslySelectedTab.content:Show()
                        PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
                    end
                    -- Update global reference
                    PCLcore.currentlySelectedTab = self.previouslySelectedTab
                end
                self.previouslySelectedTab = nil
            end
        end

        function PCLcore.Search:ClearSearchAndGoToOverview()
            self.currentSearchTerm = ""
            self.isSearchActive = false
            self.searchResults = {}
            
            -- Clear any highlighting
            self:ClearHighlighting()
            
            -- Properly destroy search results content frame
            self:DestroySearchResultsFrame()
            
            -- Clear search text in navigation frame
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.searchBox then
                PCLcore.PCL_MF_Nav.searchBox:SetText("")
                if PCLcore.PCL_MF_Nav.searchPlaceholder then
                    PCLcore.PCL_MF_Nav.searchPlaceholder:Show()
                end
            end
            
            -- Always go to Overview tab regardless of previous selection
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
                -- Find the Overview tab (should be the first one)
                local overviewTab = nil
                for _, tab in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                    if tab.section and tab.section.name == "Overview" then
                        overviewTab = tab
                        break
                    end
                end
                
                if overviewTab then
                    -- Deselect all tabs first
                    for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                        if t.SetBackdropBorderColor then
                            t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                        end
                    end
                    -- Hide all tab contents using the proper HideAllTabContents function
                    if PCLcore.HideAllTabContents then
                        PCLcore.HideAllTabContents()
                    else
                        -- Fallback: Hide all tab contents manually
                        for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                            if t.content then
                                t.content:Hide()
                            end
                        end
                    end
                    -- Select the Overview tab
                    if overviewTab.SetBackdropBorderColor then
                        overviewTab:SetBackdropBorderColor(1, 0.82, 0, 1)
                    end
                    if overviewTab.content and PCL_mainFrame.ScrollFrame then
                        -- Always keep the main scroll child as the scroll child
                        PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                        overviewTab.content:Show()
                        PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
                    end
                    -- Update global reference
                    PCLcore.currentlySelectedTab = overviewTab
                end
            end
            
            -- Clear the previously selected tab since we're defaulting to Overview
            self.previouslySelectedTab = nil
        end
        function PCLcore.Search:DisplaySearchResults()
            if not PCL_mainFrame then return end
            
            -- Store the currently selected tab so we can restore it later
            if PCLcore.currentlySelectedTab and not self.previouslySelectedTab then
                self.previouslySelectedTab = PCLcore.currentlySelectedTab
            end
            
            -- Hide all tab contents first
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
                for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                    if t.content then
                        t.content:Hide()
                    end
                end
                -- Deselect all tabs visually
                for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                    if t.SetBackdropBorderColor then
                        t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                    end
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
            
            -- Create or get search results content frame
            if not PCLcore.searchResultsContent then
                PCLcore.searchResultsContent = PCLcore.Frames:createContentFrame(PCL_mainFrame.ScrollChild, "Search Results")
                -- Ensure search results content is properly layered
                PCLcore.searchResultsContent:SetFrameStrata("MEDIUM")
                PCLcore.searchResultsContent:SetFrameLevel(10)
            end
            
            -- Update search results content
            self:UpdateSearchResultsContent()
            
            -- Show search results in main frame
            if PCL_mainFrame.ScrollFrame then
                -- Always keep the main scroll child as the scroll child
                PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                PCLcore.searchResultsContent:Show()
                PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
            end
        end        function PCLcore.Search:UpdateSearchResultsContent()
            if not PCLcore.searchResultsContent then return end
            
            local content = PCLcore.searchResultsContent
            
            -- Clear existing content more thoroughly
            -- First hide and remove all children except the title
            for i = content:GetNumChildren(), 1, -1 do
                local child = select(i, content:GetChildren())
                if child and child ~= content.title then
                    child:Hide()
                    child:SetParent(nil)
                end
            end
            
            -- Also clear any FontStrings that were created directly on the content frame
            -- We need to track and clear these separately since they're not children
            if content.searchFontStrings then
                for _, fontString in ipairs(content.searchFontStrings) do
                    if fontString then
                        fontString:Hide()
                        fontString:SetParent(nil)
                    end
                end
            end
            content.searchFontStrings = {}
            
            -- Update title
            content.title:SetText(string.format("Search Results: '%s' (%d found)", self.currentSearchTerm, #self.searchResults))
            
            if #self.searchResults == 0 then
                -- Show no results message
                if not content.noResultsText then
                    content.noResultsText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    content.noResultsText:SetPoint("TOP", content.title, "BOTTOM", 0, -20)
                    content.noResultsText:SetTextColor(0.7, 0.7, 0.7, 1)
                    table.insert(content.searchFontStrings, content.noResultsText)
                end
                content.noResultsText:SetText("No Pets found matching your search.")
                content.noResultsText:Show()
                return
            else
                if content.noResultsText then
                    content.noResultsText:Hide()
                end
            end
            
            -- Group results by section, then by category
            local groupedResults = {}
            for _, result in ipairs(self.searchResults) do
                if not groupedResults[result.section] then
                    groupedResults[result.section] = {}
                end
                if not groupedResults[result.section][result.category] then
                    groupedResults[result.section][result.category] = {}
                end
                table.insert(groupedResults[result.section][result.category], result)
            end
            
            -- Calculate layout dimensions
            local currentWidth, _ = PCLcore.Frames:GetCurrentFrameDimensions()
            local availableWidth = currentWidth - 60
            
            -- Start with user's preferred Pets per row
            local PetsPerRow = PCL_SETTINGS.PetsPerRow or 12  -- Use setting or default to 12
            -- Ensure it's within bounds
            PetsPerRow = math.max(6, math.min(PetsPerRow, 24))
            
            -- Calculate Pet size to fit exactly within available width
            local desiredSpacing = 4  -- Fixed spacing between Pets
            local minPetSize = 16  -- Absolute minimum Pet size
            local maxPetSize = 48  -- Maximum Pet size
            
            -- Try the preferred Pets per row first
            local totalSpacingWidth = desiredSpacing * (PetsPerRow - 1)
            local availableForPets = availableWidth - totalSpacingWidth
            local PetSize = math.floor(availableForPets / PetsPerRow)
            
            -- If Pet size is too small, reduce Pets per row until we get acceptable size
            local originalPetsPerRow = PetsPerRow
            while PetSize < minPetSize and PetsPerRow > 6 do
                PetsPerRow = PetsPerRow - 1
                totalSpacingWidth = desiredSpacing * (PetsPerRow - 1)
                availableForPets = availableWidth - totalSpacingWidth
                PetSize = math.floor(availableForPets / PetsPerRow)
            end
            
            -- If we had to reduce pets per row due to space constraints, inform the user
            if PetsPerRow < originalPetsPerRow then
                print(string.format("|cff00ff00PCL:|r Pets per row reduced from %d to %d due to screen space limitations. Each pet needs at least %dpx.", originalPetsPerRow, PetsPerRow, minPetSize))
                -- Note: We don't update the saved setting - this is a display-only adjustment
            end
            
            -- Ensure Pet size is within bounds
            PetSize = math.max(minPetSize, math.min(PetSize, maxPetSize))
            
            -- Recalculate actual spacing to center the grid
            local actualPetWidth = PetSize * PetsPerRow
            local spacing = PetsPerRow > 1 and math.floor((availableWidth - actualPetWidth) / (PetsPerRow - 1)) or 0
            spacing = math.max(1, spacing)  -- Minimum 1px spacing
            
            local currentY = -80 -- Start below title
            local PetIndex = 0
            
            -- Display results grouped by section and category
            for sectionName, sectionData in pairs(groupedResults) do
                -- Create section header
                local sectionHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                sectionHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, currentY)
                sectionHeader:SetText(sectionName)
                sectionHeader:SetTextColor(1, 0.82, 0, 1) -- Gold color like Blizzard UI
                table.insert(content.searchFontStrings, sectionHeader)
                currentY = currentY - 25
                
                for categoryName, categoryPets in pairs(sectionData) do
                    -- Create category header
                    local categoryHeader = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    categoryHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 20, currentY)
                    categoryHeader:SetText(categoryName .. " (" .. #categoryPets .. ")")
                    categoryHeader:SetTextColor(0.8, 0.8, 1, 1) -- Light blue color
                    table.insert(content.searchFontStrings, categoryHeader)
                    currentY = currentY - 20
                    
                    -- Display Pets for this category
                    local categoryStartY = currentY
                    local categoryPetIndex = 0
                    
                    for _, result in ipairs(categoryPets) do
                        local col = (categoryPetIndex % PetsPerRow)
                        local row = math.floor(categoryPetIndex / PetsPerRow)
                        
                        local x = spacing + col * (PetSize + spacing)
                        local y = categoryStartY - row * (PetSize + 10)
                          -- Create Pet frame
                        local PetFrame = CreateFrame("Button", nil, content, "BackdropTemplate")
                        PetFrame:SetSize(PetSize, PetSize)
                        PetFrame:SetPoint("TOPLEFT", content, "TOPLEFT", x, y)
                        
                        -- Set Pet icon
                        PetFrame.tex = PetFrame:CreateTexture(nil, "ARTWORK")
                        PetFrame.tex:SetAllPoints(PetFrame)
                        PetFrame.tex:SetTexture(result.icon)
                          -- Add pin functionality (required for pin/unpin operations)
                        PetFrame.pin = PetFrame:CreateTexture(nil, "OVERLAY")
                        PetFrame.pin:SetWidth(16)
                        PetFrame.pin:SetHeight(16)
                        PetFrame.pin:SetTexture("Interface\\AddOns\\PCL\\icons\\pin.blp")
                        PetFrame.pin:SetPoint("TOPRIGHT", PetFrame, "TOPRIGHT", -2, -2)
                        PetFrame.pin:SetAlpha(0)
                        
                        -- Set pet properties for functionality
                        PetFrame.petID = result.PetId  -- Use petID instead of PetID
                        PetFrame.category = result.category
                        PetFrame.section = result.section
                        
                        -- Check if pet is already pinned and show pin icon if needed
                        local isPinned, pinIndex = PCLcore.Function:CheckIfPinned(result.PetId)
                        if isPinned then
                            PetFrame.pin:SetAlpha(1)
                        end                        -- Style based on collection status
                        -- Note: With hideCollectedPets enabled, collected Pets won't be in search results
                        if result.isCollected then
                            PetFrame.tex:SetVertexColor(1, 1, 1, 1)
                            PetFrame:SetBackdrop({
                                bgFile = "Interface\\Buttons\\WHITE8x8",
                                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                                edgeSize = 2
                            })
                            PetFrame:SetBackdropColor(0, 0.8, 0, 0.6)
                            PetFrame:SetBackdropBorderColor(0, 1, 0, 1)
                        else
                            PetFrame.tex:SetVertexColor(0.4, 0.4, 0.4, 0.7)
                            PetFrame:SetBackdrop({
                                bgFile = "Interface\\Buttons\\WHITE8x8",
                                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                                edgeSize = 2
                            })
                            PetFrame:SetBackdropColor(0.8, 0, 0, 0.4)
                            PetFrame:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
                        end                        -- Add pet preview functionality (mouseover frame)
                        PetFrame:SetScript("OnEnter", function(self)
                            -- Show the pet preview frame
                            local petSpeciesID = PCLcore.Function:GetPetID(result.PetId)
                            if petSpeciesID and PCLcore.Function.ShowPetPreview then
                                PCLcore.Function:ShowPetPreview(petSpeciesID, self)
                            end
                        end)
                        PetFrame:SetScript("OnLeave", function(self)
                            -- Hide the pet preview frame
                            if PCLcore.Function.HidePetPreview then
                                PCLcore.Function:HidePetPreview()
                            end
                        end)
                        
                        -- Set up proper pet click functionality
                        local petSpeciesID = PCLcore.Function:GetPetID(result.PetId)
                        if petSpeciesID and PCLcore.Function.SetPetClickFunctionality then
                            PCLcore.Function:SetPetClickFunctionality(PetFrame, petSpeciesID, result.PetName, nil, result.matchedName)
                        end
                        
                        -- Add LinkPetItem functionality for complete pet interaction support
                        if PCLcore.Function.LinkPetItem then
                            PCLcore.Function:LinkPetItem(result.PetId, PetFrame, false)
                        end
                        
                        -- Override the OnMouseDown handler to include navigation for search results
                        local originalOnMouseDown = PetFrame:GetScript("OnMouseDown")
                        PetFrame:SetScript("OnMouseDown", function(self, button)
                            if button == "LeftButton" and not IsControlKeyDown() and not IsShiftKeyDown() then
                                -- Navigate to the pet's location for search results
                                PCLcore.Search:NavigateToPet(result)
                            else
                                -- Call the original OnMouseDown handler for other functionality
                                if originalOnMouseDown then
                                    originalOnMouseDown(self, button)
                                end
                            end
                        end)
                        
                        -- Ensure mouse interaction is enabled
                        PetFrame:EnableMouse(true)
                        PetFrame:SetFrameStrata("HIGH")
                        PetFrame:SetFrameLevel(10)
                        
                        categoryPetIndex = categoryPetIndex + 1
                    end
                    
                    -- Calculate how much Y space this category used
                    local categoryRows = math.ceil(#categoryPets / PetsPerRow)
                    currentY = categoryStartY - categoryRows * (PetSize + 10) - 10 -- Add some spacing after category
                end
                
                -- Add extra spacing after each section
                currentY = currentY - 10
            end
        end
        function PCLcore.Search:NavigateToPet(result)
            -- Store the target section for navigation
            local targetSection = result.section
            
            -- Clear search state without restoring previous tab
            self.currentSearchTerm = ""
            self.isSearchActive = false
            self.searchResults = {}
            
            -- Clear any highlighting
            self:ClearHighlighting()
            
            -- Properly destroy search results content frame
            self:DestroySearchResultsFrame()
            
            -- Clear search box text
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.searchBox then
                PCLcore.PCL_MF_Nav.searchBox:SetText("")
                if PCLcore.PCL_MF_Nav.searchPlaceholder then
                    PCLcore.PCL_MF_Nav.searchPlaceholder:Show()
                end
            end
            
            -- Clear the previously selected tab reference
            self.previouslySelectedTab = nil
            
            -- Find and select the correct tab for this section
            if PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
                for i, tab in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                    if tab.section and tab.section.name == targetSection then
                        -- Use the proper tab selection logic (same as SelectTab function)
                        -- Deselect all tabs first
                        for _, t in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                            if t.SetBackdropBorderColor then
                                t:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                            end
                        end
                        
                        -- Hide all tab contents using the proper HideAllTabContents function
                        if PCLcore.HideAllTabContents then
                            PCLcore.HideAllTabContents()
                        end
                        
                        -- Select the target tab
                        if tab.SetBackdropBorderColor then
                            tab:SetBackdropBorderColor(1, 0.82, 0, 1)
                        end
                        if tab.content and PCL_mainFrame.ScrollFrame then
                            -- Always keep the main scroll child as the scroll child
                            PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                            tab.content:Show()
                            PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
                        end
                        -- Update global reference
                        PCLcore.currentlySelectedTab = tab
                        break
                    end
                end
            end
            
            -- Store the Pet to highlight for later
            PCLcore.Search.highlightPetId = result.PetId
            
            -- Schedule highlighting for next frame to ensure content is loaded
            C_Timer.After(0.1, function()
                PCLcore.Search:HighlightPet(result.PetId)
            end)
            
            -- Print info for user feedback
            print("|cff00CCFFPet Collection Log:|r Found '" .. result.PetName .. "' in " .. result.section .. " > " .. result.category)
        end

        function PCLcore.Search:ClearHighlighting()
            -- Clear any existing highlighting effects
            if PCLcore.highlightedPetFrame then
                if PCLcore.highlightedPetFrame.originalBorderColor then
                    PCLcore.highlightedPetFrame:SetBackdropBorderColor(
                        PCLcore.highlightedPetFrame.originalBorderColor[1],
                        PCLcore.highlightedPetFrame.originalBorderColor[2],
                        PCLcore.highlightedPetFrame.originalBorderColor[3],
                        PCLcore.highlightedPetFrame.originalBorderColor[4]
                    )
                end
                if PCLcore.highlightedPetFrame.highlightTimer then
                    PCLcore.highlightedPetFrame.highlightTimer:Cancel()
                end
                PCLcore.highlightedPetFrame = nil
            end
        end

        function PCLcore.Search:HighlightPet(PetId)
            -- Clear any existing highlighting
            self:ClearHighlighting()
            
            -- Find the Pet frame in the current content
            local currentContent = PCL_mainFrame.ScrollFrame:GetScrollChild()
            if not currentContent then return end
            
            -- Look for pet frames that match our target pet
            local function FindPetFrame(parent)
                for i = 1, parent:GetNumChildren() do
                    local child = select(i, parent:GetChildren())
                    if child and child.petID then
                        local pet_Id = PCLcore.Function:GetPetID(child.petID)
                        local target_Id = PCLcore.Function:GetPetID(PetId)
                        if pet_Id and target_Id and pet_Id == target_Id then
                            return child
                        end
                    end
                    -- Recursively search children
                    local found = FindPetFrame(child)
                    if found then return found end
                end
            end
            
            local PetFrame = FindPetFrame(currentContent)
            if PetFrame then
                -- Store original border color
                local r, g, b, a = PetFrame:GetBackdropBorderColor()
                PetFrame.originalBorderColor = {r, g, b, a}
                
                -- Store reference for cleanup
                PCLcore.highlightedPetFrame = PetFrame
                
                -- Create pulsing highlight effect
                local pulseTimer
                local pulseCount = 0
                local maxPulses = 6
                
                pulseTimer = C_Timer.NewTicker(0.5, function()
                    pulseCount = pulseCount + 1
                    if pulseCount > maxPulses then
                        -- Restore original color and stop
                        if PetFrame.originalBorderColor then
                            PetFrame:SetBackdropBorderColor(
                                PetFrame.originalBorderColor[1],
                                PetFrame.originalBorderColor[2],
                                PetFrame.originalBorderColor[3],
                                PetFrame.originalBorderColor[4]
                            )
                        end
                        pulseTimer:Cancel()
                        PCLcore.highlightedPetFrame = nil
                        return
                    end
                    
                    -- Pulse between yellow and original color
                    if pulseCount % 2 == 1 then
                        PetFrame:SetBackdropBorderColor(1, 1, 0, 1) -- Bright yellow
                    else
                        PetFrame:SetBackdropBorderColor(
                            PetFrame.originalBorderColor[1],
                            PetFrame.originalBorderColor[2],
                            PetFrame.originalBorderColor[3],
                            PetFrame.originalBorderColor[4]
                        )
                    end
                end)
                
                PetFrame.highlightTimer = pulseTimer
                
                -- Scroll to the Pet if needed
                local frameTop = currentContent:GetTop()
                local frameBottom = currentContent:GetBottom()
                local PetTop = PetFrame:GetTop()
                local PetBottom = PetFrame:GetBottom()
                
                if frameTop and frameBottom and PetTop and PetBottom then
                    local scrollFrame = PCL_mainFrame.ScrollFrame
                    local scrollTop = scrollFrame:GetTop()
                    local scrollBottom = scrollFrame:GetBottom()
                    
                    -- Check if Pet is not visible in scroll area
                    if PetTop > scrollTop or PetBottom < scrollBottom then
                        -- Calculate scroll position to center the Pet
                        local scrollHeight = scrollFrame:GetVerticalScrollRange()
                        local contentHeight = frameTop - frameBottom
                        local PetCenter = (PetTop + PetBottom) / 2
                        local targetScroll = (frameTop - PetCenter) / contentHeight * scrollHeight
                        
                        -- Clamp to valid scroll range
                        targetScroll = math.max(0, math.min(targetScroll, scrollHeight))
                        scrollFrame:SetVerticalScroll(targetScroll)
                    end
                end
            end
        end
        
        function PCLcore.Search:RecreateSearchResultsFrame()
            if not PCLcore.searchResultsContent then return end
            
            -- Hide and remove the old search results content frame
            PCLcore.searchResultsContent:Hide()
            PCLcore.searchResultsContent:SetParent(nil)
            PCLcore.searchResultsContent = nil
            
            -- Create new search results content frame with updated dimensions
            PCLcore.searchResultsContent = PCLcore.Frames:createContentFrame(PCL_mainFrame.ScrollChild, "Search Results")
            
            -- Update the content
            self:UpdateSearchResultsContent()
            
            -- Show the new frame
            if PCL_mainFrame.ScrollFrame then
                -- Always keep the main scroll child as the scroll child
                PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                PCLcore.searchResultsContent:Show()
                PCL_mainFrame.ScrollFrame:SetVerticalScroll(0)
            end
        end
        
        function PCLcore.Search:DestroySearchResultsFrame()
            if PCLcore.searchResultsContent then
                -- Hide and remove the search results content frame
                PCLcore.searchResultsContent:Hide()
                PCLcore.searchResultsContent:SetParent(nil)
                PCLcore.searchResultsContent = nil
                
                -- Ensure the main scroll child is set as the scroll child
                if PCL_mainFrame.ScrollFrame and PCL_mainFrame.ScrollChild then
                    PCL_mainFrame.ScrollFrame:SetScrollChild(PCL_mainFrame.ScrollChild)
                end
            end
        end
    end
end

-- Make initialization functions available globally so they can be called when addon loads
PCLcore = PCLcore or {}
PCLcore.InitializeSearch = InitializeSearch
PCLcore.InitializeLibSharedMedia = InitializeLibSharedMedia
PCLcore.InitializeMinimapIcon = InitializeMinimapIcon

-- Namespace
-------------------------------------------------------------

SLASH_PCL1 = "/PCL";

SlashCmdList["PCL"] = function(msg)
    if msg:lower() == "help" then
        print(PCLcore.L["|cff00CCFFPet Collection Log Commands:\n|cffFF0000Show:|cffFFFFFF Shows your Pet collection log\n|cffFF0000Icon:|cffFFFFFF Toggles the minimap icon\n|cffFF0000Config:|cffFFFFFF Opens the settings\n|cffFF0000Help:|cffFFFFFF Shows commands"])
        print("|cffFF0000Notification Commands:|r")
        print("|cffFFFFFF/pcl resetnotify|r - Reset notification status")
        print("|cffFFFFFF/pcl testwelcome|r - Show welcome notification")
        print("|cffFFFFFF/pcl testupdate|r - Show update notification")
        print("|cffFFFFFF/pcl checknotify|r - Check for notifications now")
    end
    if msg:lower() == "show" then
        PCLcore.Main.Toggle();
    end
    if msg:lower() == "icon" then
        if PCLcore.Function and PCLcore.Function.PCL_MM then
            PCLcore.Function:PCL_MM();
        else
            print("|cffFF0000PCL:|r Minimap functionality not available yet. Please reload your UI.")
        end
    end        
    if msg:lower() == "" then
        PCLcore.Main.Toggle();
    end
    if msg:lower() == "debug" then
        PCLcore.Function:GetCollectedPets();
    end
    if msg:lower() == "config" or msg == "settings" then
        PCLcore.Frames:openSettings();
    end
    if msg:lower() == "refresh" then
        if PCLcore.Main and type(PCLcore.Main.Init) == "function" then
            PCLcore.Main:Init(true)  -- True to force re-initialization.
        end
    end
    if msg:lower() == "status" then
        print("PCL Status:")
        print("- dataLoaded:", PCLcore.dataLoaded)
        print("- PCL_MF exists:", PCLcore.PCL_MF ~= nil)
        local numPets, numOwned = C_PetJournal.GetNumPets()
        print("- Pet Journal - Total pets:", numPets, "Owned:", numOwned)
        print("- Collections addon loaded:", C_AddOns.IsAddOnLoaded("Blizzard_Collections"))
        print("- Minimap icon hidden:", PCL_SETTINGS.minimap and PCL_SETTINGS.minimap.hide or "Unknown")
    end
    -- Notification commands
    if msg:lower() == "resetnotify" then
        local notifications = (PCL and PCL.Notifications) or (PCLcore and PCLcore.Notifications)
        if notifications and notifications.ResetNotificationStatus then
            notifications:ResetNotificationStatus()
        else
            print("|cffFF0000PCL:|r Notification system not available yet. Try reloading your UI (/reload).")
        end
    end
    if msg:lower() == "testwelcome" then
        local notifications = (PCL and PCL.Notifications) or (PCLcore and PCLcore.Notifications)
        if notifications and notifications.ForceShowNotification then
            notifications:ForceShowNotification("welcome")
        else
            print("|cffFF0000PCL:|r Notification system not available yet. Try reloading your UI (/reload).")
        end
    end
    if msg:lower() == "testupdate" then
        local notifications = (PCL and PCL.Notifications) or (PCLcore and PCLcore.Notifications)
        if notifications and notifications.ForceShowNotification then
            notifications:ForceShowNotification("update")
        else
            print("|cffFF0000PCL:|r Notification system not available yet. Try reloading your UI (/reload).")
        end
    end
    if msg:lower() == "checknotify" then
        local notifications = (PCL and PCL.Notifications) or (PCLcore and PCLcore.Notifications)
        if notifications and notifications.TriggerCheck then
            notifications:TriggerCheck()
        else
            print("|cffFF0000PCL:|r Notification system not available yet. Try reloading your UI (/reload).")
        end
    end
 end
