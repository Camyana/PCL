-- PCL Collection Comparison Module
-- This module compares the user's collected pets with the breed data to show what they have/need

local _, PCLcore = ...;

PCLcore.CollectionComparison = {};

local CollectionComparison = PCLcore.CollectionComparison;

-- Function to calculate breed ID based on pet stats (improved version)
function CollectionComparison:CalculatePetBreed(speciesID, health, maxHealth, attack, speed, level, quality)
    -- If we don't have complete stats, return first available breed
    if not health or not attack or not speed or not level or not quality then
        if PCLcore.breedData and PCLcore.breedData.species and PCLcore.breedData.species[speciesID] then
            local availableBreeds = PCLcore.breedData.species[speciesID].breeds
            if availableBreeds and #availableBreeds > 0 then
                local firstBreed = availableBreeds[1]
                return firstBreed, self:GetBreedLetters(firstBreed)
            end
        end
        return 3, "B/B" -- Fallback only if no breed data
    end
    
    if not PCLcore.breedData or not PCLcore.breedData.species or not PCLcore.breedData.species[speciesID] then
        return 3, "B/B"
    end
    
    local availableBreeds = PCLcore.breedData.species[speciesID].breeds
    if not availableBreeds or #availableBreeds == 0 then
        return 3, "B/B"
    end
    
    -- Quality multipliers (exact values from BattlePetBreedID)
    local qualityMultipliers = {
        [1] = 0.5, [2] = 0.550000011920929, [3] = 0.600000023841858, 
        [4] = 0.649999976158142, [5] = 0.699999988079071, [6] = 0.75
    }
    
    -- Breed stats modifiers (exact values from BattlePetBreedID)
    local breedStatsModifiers = {
        [3] = {0.5, 0.5, 0.5},   -- B/B
        [4] = {0, 2, 0},         -- P/P
        [5] = {0, 0, 2},         -- S/S
        [6] = {2, 0, 0},         -- H/H
        [7] = {0.9, 0.9, 0},     -- H/P
        [8] = {0, 0.9, 0.9},     -- P/S
        [9] = {0.9, 0, 0.9},     -- H/S
        [10] = {0.4, 0.9, 0.4},  -- P/B
        [11] = {0.4, 0.4, 0.9},  -- S/B
        [12] = {0.9, 0.4, 0.4}   -- H/B
    }
    
    -- For level 25 pets, try exact breed matching
    if level == 25 and quality >= 3 then
        local qualityMult = qualityMultipliers[quality] or qualityMultipliers[3]
        local nQL = qualityMult * 2 * level
        
        -- Estimate base stats
        local estimatedBaseHealth = ((health - 100) / (nQL * 5)) - 0.5
        local estimatedBasePower = (attack / nQL) - 0.5
        local estimatedBaseSpeed = (speed / nQL) - 0.5
        
        -- Clamp to reasonable values
        estimatedBaseHealth = math.max(5, math.min(25, estimatedBaseHealth))
        estimatedBasePower = math.max(5, math.min(25, estimatedBasePower))
        estimatedBaseSpeed = math.max(5, math.min(25, estimatedBaseSpeed))
        
        local bestBreed = availableBreeds[1]  -- Default to first available breed
        local smallestDiff = math.huge
        
        -- Test only available breeds for this species
        for _, testBreedID in ipairs(availableBreeds) do
            local breedMods = breedStatsModifiers[testBreedID]
            if breedMods then
                -- Calculate expected stats
                local expectedHealth = math.floor(((estimatedBaseHealth + breedMods[1]) * nQL * 5 + 100) + 0.5)
                local expectedPower = math.floor(((estimatedBasePower + breedMods[2]) * nQL) + 0.5)
                local expectedSpeed = math.floor(((estimatedBaseSpeed + breedMods[3]) * nQL) + 0.5)
                
                -- Calculate difference
                local diff = math.abs(health - expectedHealth) + math.abs(attack - expectedPower) + math.abs(speed - expectedSpeed)
                
                if diff < smallestDiff then
                    smallestDiff = diff
                    bestBreed = testBreedID
                end
            end
        end
        
        return bestBreed, self:GetBreedLetters(bestBreed)
    end
    
    -- Fallback to pattern matching for lower level pets - only check available breeds
    local totalStats = health + attack + speed
    local healthRatio = health / totalStats
    local powerRatio = attack / totalStats
    local speedRatio = speed / totalStats
    
    -- Look for stat distribution patterns in available breeds only
    local bestMatch = availableBreeds[1]  -- Default to first available
    local bestScore = 0
    
    for _, breedID in ipairs(availableBreeds) do
        local letters = self:GetBreedLetters(breedID)
        local score = 0
        
        if letters == "P/P" and powerRatio > 0.4 then
            score = powerRatio * 100
        elseif letters == "S/S" and speedRatio > 0.4 then
            score = speedRatio * 100
        elseif letters == "H/H" and healthRatio > 0.5 then
            score = healthRatio * 100
        elseif letters == "H/P" and healthRatio > 0.35 and powerRatio > 0.3 then
            score = (healthRatio + powerRatio) * 50
        elseif letters == "P/S" and powerRatio > 0.3 and speedRatio > 0.3 then
            score = (powerRatio + speedRatio) * 50
        elseif letters == "H/S" and healthRatio > 0.35 and speedRatio > 0.3 then
            score = (healthRatio + speedRatio) * 50
        elseif letters == "P/B" then
            score = powerRatio * 60  -- Medium power bias
        elseif letters == "S/B" then
            score = speedRatio * 60  -- Medium speed bias
        elseif letters == "H/B" then
            score = healthRatio * 60  -- Medium health bias
        elseif letters == "B/B" then
            score = 30  -- Balanced gets moderate score
        end
        
        if score > bestScore then
            bestScore = score
            bestMatch = breedID
        end
    end
    
    return bestMatch, self:GetBreedLetters(bestMatch)
