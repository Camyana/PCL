-- Sample PetCard Breed Integration
-- Add these functions to your PetCard.lua to display breed information

-- This function should be added to your PetCard.lua after the breeds.lua file is loaded

--[[
  Get breed information for a pet species
  @param speciesID - The pet species ID from C_PetJournal
  @return table with breed information or nil if not found
]]
local function GetPetBreedInfo(speciesID)
    if not speciesID or not PCLcore.breedData then
        return nil
    end
    
    local species = PCLcore.breedData.species[speciesID]
    if not species or not species.breeds then
        return nil
    end
    
    local breedInfo = {
        speciesID = speciesID,
        availableBreeds = {},
        defaultBreed = species.breeds[1] -- First available breed as default
    }
    
    -- Get breed names and details
    for _, breedID in ipairs(species.breeds) do
        local breedName = PCLcore.GetBreedName(breedID)
        local modifiers = PCLcore.GetBreedModifiers(breedID)
        
        table.insert(breedInfo.availableBreeds, {
            id = breedID,
            name = breedName,
            modifiers = modifiers
        })
    end
    
    return breedInfo
end

--[[
  Create breed display section for PetCard
  @param parent - The parent frame
  @param speciesID - The pet species ID
  @param yOffset - Current Y offset for positioning
  @return new Y offset after breed section
]]
local function CreateBreedSection(parent, speciesID, yOffset)
    if not parent or not speciesID then
        return yOffset
    end
    
    local breedInfo = GetPetBreedInfo(speciesID)
    if not breedInfo then
        return yOffset -- No breed data available
    end
    
    -- Create breed header
    local breedHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    breedHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
    breedHeader:SetText("Available Breeds:")
    breedHeader:SetTextColor(1, 0.82, 0) -- Gold color
    
    yOffset = yOffset - 25
    
    -- Display available breeds
    local maxBreedsPerRow = 3
    local breedCount = #breedInfo.availableBreeds
    local currentRow = 0
    local currentCol = 0
    
    for i, breed in ipairs(breedInfo.availableBreeds) do
        local breedButton = CreateFrame("Button", nil, parent)
        breedButton:SetSize(80, 25)
        
        -- Position the button
        local xPos = 15 + (currentCol * 90)
        local yPos = yOffset - (currentRow * 30)
        breedButton:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, yPos)
        
        -- Create breed text
        local breedText = breedButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        breedText:SetPoint("CENTER", breedButton, "CENTER", 0, 0)
        breedText:SetText(breed.name)
        breedText:SetTextColor(0.8, 0.8, 1) -- Light blue
        
        -- Create background
        local bg = breedButton:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(breedButton)
        bg:SetColorTexture(0.2, 0.2, 0.4, 0.6)
        
        -- Hover effects
        breedButton:SetScript("OnEnter", function(self)
            bg:SetColorTexture(0.3, 0.3, 0.6, 0.8)
            
            -- Show breed tooltip
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(breed.name, 1, 1, 1)
            
            if breed.modifiers then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Stat Allocation:", 1, 0.82, 0)
                GameTooltip:AddLine(string.format("Health: +%.1f", breed.modifiers.health), 0.8, 1, 0.8)
                GameTooltip:AddLine(string.format("Power: +%.1f", breed.modifiers.power), 1, 0.8, 0.8)
                GameTooltip:AddLine(string.format("Speed: +%.1f", breed.modifiers.speed), 0.8, 0.8, 1)
            end
            
            GameTooltip:Show()
        end)
        
        breedButton:SetScript("OnLeave", function(self)
            bg:SetColorTexture(0.2, 0.2, 0.4, 0.6)
            GameTooltip:Hide()
        end)
        
        -- Handle clicking (you can extend this for breed selection)
        breedButton:SetScript("OnClick", function(self)
            -- Selected breed for species
            -- Here you could implement breed preference saving
        end)
        
        -- Move to next position
        currentCol = currentCol + 1
        if currentCol >= maxBreedsPerRow then
            currentCol = 0
            currentRow = currentRow + 1
        end
    end
    
    -- Calculate new yOffset based on number of rows used
    local rowsUsed = math.ceil(breedCount / maxBreedsPerRow)
    yOffset = yOffset - (rowsUsed * 30) - 10 -- Extra padding
    
    return yOffset
end

--[[
  Example of how to integrate breed display into your existing PetCard
  Add this call in your PetCard display function where appropriate
]]
local function IntegrateBreedDisplay()
    -- This would be called from your main PetCard display function
    -- Example usage:
    
    --[[
    In your PetCard display function, add something like:
    
    -- After displaying basic pet info, add breed section
    if speciesID then
        currentYOffset = CreateBreedSection(petCardFrame, speciesID, currentYOffset)
    end
    ]]
    
    -- Breed display integration ready
end

-- Export functions for use in PetCard
PCLcore.PetCard.GetPetBreedInfo = GetPetBreedInfo
PCLcore.PetCard.CreateBreedSection = CreateBreedSection
PCLcore.PetCard.IntegrateBreedDisplay = IntegrateBreedDisplay

-- Example test function
local function TestBreedData()
    -- Test with a common pet species ID
    local testSpeciesID = 40 -- Westfall Chicken
    local breedInfo = GetPetBreedInfo(testSpeciesID)
    
    if breedInfo then
        -- Breed data found for species
        for i, breed in ipairs(breedInfo.availableBreeds) do
            local mods = breed.modifiers
            if mods then
                -- Breed info with modifiers
            else
                -- Breed info without modifiers
            end
        end
    else
        -- No breed data found for species
    end
end

-- Make test function available
PCLcore.TestBreedData = TestBreedData

-- PetCard breed integration loaded