end

-- Function to get breed letters from breed ID
function CollectionComparison:GetBreedLetters(breedID)
    local breedLetters = {
        [3] = "B/B",   -- Balanced
        [4] = "P/P",   -- Power
        [5] = "S/S",   -- Speed
        [6] = "H/H",   -- Health
        [7] = "H/P",   -- Health/Power
        [8] = "P/S",   -- Power/Speed
        [9] = "H/S",   -- Health/Speed
        [10] = "P/B",  -- Power/Balanced
        [11] = "S/B",  -- Speed/Balanced
        [12] = "H/B"   -- Health/Balanced
    }
    
    return breedLetters[breedID] or "?/?"
end

-- Helper function to get breed letters list from breed IDs
function CollectionComparison:GetBreedLettersList(breedIDs)
    local letters = {}
    for _, breedID in ipairs(breedIDs or {}) do
        table.insert(letters, self:GetBreedLetters(breedID))
    end
    return letters
end

-- Helper function to get quality text
function CollectionComparison:GetQualityText(quality)
    local qualityTexts = {
        [1] = "Poor",
        [2] = "Common", 
        [3] = "Uncommon",
        [4] = "Rare",
        [5] = "Epic",
        [6] = "Legendary"
    }
    return qualityTexts[quality] or "Unknown"
end

-- Function to get detailed user pet information for a species
function CollectionComparison:GetUserPetDetails(speciesID)
    local userPets = {}
    local totalCollected = 0
    
    -- We need to iterate through all owned pets and filter by species
    local numPets, numOwned = C_PetJournal.GetNumPets()
    
    for i = 1, numOwned do
        local petID, species, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
        
        if owned and species == speciesID then
            local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID)
            
            local petInfo = {
                petID = petID,
                name = customName or speciesName,
                level = level,
                quality = rarity,
                health = health,
                maxHealth = maxHealth,
                attack = attack,
                speed = speed,
                speciesID = species
            }
            
            if health and attack and speed and level and rarity then
                local breedID, breedLetters = self:CalculatePetBreed(speciesID, health, maxHealth, attack, speed, level, rarity)
                petInfo.breedID = breedID
                petInfo.breedLetters = breedLetters
            end
            
            table.insert(userPets, petInfo)
            totalCollected = totalCollected + 1
        end
    end
    
    return userPets, totalCollected
end

-- Function to compare user's collection with available breeds for a species
function CollectionComparison:CompareSpeciesCollection(speciesID)
    local comparison = {
        speciesID = speciesID,
        isCollected = false,
        totalOwned = 0,
        totalAvailableBreeds = 0,
        ownedBreeds = {},
        missingBreeds = {},
        collectedBreedIDs = {},
        availableBreedIDs = {}
    }
    
    -- Get species name for display
    local speciesName = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    comparison.speciesName = speciesName or "Unknown Pet"
    
    -- Check if user has collected this species at all
    comparison.isCollected = PCLcore.Function.IsPetCollected and PCLcore.Function.IsPetCollected(speciesID) or false
    
    -- Get available breeds from our data
    if PCLcore.breedData and PCLcore.breedData.species and PCLcore.breedData.species[speciesID] then
        local breedData = PCLcore.breedData.species[speciesID]
        comparison.availableBreedIDs = breedData.breeds or {}
        comparison.totalAvailableBreeds = #comparison.availableBreedIDs
    end
    
    -- If not collected, all breeds are missing
    if not comparison.isCollected then
        for _, breedID in ipairs(comparison.availableBreedIDs) do
            table.insert(comparison.missingBreeds, {
                breedID = breedID,
                breedLetters = self:GetBreedLetters(breedID)
            })
        end
        return comparison
    end
    
    -- Get user's collected pets for this species
    local userPets, totalCollected = self:GetUserPetDetails(speciesID)
    comparison.totalOwned = totalCollected
    comparison.userPets = userPets
    
    -- Track which breeds the user has
    local ownedBreedSet = {}
    for _, pet in ipairs(userPets) do
        if pet.breedID then
            ownedBreedSet[pet.breedID] = true
            if not comparison.collectedBreedIDs[pet.breedID] then
                table.insert(comparison.collectedBreedIDs, pet.breedID)
                table.insert(comparison.ownedBreeds, {
                    breedID = pet.breedID,
                    breedLetters = pet.breedLetters or self:GetBreedLetters(pet.breedID),
                    count = 1
                })
            else
                -- Increment count for this breed
                for _, ownedBreed in ipairs(comparison.ownedBreeds) do
                    if ownedBreed.breedID == pet.breedID then
                        ownedBreed.count = ownedBreed.count + 1
                        break
                    end
                end
            end
        end
    end
    
    -- Find missing breeds
    for _, breedID in ipairs(comparison.availableBreedIDs) do
        if not ownedBreedSet[breedID] then
            table.insert(comparison.missingBreeds, {
                breedID = breedID,
                breedLetters = self:GetBreedLetters(breedID)
            })
        end
    end
    
    return comparison
end

-- Function to generate a summary of all collection comparisons
function CollectionComparison:GenerateCollectionSummary()
    local summary = {
        totalSpecies = 0,
        collectedSpecies = 0,
        uncollectedSpecies = 0,
        totalAvailableBreeds = 0,
        totalCollectedBreeds = 0,
        totalMissingBreeds = 0,
        speciesDetails = {}
    }
    
    if not PCLcore.breedData or not PCLcore.breedData.species then
        print("|cffFF0000PCL: Breed data not loaded! Cannot generate collection summary.|r")
        return summary
    end
    
    -- Iterate through all species in our breed data
    for speciesID, breedData in pairs(PCLcore.breedData.species) do
        local comparison = self:CompareSpeciesCollection(tonumber(speciesID))
        
        summary.totalSpecies = summary.totalSpecies + 1
        summary.totalAvailableBreeds = summary.totalAvailableBreeds + comparison.totalAvailableBreeds
        
        if comparison.isCollected then
            summary.collectedSpecies = summary.collectedSpecies + 1
            summary.totalCollectedBreeds = summary.totalCollectedBreeds + #comparison.ownedBreeds
        else
            summary.uncollectedSpecies = summary.uncollectedSpecies + 1
        end
        
        summary.totalMissingBreeds = summary.totalMissingBreeds + #comparison.missingBreeds
        
        -- Store detailed comparison for later use
        summary.speciesDetails[speciesID] = comparison
    end
    
    return summary
end

-- Function to find species with missing breeds (for collecting priorities)
function CollectionComparison:FindSpeciesWithMissingBreeds(maxResults)
    local speciesWithMissingBreeds = {}
    maxResults = maxResults or 50 -- Default limit
    
    if not PCLcore.breedData or not PCLcore.breedData.species then
        return speciesWithMissingBreeds
    end
    
    for speciesID, breedData in pairs(PCLcore.breedData.species) do
        local comparison = self:CompareSpeciesCollection(tonumber(speciesID))
        
        -- Only include species that are collected but missing some breeds
        if comparison.isCollected and #comparison.missingBreeds > 0 then
            table.insert(speciesWithMissingBreeds, {
                speciesID = comparison.speciesID,
                speciesName = comparison.speciesName,
                totalBreeds = comparison.totalAvailableBreeds,
                ownedBreeds = #comparison.ownedBreeds,
                missingBreeds = comparison.missingBreeds,
                missingCount = #comparison.missingBreeds,
                completionPercentage = (#comparison.ownedBreeds / comparison.totalAvailableBreeds) * 100
            })
        end
        
        -- Stop if we've reached the limit
        if #speciesWithMissingBreeds >= maxResults then
            break
        end
    end
    
    -- Sort by completion percentage (ascending - most incomplete first)
    table.sort(speciesWithMissingBreeds, function(a, b)
        return a.completionPercentage < b.completionPercentage
    end)
    
    return speciesWithMissingBreeds
end

-- Function to display collection summary in chat
function CollectionComparison:DisplaySummaryInChat()
    local summary = self:GenerateCollectionSummary()
    
    print("|cff00CCFFPCLː Pet Collection & Breed Summary|r")
    print("|cffFFFFFF─────────────────────────────────────|r")
    print(string.format("|cffAAFFAATotal Species in Database: |cffFFFFFF%d|r", summary.totalSpecies))
    print(string.format("|cff00FF00Collected Species: |cffFFFFFF%d|r (%.1f%%)", 
        summary.collectedSpecies, 
        (summary.collectedSpecies / summary.totalSpecies) * 100))
    print(string.format("|cffFF4444Uncollected Species: |cffFFFFFF%d|r", summary.uncollectedSpecies))
    print("|cffFFFFFF─────────────────────────────────────|r")
    print(string.format("|cffAAFFAATotal Available Breeds: |cffFFFFFF%d|r", summary.totalAvailableBreeds))
    print(string.format("|cff00FF00Collected Breeds: |cffFFFFFF%d|r (%.1f%%)", 
        summary.totalCollectedBreeds, 
        (summary.totalCollectedBreeds / summary.totalAvailableBreeds) * 100))
    print(string.format("|cffFF4444Missing Breeds: |cffFFFFFF%d|r", summary.totalMissingBreeds))
end

-- Function to display species with missing breeds
function CollectionComparison:DisplayMissingBreeds(maxResults)
    maxResults = maxResults or 10
    
    local speciesWithMissing = self:FindSpeciesWithMissingBreeds(maxResults)
    
    if #speciesWithMissing == 0 then
        print("|cff00FF00PCLː Congratulations! You have all available breeds for your collected pets!|r")
        return
    end
    
    print(string.format("|cff00CCFFPCLː Top %d Species Missing Breeds:|r", math.min(maxResults, #speciesWithMissing)))
    print("|cffFFFFFF─────────────────────────────────────|r")
    
    for i, species in ipairs(speciesWithMissing) do
        if i > maxResults then break end
        
        local missingBreedText = ""
        for j, breed in ipairs(species.missingBreeds) do
            if j > 1 then missingBreedText = missingBreedText .. ", " end
            missingBreedText = missingBreedText .. breed.breedLetters
        end
        
        print(string.format("%d. |cffFFFF00%s|r |cffAAAAAAL(Species %d)|r", 
            i, species.speciesName or "Unknown", species.speciesID))
        print(string.format("   |cff00FF00%d/%d breeds|r (%.0f%%) |cffFF4444Missing:|r %s", 
            species.ownedBreeds, species.totalBreeds, species.completionPercentage, missingBreedText))
    end
end

-- Add a test command to debug a specific species
SLASH_PCLTESTCOMPARE1 = "/pcltestcompare"
SlashCmdList["PCLTESTCOMPARE"] = function(msg)
    local speciesID = tonumber(msg)
    if not speciesID then
        print("PCL: Usage: /pcltestcompare [speciesID]")
        return
    end
    
    local speciesName, speciesIcon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if not speciesName then
        print("PCL: Invalid species ID: " .. tostring(speciesID))
        return
    end
    
    -- Get available breeds for this species
    local availableBreeds = {}
    if PCLcore.breedData and PCLcore.breedData.species and PCLcore.breedData.species[speciesID] then
        availableBreeds = PCLcore.breedData.species[speciesID].breeds or {}
    end
    
    if #availableBreeds == 0 then
        print("PCL: No breed data available for " .. speciesName .. " (ID: " .. speciesID .. ")")
        return
    end
    
    -- Get owned pets of this species
    local ownedPets = {}
    local numPets, numOwned = C_PetJournal.GetNumPets()
    
    for i = 1, numOwned do
        local petID, species, owned, customName, level, favorite, isRevoked, speciesName = C_PetJournal.GetPetInfoByIndex(i)
        if owned and species == speciesID then
            table.insert(ownedPets, petID)
        end
    end
    
    print("PCL: Breed Test for " .. speciesName .. " (Species ID: " .. speciesID .. ")")
    print("Available Breeds: " .. #availableBreeds .. " (" .. table.concat(PCLcore.CollectionComparison:GetBreedLettersList(availableBreeds), ", ") .. ")")
    print("Owned Pets: " .. #ownedPets)
    
    if #ownedPets == 0 then
        print("  - No pets of this species owned")
        return
    end
    
    -- Track which breeds we have
    local ownedBreeds = {}
    
    for i, petID in ipairs(ownedPets) do
        local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID)
        local _, _, level, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(petID)
        
        if health and attack and speed and level and rarity then
            local breedID, breedLetters = PCLcore.CollectionComparison:CalculatePetBreed(speciesID, health, maxHealth, attack, speed, level, rarity)
            
            print(string.format("  Pet %d: %s (Level %d, %s quality) - Breed: %s (ID: %d)", 
                i, petName or "Unknown", level or 1, 
                PCLcore.CollectionComparison:GetQualityText(rarity) or "Unknown", 
                breedLetters or "Unknown", breedID or 0))
            
            ownedBreeds[breedID] = (ownedBreeds[breedID] or 0) + 1
        else
            print(string.format("  Pet %d: %s - Unable to determine breed (missing stats)", i, petName or "Unknown"))
        end
    end
    
    -- Show breed completion summary
    local ownedBreedCount = 0
    for _ in pairs(ownedBreeds) do
        ownedBreedCount = ownedBreedCount + 1
    end
    
    print(string.format("Breed Collection: %d/%d breeds owned (%.1f%% complete)", 
        ownedBreedCount, #availableBreeds, (ownedBreedCount / #availableBreeds) * 100))
    
    -- Show missing breeds
    local missingBreeds = {}
    for _, breedID in ipairs(availableBreeds) do
        if not ownedBreeds[breedID] then
            table.insert(missingBreeds, PCLcore.CollectionComparison:GetBreedLetters(breedID))
        end
    end
    
    if #missingBreeds > 0 then
        print("Missing Breeds: " .. table.concat(missingBreeds, ", "))
    else
        print("✓ All available breeds collected!")
    end
end

-- Slash command handlers
SLASH_PCLCOMPARE1 = "/pclcompare"
SlashCmdList["PCLCOMPARE"] = function(msg)
    local command = string.lower(string.trim(msg or ""))
    
    if command == "" or command == "summary" then
        PCLcore.CollectionComparison:DisplaySummaryInChat()
    elseif command == "missing" then
        PCLcore.CollectionComparison:DisplayMissingBreeds(10)
    elseif string.match(command, "^missing %d+$") then
        local count = tonumber(string.match(command, "(%d+)"))
        PCLcore.CollectionComparison:DisplayMissingBreeds(count)
    elseif string.match(command, "^species %d+$") then
        local speciesID = tonumber(string.match(command, "(%d+)"))
        local comparison = PCLcore.CollectionComparison:CompareSpeciesCollection(speciesID)
        
        print(string.format("|cff00CCFFPCLː %s |cffAAAAAAL(Species %d)|r", 
            comparison.speciesName, comparison.speciesID))
        
        if not comparison.isCollected then
            print("|cffFF4444Status:|r Not Collected")
        else
            print(string.format("|cff00FF00Status:|r Collected |cffFFFFFF(%d owned)|r", comparison.totalOwned))
            
            if #comparison.ownedBreeds > 0 then
                local ownedText = ""
                for i, breed in ipairs(comparison.ownedBreeds) do
                    if i > 1 then ownedText = ownedText .. ", " end
                    ownedText = ownedText .. breed.breedLetters
                    if breed.count > 1 then
                        ownedText = ownedText .. " (" .. breed.count .. ")"
                    end
                end
                print("|cff00FF00Owned Breeds:|r " .. ownedText)
            end
            
            if #comparison.missingBreeds > 0 then
                local missingText = ""
                for i, breed in ipairs(comparison.missingBreeds) do
                    if i > 1 then missingText = missingText .. ", " end
                    missingText = missingText .. breed.breedLetters
                end
                print("|cffFF4444Missing Breeds:|r " .. missingText)
            else
                print("|cff00FF00All breeds collected for this species!|r")
            end
        end
    else
        print("|cff00CCFFPCLː Collection Comparison Commands:|r")
        print("|cffFFFFFF/pclcompare|r - Show collection summary")
        print("|cffFFFFFF/pclcompare summary|r - Show collection summary")
        print("|cffFFFFFF/pclcompare missing [count]|r - Show species missing breeds")
        print("|cffFFFFFF/pclcompare species [speciesID]|r - Show details for specific species")
    end
end
