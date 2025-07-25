local PCL, PCLcore = ...;

PCLcore.Function = {};
local PCL_functions = PCLcore.Function;

-- Function to detect if we're running on Classic WoW
function PCL_functions:IsClassicWoW()
    -- WOW_PROJECT_ID constants:
    -- WOW_PROJECT_MAINLINE = 1 (Retail)
    -- WOW_PROJECT_CLASSIC = 2 (Classic Era) 
    -- WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5 (TBC Classic)
    -- WOW_PROJECT_WRATH_CLASSIC = 11 (Wrath Classic)
    -- WOW_PROJECT_CATACLYSM_CLASSIC = 14 (Cata Classic)
    if WOW_PROJECT_ID then
        return WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
    end
    -- Fallback detection if WOW_PROJECT_ID is not available
    return select(4, GetBuildInfo()) < 90000
end

-- Pet Quality Border Colors
local PET_QUALITY_COLORS = {
    [1] = {r = 0.6, g = 0.6, b = 0.6, a = 1},    -- Poor (Gray)
    [2] = {r = 1, g = 1, b = 1, a = 1},          -- Common (White)  
    [3] = {r = 0.1, g = 1, b = 0.1, a = 1},      -- Uncommon (Green)
    [4] = {r = 0.1, g = 0.5, b = 1, a = 1},      -- Rare (Blue)
    [5] = {r = 0.9, g = 0.5, b = 1, a = 1},      -- Epic (Purple)
    [6] = {r = 1, g = 0.5, b = 0, a = 1}         -- Legendary (Orange)
}

-- Function to get pet quality for a collected pet
function PCL_functions:GetPetQuality(speciesID)
    -- For collected pets, find the highest quality version owned
    local highestQuality = 1
    for i = 1, C_PetJournal.GetNumPets() do
        local petID, speciesIDCheck, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
        if owned and speciesIDCheck == speciesID then
            -- Get the pet stats which include quality information
            local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(petID)
            if rarity and rarity > highestQuality then
                highestQuality = rarity
            end
        end
    end
    return highestQuality
end

-- Function to apply quality border to pet frame  
function PCL_functions:ApplyPetQualityBorder(petFrame, speciesID, isCollected)
    if not petFrame or not speciesID then
        return
    end
    
    -- Only show quality borders for collected pets if setting is enabled
    if PCL_SETTINGS.showPetQuality and isCollected then
        local quality = self:GetPetQuality(speciesID)
        local qualityColor = PET_QUALITY_COLORS[quality] or PET_QUALITY_COLORS[1]
        
        -- Apply quality border color
        petFrame:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, qualityColor.a)
        
        -- Make border thicker for higher quality pets
        if quality >= 4 then  -- Rare and above
            petFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 3  -- Thicker border for rare+ pets
            })
        end
    else
        -- Default border for uncollected or when quality display is disabled
        if isCollected then
            petFrame:SetBackdropBorderColor(0, 1, 0, 1)  -- Green for collected
        else
            petFrame:SetBackdropBorderColor(0.6, 0.2, 0.2, 0.8)  -- Red for uncollected
        end
    end
end

-- Function to add pet level display to frame
function PCL_functions:AddPetLevelDisplay(petFrame, speciesID, isCollected)
    if not petFrame or not speciesID or not isCollected or not PCL_SETTINGS.showPetLevel then
        return
    end
    
    -- Find the highest level pet of this species
    local highestLevel = 1
    for i = 1, C_PetJournal.GetNumPets() do
        local petID, speciesIDCheck, owned, customName, level = C_PetJournal.GetPetInfoByIndex(i)
        if owned and speciesIDCheck == speciesID and level then
            if level > highestLevel then
                highestLevel = level
            end
        end
    end
    
    -- Only show level if it's above 1
    if highestLevel > 1 then
        -- Create level text if it doesn't exist
        if not petFrame.levelText then
            petFrame.levelText = petFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            petFrame.levelText:SetPoint("BOTTOMRIGHT", petFrame, "BOTTOMRIGHT", -2, 2)
            petFrame.levelText:SetTextColor(1, 1, 0, 1)  -- Yellow text
            petFrame.levelText:SetJustifyH("RIGHT")
        end
        
        petFrame.levelText:SetText(tostring(highestLevel))
        petFrame.levelText:Show()
    elseif petFrame.levelText then
        petFrame.levelText:Hide()
    end
end

-- Function to add breed collection status indicator to pet frames
function PCL_functions:AddBreedCollectionStatus(petFrame, speciesID, isCollected)
    if not isCollected or not PCLcore.CollectionComparison then
        -- Hide any existing breed status indicator
        if petFrame.breedStatus then
            petFrame.breedStatus:Hide()
        end
        return
    end
    
    -- Get breed comparison data for this species
    local comparison = PCLcore.CollectionComparison:CompareSpeciesCollection(speciesID)
    
    -- Only show breed status for collected pets with multiple available breeds
    if not comparison.isCollected or comparison.totalAvailableBreeds <= 1 then
        if petFrame.breedStatus then
            petFrame.breedStatus:Hide()
        end
        return
    end
    
    -- Create breed status indicator if it doesn't exist
    if not petFrame.breedStatus then
        petFrame.breedStatus = petFrame:CreateTexture(nil, "OVERLAY")
        petFrame.breedStatus:SetWidth(12)
        petFrame.breedStatus:SetHeight(12)
        petFrame.breedStatus:SetPoint("BOTTOMLEFT", petFrame, "BOTTOMLEFT", 2, 2)
    end
    
    -- Determine status color based on breed completion
    local ownedBreeds = #comparison.ownedBreeds
    local totalBreeds = comparison.totalAvailableBreeds
    local completionRatio = ownedBreeds / totalBreeds
    
    if completionRatio >= 1.0 then
        -- All breeds collected - show green checkmark
        petFrame.breedStatus:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
        petFrame.breedStatus:SetVertexColor(0, 1, 0, 1)
    elseif completionRatio >= 0.5 then
        -- Partial collection - show yellow warning
        petFrame.breedStatus:SetTexture("Interface\\RaidFrame\\ReadyCheck-Waiting")
        petFrame.breedStatus:SetVertexColor(1, 1, 0, 1)
    else
        -- Few breeds collected - show red X
        petFrame.breedStatus:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
        petFrame.breedStatus:SetVertexColor(1, 0, 0, 1)
    end
    
    petFrame.breedStatus:Show()
    
    -- Store breed info for tooltip
    petFrame.breedComparisonData = comparison
end

-- Function to check if pet should be filtered by family
function PCL_functions:ShouldFilterPetByFamily(speciesID, selectedFamily)
    if not PCL_SETTINGS.filterByFamily or not selectedFamily or selectedFamily == "All" then
        return false  -- Don't filter
    end
    
    -- Get pet info to check family
    local petName, icon, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    
    -- Pet type numbers correspond to families
    local petTypeNames = {
        [1] = "Humanoid", [2] = "Dragonkin", [3] = "Flying", [4] = "Undead", [5] = "Critter",
        [6] = "Magic", [7] = "Elemental", [8] = "Beast", [9] = "Aquatic", [10] = "Mechanical"
    }
    
    local petFamilyName = petTypeNames[petType] or "Unknown"
    
    -- Return true if pet should be filtered out (family doesn't match)
    return petFamilyName ~= selectedFamily
end

-- Function to check if pet should be filtered by quality (show only rare+)
function PCL_functions:ShouldFilterPetByQuality(speciesID)
    if not PCL_SETTINGS.showOnlyRare then
        return false  -- Don't filter
    end
    
    -- Only apply quality filter to collected pets
    if not IsPetCollected(speciesID) then
        return false  -- Show uncollected pets regardless of quality setting
    end
    
    local quality = self:GetPetQuality(speciesID)
    
    -- Return true if pet should be filtered out (quality too low)
    return quality < 3  -- Filter out Poor (1) and Common (2) quality pets
end

-- Helper function to get localization safely
local function L(key)
    if PCLcore.L then
        return PCLcore.L[key] or key
    end
    return key
end

PCLcore.pets = {}
PCLcore.stats= {}
PCLcore.overviewStats = {}
PCLcore.overviewFrames = {}
PCLcore.petFrames = {}
PCLcore.petCheck = {}
PCLcore.addon_name = L("PCL | Pet Collection Log")
PCLcore.pinnedPetsChanged = false  -- Flag to track if pinned pets have been modified


function PCL_functions:getFaction()
    -- * --------------------------------
    -- * Get's player faction
    -- * --------------------------------
	if UnitFactionGroup("player") == "Alliance" then
		return "Horde" -- Inverse
	else
		return "Alliance" -- Inverse
	end
end

-- local function IsMountFactionSpecific(id)
--     if string.sub(id, 1, 1) == "m" then
--         mount_Id = string.sub(id, 2, -1)
--         local mountName, spellID, icon, _, _, _, _, isFactionSpecific, faction, _, isCollected, mountID, _ = C_MountJournal.GetMountInfoByID(mount_Id)
--         return faction, isFactionSpecific
--     else
--         mount_Id = C_MountJournal.GetMountFromItem(id)
--         local mountName, spellID, icon, _, _, _, _, isFactionSpecific, faction, _, isCollected, mountID, _ = C_MountJournal.GetMountInfoByID(mount_Id)
--         return faction, isFactionSpecific
--     end
-- end

-- Pet-related functions for PCL
local function GetPetInfoBySpeciesIDChecked(speciesID)
    local petName, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    local isCollected = numCollected > 0
    return petName, icon, petType, isCollected, numCollected, obtainable
end

local function IsPetFactionSpecific(speciesID)
    -- Most pets are not faction-specific, but some special cases exist
    -- For now, return false for most pets unless we find specific faction-locked pets
    return nil, false
end

PCLcore.Function.IsPetFactionSpecific = IsPetFactionSpecific

-- Check if a pet is collected based on species ID
function IsPetCollected(petSpeciesID)
    if not petSpeciesID then
        return false
    end
    
    -- Convert to number if it's a string
    local speciesID = tonumber(petSpeciesID)
    if not speciesID then
        return false
    end
    
    -- Use C_PetJournal.GetNumCollectedInfo to check if pet is collected
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    local isCollected = numCollected and numCollected > 0
    
    return isCollected
end

-- Also add it to the PCLcore.Function namespace for consistency
PCLcore.Function.IsPetCollected = IsPetCollected

-- Check if a pet is pinned in the PCL_PINNED table
function PCL_functions:CheckIfPinned(petID)
    if not petID then
        return false, nil
    end
    
    -- Ensure PCL_PINNED table exists
    if not PCL_PINNED then
        return false, nil
    end
    
    -- Extract species ID from pet ID (remove "p" prefix if it exists)
    local targetSpeciesID
    if type(petID) == "string" and string.sub(petID, 1, 1) == "p" then
        targetSpeciesID = tonumber(string.sub(petID, 2, -1))
    else
        targetSpeciesID = tonumber(petID)
    end
    
    if not targetSpeciesID then
        return false, nil
    end
    
    -- Search through pinned pets
    for i, pinnedPet in ipairs(PCL_PINNED) do
        local pinnedSpeciesID = tonumber(pinnedPet.petID)
        if pinnedSpeciesID == targetSpeciesID then
            return true, i
        end
    end
    
    return false, nil
end

-- Also add it to the PCLcore.Function namespace for consistency
PCLcore.Function.CheckIfPinned = PCL_functions.CheckIfPinned

-- Updated function to get pet ID (species ID) instead of mount ID
function PCLcore.Function:GetPetID(id)
    if type(id) == "string" and string.sub(id, 1, 1) == "p" then
        return tonumber(string.sub(id, 2, -1))
    else
        return tonumber(id)
    end
end

-- Alias for backward compatibility during transition
PCLcore.Function.GetMountID = PCLcore.Function.GetPetID

function PCL_functions:resetToDefault(setting)
    -- If no specific setting provided, reset all to defaults
    if setting == nil then
        PCL_SETTINGS = {}
        self:EstablishDefaults()
        return
    end
    
    -- Reset specific settings
    if setting == "Opacity" then
        PCL_SETTINGS.opacity = 0.95
    elseif setting == "Texture" then
        PCL_SETTINGS.statusBarTexture = nil
    elseif setting == "Colors" then
        PCL_SETTINGS.progressColors = {
            low = { a = 1, r = 0.929, g = 0.007, b = 0.019 },
            high = { a = 1, r = 0.1, g = 0.9, b = 0.1 },
            medium = { a = 1, r = 0.941, g = 0.658, b = 0.019 },
            complete = { a = 1, r = 0, g = 0.5, b = 0.9 }
        }
    elseif setting == "BlizzardTheme" then
        PCL_SETTINGS.useBlizzardTheme = false
    elseif setting == "PetsPerRow" then
        PCL_SETTINGS.PetsPerRow = 12
    elseif setting == "Minimap" then
        PCL_SETTINGS.minimap = {
            hide = false,
            minimapPos = 220,
            radius = 80
        }
    elseif setting == "HideCollectedPets" then
        PCL_SETTINGS.hideCollectedPets = false
    elseif setting == "HideCollectedMounts" then
        PCL_SETTINGS.hideCollectedMounts = false
    elseif setting == "MountsPerRow" then
        PCL_SETTINGS.mountsPerRow = 12
    end
end

-- Initialize DataBroker and LibDBIcon for minimap functionality
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local LibDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

-- DataBroker object for PCL
local PCL_LDB = nil
if LDB then
    PCL_LDB = LDB:NewDataObject("PCL", {
        type = "launcher",
        text = "PCL",
        icon = "Interface\\AddOns\\PCL\\pcl-logo-32",
        OnClick = function(self, button)
            if button == "LeftButton" then
                if PCL_OnAddonCompartmentClick then
                    PCL_OnAddonCompartmentClick()
                end
            elseif button == "RightButton" then
                if PCLcore.Frames and PCLcore.Frames.openSettings then
                    PCLcore.Frames:openSettings()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if tooltip and tooltip.SetText then
                tooltip:SetText("Pet Collection Log")
                tooltip:AddLine("Left-click: Toggle main window")
                tooltip:AddLine("Right-click: Open settings")
                tooltip:Show()
            end
        end,
    })
else
    -- LibDataBroker-1.1 not found - minimap icon will not be available
end

-- PCL_MM function to toggle minimap icon
function PCL_functions:PCL_MM()
    -- Ensure minimap settings exist
    if not PCL_SETTINGS then
        PCL_SETTINGS = {}
    end
    if not PCL_SETTINGS.minimap then
        PCL_SETTINGS.minimap = {
            hide = false,
            minimapPos = 220,
            radius = 80
        }
    end
    
    -- Toggle minimap icon visibility
    PCL_SETTINGS.minimap.hide = not PCL_SETTINGS.minimap.hide
    if LibDBIcon and PCL_LDB then
        if PCL_SETTINGS.minimap.hide then
            LibDBIcon:Hide("PCL")
            -- Minimap icon hidden
        else
            LibDBIcon:Show("PCL")
            -- Minimap icon shown
        end
    else
        -- Minimap functionality not available (missing LibDBIcon)
    end
end

-- Make PCL_MM available in the PCLcore.Function namespace
PCLcore.Function.PCL_MM = PCL_functions.PCL_MM

-- Helper function to safely set setting values with change notification
local function SetSettingValue(settingName, value)
    local oldValue = PCL_SETTINGS[settingName]
    if oldValue == value then
        return  -- No change needed
    end
    
    PCL_SETTINGS[settingName] = value
    
    -- Trigger refresh for settings that affect UI layout
    local layoutAffectingSettings = {
        "useBlizzardTheme",
        "PetsPerRow", 
        "hideCollectedPets"
    }
    
    for _, layoutSetting in ipairs(layoutAffectingSettings) do
        if settingName == layoutSetting then
            if PCLcore.Frames and PCLcore.Frames.RefreshLayout then
                PCLcore.Frames:RefreshLayout()
            end
            break
        end
    end
    
    -- Handle opacity changes
    if settingName == "opacity" then
        if PCL_mainFrame and PCL_mainFrame.SetBackdropColor then
            if PCL_SETTINGS.useBlizzardTheme then
                PCL_mainFrame:SetBackdropColor(0.05, 0.05, 0.15, value)
            else
                PCL_mainFrame:SetBackdropColor(0.08, 0.08, 0.08, value)
            end
        end
    end
    
    -- Handle minimap changes
    if settingName == "minimap" and LibDBIcon and PCL_LDB then
        if value and value.hide then
            LibDBIcon:Hide("PCL")
        else
            LibDBIcon:Show("PCL")
        end
    end
end

-- Establish default settings (based on PetCollector reference structure)
function PCL_functions:EstablishDefaults()
    if PCL_SETTINGS == nil then
        PCL_SETTINGS = {}
    end
    
    -- Core display settings
    if PCL_SETTINGS.opacity == nil then
        PCL_SETTINGS.opacity = 0.95
    end
    if PCL_SETTINGS.useBlizzardTheme == nil then
        PCL_SETTINGS.useBlizzardTheme = false
    end
    
    -- Pet display settings
    if PCL_SETTINGS.PetsPerRow == nil then
        PCL_SETTINGS.PetsPerRow = 12
    end
    if PCL_SETTINGS.hideCollectedPets == nil then
        PCL_SETTINGS.hideCollectedPets = false
    end
    
    -- Minimap settings
    if PCL_SETTINGS.minimap == nil then
        PCL_SETTINGS.minimap = {
            hide = false,
            minimapPos = 220,
            radius = 80
        }
    end
    
    -- Progress bar colors
    if PCL_SETTINGS.progressColors == nil then
        PCL_SETTINGS.progressColors = {
            low = { a = 1, r = 0.929, g = 0.007, b = 0.019 },
            high = { a = 1, r = 0.1, g = 0.9, b = 0.1 },
            medium = { a = 1, r = 0.941, g = 0.658, b = 0.019 },
            complete = { a = 1, r = 0, g = 0.5, b = 0.9 }
        }
    end
    
    -- Status bar texture
    if PCL_SETTINGS.statusBarTexture == nil then
        -- Set a reasonable default texture
        if PCLcore.media then
            -- Try to get the first available texture from LibSharedMedia
            local textures = PCLcore.media:HashTable("statusbar")
            if textures then
                for textureName, texturePath in pairs(textures) do
                    PCL_SETTINGS.statusBarTexture = textureName
                    break
                end
            end
        end
        -- If still nil, it will use the default fallback in the progressBar function
    end
    
    -- Legacy mount settings (kept for compatibility during transition)
    if PCL_SETTINGS.hideCollectedMounts == nil then
        PCL_SETTINGS.hideCollectedMounts = false
    end
    if PCL_SETTINGS.mountsPerRow == nil then
        PCL_SETTINGS.mountsPerRow = 12
    end
end

-- Initialize settings on addon load
if PCL_SETTINGS == nil then
    PCL_functions:EstablishDefaults()
else
    -- Ensure all defaults exist for existing users
    PCL_functions:EstablishDefaults()
end

-- Settings registration function
function PCL_functions:AddonSettings()
    -- Initialize settings using the structured approach
    self:EstablishDefaults()
    
    -- Register minimap icon
    if LibDBIcon and PCL_LDB then
        LibDBIcon:Register("PCL", PCL_LDB, PCL_SETTINGS.minimap)
        if not PCL_SETTINGS.minimap.hide then
            LibDBIcon:Show("PCL")
        end
    end
    
    -- Use AceConfig-3.0 for settings (like MCL does)
    local AceConfig = LibStub("AceConfig-3.0");
    local media = LibStub("LibSharedMedia-3.0")
    if not media then
        -- LibSharedMedia-3.0 not found - using default textures
    end
    
    local options = {
        type = "group",
        name = "Pet Collection Log Settings",
        order = 1,
        args = {
            headerone = {             
                order = 1,
                name = "Main Window Options",
                type = "header",
                width = "full",
            },            
            mainWindow = {             
                order = 2,
                name = "Main Window Opacity",
                desc = "Changes the opacity of the main window",
                type = "range",
                width = "normal",
                min = 0.3,
                max = 1,
                softMin = 0.3,
                softMax = 1,
                bigStep = 0.05,
                isPercent = false,
                set = function(info, val) 
                    PCL_SETTINGS.opacity = val
                    -- Apply opacity change immediately
                    if PCL_mainFrame and PCL_mainFrame.SetBackdropColor then
                        if PCL_SETTINGS.useBlizzardTheme then
                            PCL_mainFrame:SetBackdropColor(0.05, 0.05, 0.15, val)
                        else
                            PCL_mainFrame:SetBackdropColor(0.08, 0.08, 0.08, val)
                        end
                    end
                end,
                get = function(info) return PCL_SETTINGS.opacity; end,
            },
            spacer1 = {
                order = 2.5,
                cmdHidden = true,
                name = "",
                type = "description",
                width = "half",
            },
            defaultOpacity = {
                order = 3,
                name = "Reset Opacity",
                desc = "Reset to default opacity",
                width = "normal",
                type = "execute",
                func = function()
                    PCL_functions:resetToDefault("Opacity")
                    -- Apply opacity change immediately
                    if PCL_mainFrame and PCL_mainFrame.SetBackdropColor then
                        if PCL_SETTINGS.useBlizzardTheme then
                            PCL_mainFrame:SetBackdropColor(0.05, 0.05, 0.15, PCL_SETTINGS.opacity)
                        else
                            PCL_mainFrame:SetBackdropColor(0.08, 0.08, 0.08, PCL_SETTINGS.opacity)
                        end
                    end
                end
            },              
            headertwo = {             
                order = 4,
                name = "Progress Bar Settings",
                type = "header",
                width = "full",
            },             
            texture = {              
                order = 5,
                type = "select",
                name = "Statusbar Texture",
                width = "normal",
                desc = "Set the statusbar texture.",
                values = media and media:HashTable("statusbar") or {["Interface\\TargetingFrame\\UI-StatusBar"] = "Default"},
                set = function(info, val) 
                    PCL_SETTINGS.statusBarTexture = val
                    -- Update all existing status bars with the new texture
                    if PCLcore.Function and PCLcore.Function.UpdateAllStatusBarTextures then
                        PCLcore.Function:UpdateAllStatusBarTextures()
                    end
                end,
                get = function(info) return PCL_SETTINGS.statusBarTexture; end,
                style = "dropdown",
            },
            spacer2 = {
                order = 5.5,
                cmdHidden = true,
                name = "",
                type = "description",
                width = "half",
            },            
            defaultTexture = {
                order = 6,
                name = "Reset Texture",
                desc = "Reset to default texture",
                width = "normal",
                type = "execute",
                func = function()
                    PCL_functions:resetToDefault("Texture")
                    -- Update all existing status bars with the reset texture
                    if PCLcore.Function and PCLcore.Function.UpdateAllStatusBarTextures then
                        PCLcore.Function:UpdateAllStatusBarTextures()
                    end
                end
            },
            spacer3 = {
                order = 6.5,
                cmdHidden = true,
                name = "",
                type = "description",
                width = "full",
            },                              
            progressColorLow = {
                order = 7,
                type = "color",
                name = "Progress Bar (<33%)",
                width = "normal",
                desc = "Set the progress bar colors to be shown when the percentage collected is below 33%",
                set = function(info, r, g, b) 
                    PCL_SETTINGS.progressColors.low.r = r
                    PCL_SETTINGS.progressColors.low.g = g
                    PCL_SETTINGS.progressColors.low.b = b
                end,
                get = function(info) return PCL_SETTINGS.progressColors.low.r, PCL_SETTINGS.progressColors.low.g, PCL_SETTINGS.progressColors.low.b; end,                
            },
            spacer4 = {
                order = 7.5,
                cmdHidden = true,
                name = "",
                type = "description",
                width = "half",
            },            
            progressColorMedium = {
                order = 8,
                type = "color",
                name = "Progress Bar (<66%)",
                width = "normal",
                desc = "Set the progress bar colors to be shown when the percentage collected is below 66%",
                set = function(info, r, g, b) 
                    PCL_SETTINGS.progressColors.medium.r = r
                    PCL_SETTINGS.progressColors.medium.g = g
                    PCL_SETTINGS.progressColors.medium.b = b
                end,
                get = function(info) return PCL_SETTINGS.progressColors.medium.r, PCL_SETTINGS.progressColors.medium.g, PCL_SETTINGS.progressColors.medium.b; end,                
            },
            spacer5 = {
                order = 8.5,
                cmdHidden = true,
                name = "",
                type = "description",
                width = "half",
            },             
            progressColorHigh = {
                order = 9,
                type = "color",
                name = "Progress Bar (<100%)",
                width = "normal",
                desc = "Set the progress bar colors to be shown when the percentage collected is below 100%",
                set = function(info, r, g, b) 
                    PCL_SETTINGS.progressColors.high.r = r
                    PCL_SETTINGS.progressColors.high.g = g
                    PCL_SETTINGS.progressColors.high.b = b
                end,
                get = function(info) return PCL_SETTINGS.progressColors.high.r, PCL_SETTINGS.progressColors.high.g, PCL_SETTINGS.progressColors.high.b; end,                
            },
            spacer6 = {
                order = 9.5,
                cmdHidden = true,
                name = "",
                type = "description",
                width = "half",
            },             
            progressColorComplete = {
                order = 10,
                type = "color",
                name = "Progress Bar (100%)",
                width = "normal",
                desc = "Set the progress bar colors to be shown when all pets are collected",
                set = function(info, r, g, b) 
                    PCL_SETTINGS.progressColors.complete.r = r
                    PCL_SETTINGS.progressColors.complete.g = g
                    PCL_SETTINGS.progressColors.complete.b = b
                end,
                get = function(info) return PCL_SETTINGS.progressColors.complete.r, PCL_SETTINGS.progressColors.complete.g, PCL_SETTINGS.progressColors.complete.b; end,                
            },
            defaultColor = {
                order = 11,
                name = "Reset Colors",
                desc = "Reset to default colors",
                width = "normal",
                type = "execute",
                func = function()
                    PCL_functions:resetToDefault("Colors")
                end
            },              
            headerthree = {             
                order = 12,
                name = "Layout Settings",
                type = "header",
                width = "full",
            },
            petsPerRow = {
                order = 12.5,
                name = "Pets Per Row",
                desc = "Set the number of pets to display per row in the pet grid.",
                type = "range",
                width = "normal",
                min = 6,
                max = 24,
                softMin = 6,
                softMax = 24,
                step = 1,
                bigStep = 1,
                set = function(info, val)
                    PCL_SETTINGS.PetsPerRow = val
                    -- Trigger layout refresh to update the pet grid immediately
                    if PCLcore.Frames and PCLcore.Frames.RefreshLayout then
                        PCLcore.Frames:RefreshLayout()
                        -- Updated pets per row - layout refreshed
                    else
                        -- Updated pets per row - please reload UI to see changes
                    end
                end,
                get = function(info) return PCL_SETTINGS.PetsPerRow; end,
            },
            headerfour = {             
                order = 13,
                name = "Display Settings",
                type = "header",
                width = "full",
            },            
            hideCollectedPets = {
                order = 14,
                name = "Hide Collected Pets",
                desc = "If enabled, collected pets will not be shown in the list at all.",
                type = "toggle",
                width = "full",
                set = function(info, val)
                    PCL_SETTINGS.hideCollectedPets = val
                    -- Trigger layout refresh since this affects which pets are displayed
                    if PCLcore.Frames and PCLcore.Frames.RefreshLayout then
                        PCLcore.Frames:RefreshLayout()
                    end
                end,
                get = function(info) return PCL_SETTINGS.hideCollectedPets; end,
            },
            useBlizzardTheme = {
                order = 14.5,
                name = "Use Blizzard Theme",
                desc = "If enabled, the addon will use Blizzard's default UI theme.",
                type = "toggle",
                width = "full",
                set = function(info, val)
                    PCL_SETTINGS.useBlizzardTheme = val
                    -- Trigger layout refresh since this affects the entire UI appearance
                    if PCLcore.Frames and PCLcore.Frames.RefreshLayout then
                        PCLcore.Frames:RefreshLayout()
                    end
                end,
                get = function(info) return PCL_SETTINGS.useBlizzardTheme; end,
            },
            minimapIconToggle = {
                order = 14.6,
                name = "Show Minimap Icon",
                desc = "Toggle the display of the Minimap Icon.",
                type = "toggle",
                width = "full",
                set = function(info, val)
                    if not PCL_SETTINGS.minimap then
                        PCL_SETTINGS.minimap = {
                            hide = false,
                            minimapPos = 220,
                            radius = 80
                        }
                    end
                    PCL_SETTINGS.minimap.hide = not val
                    if LibDBIcon and PCL_LDB then
                        if val then
                            LibDBIcon:Show("PCL")
                        else
                            LibDBIcon:Hide("PCL")
                        end
                    end
                end,
                get = function(info)
                    return not (PCL_SETTINGS.minimap and PCL_SETTINGS.minimap.hide)
                end,
            },
            headerfive = {             
                order = 15,
                name = "Reset Settings",
                type = "header",
                width = "full",
            },             
            defaults = {
                order = 16,
                name = "Reset Settings",
                desc = "Reset to default settings",
                width = "normal",
                type = "execute",
                func = function()
                    PCL_functions:resetToDefault(nil)
                end
            }                                                                                                       
        }
    }

    -- Register the options table and add to Blizzard options (like MCL does)
    AceConfig:RegisterOptionsTable(PCLcore.addon_name, options, {});
    PCLcore.AceConfigDialog = LibStub("AceConfigDialog-3.0");
    PCLcore.AceConfigDialog:AddToBlizOptions(PCLcore.addon_name, PCLcore.addon_name, nil);
end

-- Make AddonSettings available in the PCLcore.Function namespace
PCLcore.Function.AddonSettings = PCL_functions.AddonSettings
PCLcore.Function.EstablishDefaults = PCL_functions.EstablishDefaults

-- Function to update all existing status bar textures
function PCL_functions:UpdateAllStatusBarTextures()
    if not PCLcore.statusBarFrames then
        -- No status bar frames to update
        return
    end
    
    -- Determine the texture to use
    local textureToUse = "Interface\\TargetingFrame\\UI-StatusBar"  -- Default fallback
    local textureName = "Default"
    
    if PCLcore.media and PCL_SETTINGS.statusBarTexture then
        local texture = PCLcore.media:Fetch("statusbar", PCL_SETTINGS.statusBarTexture)
        if texture then
            textureToUse = texture
            textureName = PCL_SETTINGS.statusBarTexture
        end
    end
    
    -- Update all tracked status bars
    local updatedCount = 0
    for i, statusBar in ipairs(PCLcore.statusBarFrames) do
        if statusBar and statusBar.SetStatusBarTexture then
            statusBar:SetStatusBarTexture(textureToUse)
            updatedCount = updatedCount + 1
        end
    end
    
    -- Updated status bars with texture
end

-- Make UpdateAllStatusBarTextures available in the PCLcore.Function namespace
PCLcore.Function.UpdateAllStatusBarTextures = PCL_functions.UpdateAllStatusBarTextures

-- Tables Mounts into Global List
function PCL_functions:TableMounts(id, frame, section, category)
    local mount = {
        id = id,
        frame = frame,
        section =  section,
        category = category,
    }
    table.insert(PCLcore.mounts, mount)
end

function PCL_functions:TablePets(id, frame, section, category)
    local pet = {
        id = id,
        frame = frame,
        section = section,
        category = category,
    }
    table.insert(PCLcore.pets, pet)
end

function PCL_functions:simplearmoryLink()
    local region = GetCVar("portal")

    local realmName = GetRealmName()

    local playerName = UnitName("player")

    local string = "https://simplearmory.com/#/"..region.."/"..realmName.."/"..playerName

    KethoEditBox_Show(string)

end

function PCL_functions:dfaLink()
    local region = GetCVar("portal")

    local realmName = GetRealmName()

    local playerName = UnitName("player")

    local string = "https://www.dataforazeroth.com/characters/"..region.."/"..realmName.."/"..playerName

    KethoEditBox_Show(string)

end

function PCL_functions:compareLink()
    local region = GetCVar("portal")

    local realmName = GetRealmName()

    local playerName = UnitName("player")
    local targetName, targetRealm
    if UnitIsPlayer("target") then
        targetName, targetRealm = UnitName("target")
        if targetRealm == nil then
            targetRealm = realmName
        end
    else
        KethoEditBox_Show("Mount off requires a target")
        return
    end
    
    local string = "https://wow-mcl.herokuapp.com/?realma="..region.."."..realmName.."&charactera="..playerName.."&realmb="..region.."."..targetRealm.."&characterb="..targetName
    
    KethoEditBox_Show(string)
end


function KethoEditBox_Show(text)
    if not KethoEditBox then
        local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(700, 100)
        
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = { left = 8, right = 6, top = 8, bottom = 8 },
        })
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
        
        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)
        
        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
        
        -- EditBox
        local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        sf:SetScrollChild(eb)
        
        -- Resizable
        f:SetResizable(true)
        f:SetFrameStrata("HIGH")
        
        f:Show()
    end
    
    if text then
        KethoEditBoxEditBox:SetText(text)
    end
    KethoEditBox:Show()
    PCLcore.PCL_MF:Hide()
end

function PCL_functions:initSections()
    -- * --------------------------------
    -- * Create variables and assign strings to each section.
    -- * --------------------------------

    local faction = PCL_functions:getFaction()
    local isClassic = PCL_functions:IsClassicWoW()
    PCLcore.sections = {}

    for i, v in ipairs(PCLcore.sectionNames) do
        -- Skip opposite faction section
        if v.name ~= faction then
            -- Skip sections not compatible with Classic if we're on Classic
            if not isClassic or v.includeInClassic ~= false then
                table.insert(PCLcore.sections, v)
            end
        end
    end

    PCLcore.PCL_MF_Nav = PCLcore.Frames:createNavFrame(PCLcore.PCL_MF, PCLcore.L["Sections"])

    -- Create the overview parent frame before SetTabs
    if not PCLcore.overview or not PCLcore.overview:IsObjectType("Frame") then
        -- Use the same width calculations from frames.lua for consistency
        local main_frame_width = 1250  -- Match the width from frames.lua
        PCLcore.overview = CreateFrame("Frame", nil, PCL_mainFrame.ScrollChild, "BackdropTemplate")
        PCLcore.overview:SetSize(main_frame_width - 60, 550)  -- Use consistent width calculation
        PCLcore.overview:SetPoint("TOPLEFT", PCL_mainFrame.ScrollChild, "TOPLEFT", 30, 0)  -- Consistent with other content frames
        PCLcore.overview:SetBackdropColor(0, 0, 0, 0)
    end
    -- Build the overview content into the overview frame
    PCLcore.Frames:createOverviewCategory(PCLcore.sections, PCLcore.overview)

    local tabFrames, numTabs = PCLcore.Frames:SetTabs() 

    PCLcore.sectionFrames = {}
    for i=1, numTabs do
        -- The section frames are already created in SetTabs, just reference them
        if tabFrames and tabFrames[i] then
            table.insert(PCLcore.sectionFrames, tabFrames[i])
        end
    end    
end


function PCL_functions:GetCollectedPets()
    local pets = {}
    local numPets, numOwned = C_PetJournal.GetNumPets()
    
    -- Iterate through all pet slots to find collected pets
    for i = 1, numPets do
        local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
        
        if owned and speciesID then
            -- Most pets are not faction-specific, but we can add logic here if needed
            table.insert(pets, speciesID)
        end
    end
    
    -- Update pet check list for compatibility
    if not PCLcore.petCheck then
        PCLcore.petCheck = {}
    end
    
    for k,v in pairs(pets) do
        local exists = false
        for kk,vv in pairs(PCLcore.petCheck) do
            if v == vv then
                exists = true
            end
        end
        if not exists then
            table.insert(PCLcore.petCheck, v)
        end
    end
    
    return pets
end

-- Keep backward compatibility
PCL_functions.GetCollectedMounts = PCL_functions.GetCollectedPets

-- Update collection data (triggers collection check)
function PCL_functions:UpdateCollection()
    if PCLcore.Function and PCLcore.Function.GetCollectedPets then
        PCLcore.Function:GetCollectedPets()
    end
    
    -- Initialize stats table if needed
    if not PCLcore.stats then
        PCLcore.stats = {}
    end
    
    -- Initialize Pinned section stats if needed
    if not PCLcore.stats["Pinned"] then
        PCLcore.stats["Pinned"] = { total = 0, collected = 0 }
    end
end

-- Calculate statistics for each section
function PCL_functions:CalculateSectionStats()
    if not PCLcore.petList or not PCLcore.stats then
        return
    end
    
    -- Clear existing stats (except Pinned which is handled separately)
    for k in pairs(PCLcore.stats) do
        if k ~= "Pinned" then
            PCLcore.stats[k] = nil
        end
    end
    
    -- Calculate stats for each section
    for sectionId, sectionData in pairs(PCLcore.petList) do
        if type(sectionData) == "table" and sectionData.name then
            local sectionName = sectionData.name
            local totalPets = 0
            local collectedPets = 0
            
            -- Go through all categories in this section
            if sectionData.categories then
                for categoryName, categoryData in pairs(sectionData.categories) do
                    if categoryData.pets then
                        for _, petId in ipairs(categoryData.pets) do
                            -- Convert pet ID if needed
                            local petSpeciesID = tonumber(petId)
                            if petSpeciesID then
                                -- Check faction restrictions
                                local allowed = true
                                if PCLcore.Function and PCLcore.Function.IsPetFactionSpecific then
                                    local faction, faction_specific = PCLcore.Function.IsPetFactionSpecific(petId)
                                    if faction_specific then
                                        local playerFaction = UnitFactionGroup("player")
                                        local petFaction = (faction == 0) and "Horde" or "Alliance"
                                        allowed = (petFaction == playerFaction)
                                    end
                                end
                                
                                if allowed then
                                    totalPets = totalPets + 1
                                    
                                    -- Check if pet is collected
                                    if IsPetCollected(petSpeciesID) then
                                        collectedPets = collectedPets + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Store section stats
            PCLcore.stats[sectionName] = {
                total = totalPets,
                collected = collectedPets
            }
        end
    end
    
    -- Update Pinned section stats
    if PCL_PINNED then
        PCLcore.stats["Pinned"] = {
            total = #PCL_PINNED,
            collected = 0  -- Pinned pets don't have a collected count since they're just references
        }
    end
end

function PCL_functions:CreateBorder(frame, side)
    frame.borders = frame:CreateLine(nil, "BACKGROUND", nil, 0)
    local l = frame.borders
    l:SetThickness(1)
    l:SetColorTexture(1, 1, 1, 0.4)
	l:SetStartPoint("BOTTOM"..side)
	l:SetEndPoint("TOP"..side)
    return frame
end


function PCL_functions:CreateFullBorder(self)
    if not self.borders then
        self.borders = {}
        for i=1, 4 do
            self.borders[i] = self:CreateLine(nil, "BACKGROUND", nil, 0)
            local l = self.borders[i]
            l:SetThickness(2)
            l:SetColorTexture(0, 0, 0, 0.7)
            if i==1 then
                l:SetStartPoint("TOPLEFT", 0, 1)
                l:SetEndPoint("TOPRIGHT", 0, 1)
            elseif i==2 then
                l:SetStartPoint("TOPRIGHT", 0, 1)
                l:SetEndPoint("BOTTOMRIGHT", 0, 2)
            elseif i==3 then
                l:SetStartPoint("BOTTOMRIGHT", 0, 2)
                l:SetEndPoint("BOTTOMLEFT", 0, 2)
            else
                l:SetStartPoint("BOTTOMLEFT", 0, 2)
                l:SetEndPoint("TOPLEFT", 0, 1)
            end
        end
    end
end

function PCL_functions:getTableLength(set)
    local i = 1
    for k,v in pairs(set) do
        i = i+1
    end
    return i
end

function PCL_functions:SetPetClickFunctionalityPin(frame, petSpeciesID, petName, itemLink, displayName)
    frame:SetScript("OnMouseDown", function(frame, button)
        if button == 'RightButton' then
            local petID = "p"..petSpeciesID
            local is_pinned, k = PCLcore.Function:CheckIfPinned(petID)
            if is_pinned then
                -- Remove from pinned
                table.remove(PCL_PINNED, k)
                frame.pin:SetAlpha(0)
                frame:Hide()
                -- Pet unpinned
                PCLcore.stats["Pinned"].total = PCLcore.Function:getTableLength(PCL_PINNED)
                PCLcore.RefreshUIFrames()  
            else
                -- Add to pinned
                table.insert(PCL_PINNED, {
                    petID = petSpeciesID,
                    category = frame.category,
                    section = frame.section
                })
                frame.pin:SetAlpha(1)
                -- Pet pinned
                PCLcore.stats["Pinned"].total = PCLcore.Function:getTableLength(PCL_PINNED)
                PCLcore.RefreshUIFrames()
            end
        elseif button == 'LeftButton' then
            if IsShiftKeyDown() then
                -- Attempt to link the pet in chat
                local petLink = C_PetJournal.GetBattlePetLink(petSpeciesID)
                if petLink and ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(petLink)
                end
            elseif IsAltKeyDown() then
                -- Alt+Left-click - Pin the detailed PetCard
                -- Alt+Left-click detected for pet species
                if PCLcore.PetCard and PCLcore.PetCard.PinFromHover then
                    -- Calling PinFromHover
                    PCLcore.PetCard:PinFromHover(petSpeciesID, frame)
                else
                    -- PetCard or PinFromHover not available
                end
            else
                -- Normal left-click for pin functionality could summon pet if desired
                if IsPetCollected(tonumber(petSpeciesID)) then
                    -- Get the first owned pet of this species
                    local petGUID = nil
                    for i = 1, C_PetJournal.GetNumPets() do
                        local guid, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i)
                        if owned and speciesID == tonumber(petSpeciesID) then
                            petGUID = guid
                            break
                        end
                    end
                    if petGUID then
                        C_PetJournal.SummonPetByGUID(petGUID)
                    end
                end
            end
        end
    end)
end

function PCL_functions:SetPetClickFunctionality(frame, petSpeciesID, petName, itemLink, displayName)
    frame:SetScript("OnMouseDown", function(frame, button)
        if button == 'RightButton' then
            if IsControlKeyDown() then
                local petID = "p"..petSpeciesID
                local is_pinned, k = PCLcore.Function:CheckIfPinned(petID)
                if is_pinned then
                    -- Remove from pinned
                    table.remove(PCL_PINNED, k)
                    frame.pin:SetAlpha(0)
                    -- Pet unpinned
                    PCLcore.stats["Pinned"].total = PCLcore.Function:getTableLength(PCL_PINNED)
                    PCLcore.RefreshUIFrames()
                else
                    -- Add to pinned
                    table.insert(PCL_PINNED, {
                        petID = petSpeciesID,
                        category = frame.category,
                        section = frame.section
                    })
                    frame.pin:SetAlpha(1)
                    -- Pet pinned
                    PCLcore.stats["Pinned"].total = PCLcore.Function:getTableLength(PCL_PINNED)
                    PCLcore.RefreshUIFrames()
                end
            else
                -- Normal right-click - attempt to summon pet if collected
                if IsPetCollected(tonumber(petSpeciesID)) then
                    C_PetJournal.SummonRandomPet(false)  -- Summon a random pet or dismiss current
                end
            end
        elseif button == 'LeftButton' then
            if IsShiftKeyDown() then
                -- Attempt to link the pet in chat
                local petLink = C_PetJournal.GetBattlePetLink(petSpeciesID)
                if petLink and ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(petLink)
                end
            elseif IsAltKeyDown() then
                -- Alt+Left-click - Pin the detailed PetCard
                -- Alt+Left-click detected for pet species (non-pin)
                if PCLcore.PetCard and PCLcore.PetCard.PinFromHover then
                    -- Calling PinFromHover from non-pin function
                    PCLcore.PetCard:PinFromHover(petSpeciesID, frame)
                else
                    -- PetCard or PinFromHover not available from non-pin function
                end
            else
                -- Normal left-click - attempt to summon specific pet if collected
                if IsPetCollected(tonumber(petSpeciesID)) then
                    -- Get the first owned pet of this species
                    local petGUID = nil
                    for i = 1, C_PetJournal.GetNumPets() do
                        local guid, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i)
                        if owned and speciesID == tonumber(petSpeciesID) then
                            petGUID = guid
                            break
                        end
                    end
                    if petGUID then
                        C_PetJournal.SummonPetByGUID(petGUID)
                    end
                end
            end
        end
        if button == 'MiddleButton' then
            -- Middle click to attempt to summon pet if it's collected
            if IsPetCollected(tonumber(petSpeciesID)) then
                -- Get the first owned pet of this species
                local petGUID = nil
                for i = 1, C_PetJournal.GetNumPets() do
                    local guid, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i)
                    if owned and speciesID == tonumber(petSpeciesID) then
                        petGUID = guid
                        break
                    end
                end
                if petGUID then
                    C_PetJournal.SummonPetByGUID(petGUID)
                end
            end
        end
    end)
end

function PCL_functions:SetMouseClickFunctionalityPin(frame, mountID, mountName, itemLink, spellID, isSteadyFlight)
    frame:SetScript("OnMouseDown", function(self, button)
        if IsControlKeyDown() then
            if button == 'LeftButton' then
                DressUpMount(mountID)
            elseif button == 'RightButton' then
                -- Allow pinning of both collected and uncollected mounts
                -- Initialize PCL_PINNED if it doesn't exist
                if not PCL_PINNED then
                    PCL_PINNED = {}
                end
                
                local pin = false
                local pin_count = table.getn(PCL_PINNED)
                if pin_count ~= nil then                     
                    for i=1, pin_count do                      
                        if PCL_PINNED[i].mountID == "m"..mountID then
                            pin = i
                            break
                        end
                    end
                end
                
                -- Only remove if we found a valid pin index
                if pin ~= false then
                    table.remove(PCL_PINNED, pin)
                    
                    -- Set flag to indicate pinned mounts have been modified
                    PCLcore.pinnedMountsChanged = true
                    
                    -- Update all pin icons for this mount
                    PCLcore.Function:UpdateAllPinIcons(mountID)
                    
                    -- Refresh the pinned section by recreating it
                    if _G["PinnedFrame"] then
                        -- Clear existing pet frames more thoroughly
                        if not PCLcore.petFrames then
                            PCLcore.petFrames = {}
                        end
                        if PCLcore.petFrames[1] then
                            for _, oldFrame in ipairs(PCLcore.petFrames[1]) do
                                if oldFrame and oldFrame:GetParent() then
                                    oldFrame:Hide()
                                    oldFrame:SetParent(nil)
                                end
                            end
                        end
                        
                        -- Also clear any untracked children of PinnedFrame
                        local children = {_G["PinnedFrame"]:GetChildren()}
                        for _, child in ipairs(children) do
                            if child and child:IsObjectType("Button") and child.petID then
                                child:Hide()
                                child:SetParent(nil)
                            end
                        end
                        
                        PCLcore.petFrames[1] = {}
                        
                        -- Recreate the pinned section content
                        local overflow, petFrame = PCLcore.Function:CreatePetsForCategory(PCL_PINNED, _G["PinnedFrame"], 30, _G["PinnedTab"], true, true)
                        PCLcore.petFrames[1] = petFrame
                    end
                end
            end               
        elseif button=='LeftButton' then
            if IsShiftKeyDown() then
                -- Handle shift-click to link mount in chat
                if itemLink and ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(itemLink)
                elseif spellID then
                    local spellLink = C_Spell.GetSpellLink(spellID)
                    if spellLink and ChatEdit_GetActiveWindow() then
                        ChatEdit_InsertLink(spellLink)
                    end
                end
            end
        end
        if button == 'MiddleButton' then
            -- Middle click to cast mount if it's collected
            if IsPetCollected(mountID) then
                CastSpellByName(mountName);
            end
        end
    end)
end

function PCL_functions:SetMouseClickFunctionality(frame, mountID, mountName, itemLink, spellID, isSteadyFlight) -- * Mount Frames

    frame:SetScript("OnMouseDown", function(self, button)
        if IsControlKeyDown() then
            if button == 'LeftButton' then
                DressUpMount(mountID)
            elseif button == 'RightButton' then
                -- Allow pinning of both collected and uncollected mounts
                -- Initialize PCL_PINNED if it doesn't exist
                if not PCL_PINNED then
                    PCL_PINNED = {}
                end
                
                local pin = false
                local pin_count = table.getn(PCL_PINNED)
                if pin_count ~= nil then                     
                    for i=1, pin_count do
                        if PCL_PINNED[i].mountID == "m"..mountID then
                            pin = i
                        end
                    end
                end
                if pin ~= false then
                    if frame.pin then
                        frame.pin:SetAlpha(0)
                    end
                    table.remove(PCL_PINNED, pin)
                    
                    -- Set flag to indicate pinned mounts have been modified
                    PCLcore.pinnedMountsChanged = true
                    
                    -- Update all pin icons for this mount
                    PCLcore.Function:UpdateAllPinIcons(mountID)
                    local index = 0
                    -- Initialize PCLcore.petFrames[1] if it doesn't exist
                    if not PCLcore.petFrames then
                        PCLcore.petFrames = {}
                    end
                    if not PCLcore.petFrames[1] then
                        PCLcore.petFrames[1] = {}
                    end
                    for k,v in pairs(PCLcore.petFrames[1]) do
                        index = index + 1
                        if tostring(v.petID) == tostring(mountID) then
                            PCLcore.petFrames[1][index]:Hide()                                
                            table.remove(PCLcore.petFrames[1],  index)
                            for kk,vv in ipairs(PCLcore.petFrames[1]) do
                                if kk == 1 then
                                    vv:SetParent(_G["PinnedFrame"])
                                    vv:Show()
                                else
                                    vv:SetParent(PCLcore.petFrames[1][kk-1])
                                    vv:Show()
                                end
                            end                                
                        end
                    end
                    
                    -- Refresh the pinned tab layout after unpinning
                    if PCL_frames and PCL_frames.RefreshLayout then
                        -- Check if we're currently viewing the Pinned tab
                        local isPinnedTabActive = false
                        if PCLcore.currentlySelectedTab and PCLcore.currentlySelectedTab.section and PCLcore.currentlySelectedTab.section.name == "Pinned" then
                            isPinnedTabActive = true
                        end
                        
                        -- Refresh the layout to update the pinned content
                        PCLcore.Frames:RefreshLayout()
                        
                        -- If we were on the Pinned tab, reselect it
                        if isPinnedTabActive and PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
                            for _, tab in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                                if tab.section and tab.section.name == "Pinned" then
                                    tab:GetScript("OnClick")(tab)
                                    break
                                end
                            end
                        end
                    end
                else	                            
                    if frame.pin then
                        frame.pin:SetAlpha(1)
                    end
                    local t = {
                        mountID = "m"..mountID,
                        category = frame.category,
                        section = frame.section
                    }
                    if pin_count == nil then
                        PCL_PINNED[1] = t
                    else
                        PCL_PINNED[pin_count+1] = t
                    end
                    
                    -- Set flag to indicate pinned mounts have been modified
                    PCLcore.pinnedMountsChanged = true
                    
                    PCLcore.Function:CreatePinnedPet(petID, frame.category, frame.section)
                    -- Update all pin icons for this mount
                    PCLcore.Function:UpdateAllPinIcons(mountID)

                    -- Refresh the pinned tab layout after pinning
                    C_Timer.After(0.1, function()
                        if PCL_frames and PCL_frames.SetTabs then
                            -- Check if we're currently viewing the Pinned tab
                            local isPinnedTabActive = false
                            if PCLcore.currentlySelectedTab and PCLcore.currentlySelectedTab.section and PCLcore.currentlySelectedTab.section.name == "Pinned" then
                                isPinnedTabActive = true
                            end
                            
                            -- Refresh the tabs to update the pinned content
                            PCLcore.Frames:SetTabs()
                            
                            -- If we were on the Pinned tab, reselect it
                            if isPinnedTabActive and PCLcore.PCL_MF_Nav and PCLcore.PCL_MF_Nav.tabs then
                                for _, tab in ipairs(PCLcore.PCL_MF_Nav.tabs) do
                                    if tab.section and tab.section.name == "Pinned" then
                                        tab:GetScript("OnClick")(tab)
                                        break
                                    end
                                end
                            end
                        end
                    end)

                end
            end               
        elseif button=='LeftButton' then
            if IsShiftKeyDown() then
                -- Handle shift-click to link mount in chat
                if itemLink and ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(itemLink)
                elseif spellID then
                    local spellLink = C_Spell.GetSpellLink(spellID)
                    if spellLink and ChatEdit_GetActiveWindow() then
                        ChatEdit_InsertLink(spellLink)
                    end
                end
            elseif isSteadyFlight then
                if frame.pop and frame.pop:IsShown() then 
                    frame.pop:Hide()
                elseif frame.pop then
                    frame.pop:Show()
                end
            else
                -- Don't add conflicting OnClick handlers here since OnMouseDown is already handling mouse events
                -- Shift-click functionality is handled in SetMouseClickFunctionality
            end
        end
        if button == 'MiddleButton' then
            -- Middle click to cast mount if it's collected
            if IsPetCollected(mountID) then
                CastSpellByName(mountName);
            end
        end
    end)
end

-- LinkPetItem function - handles pet frame interactions and tooltips
function PCL_functions:LinkPetItem(id, frame, pin)
    -- For now, just add basic click functionality without hover preview
    -- We'll add the hover preview back once the basic functionality works
    if string.sub(tostring(id), 1, 1) == "p" then
        local petSpeciesID = tonumber(string.sub(id, 2, -1))
        
        if not frame then
            return
        end
        
        -- Ensure the frame can receive mouse events
        frame:EnableMouse(true)
        
        -- Add hover functionality for pet preview using embedded PetCard
        frame:SetScript("OnEnter", function(self)
            if PCLcore.PetCard and PCLcore.PetCard.Show then
                -- Create pet data object for the embedded pet card
                local petData = { speciesID = petSpeciesID }
                PCLcore.PetCard:Show(petData)
            end
        end)
        
        frame:SetScript("OnLeave", function(self)
            -- Pet card will remain open when mouse leaves the pet frame
        end)
        
        -- Add click functionality
        if pin == true then
            if PCLcore.Function.SetPetClickFunctionalityPin then
                PCLcore.Function:SetPetClickFunctionalityPin(frame, petSpeciesID, nil, nil, nil)
            end
        else
            if PCLcore.Function.SetPetClickFunctionality then
                PCLcore.Function:SetPetClickFunctionality(frame, petSpeciesID, nil, nil, nil)
            end
        end  
    else
        if pin == true then
            if PCLcore.Function.SetMouseClickFunctionalityPin then
                PCLcore.Function:SetMouseClickFunctionalityPin(frame, id, nil, nil, nil, nil)
            end
        else
            if PCLcore.Function.SetMouseClickFunctionality then
                PCLcore.Function:SetMouseClickFunctionality(frame, id, nil, nil, nil, nil)
            end
        end
    end
end

-- Pet Preview Frame Functions
local petPreviewFrame = nil

function PCL_functions:CreatePetPreviewFrame()
    if petPreviewFrame then
        return petPreviewFrame
    end
    
    -- Create the main preview frame using the same template as navigation frame
    local frameTemplate = PCL_SETTINGS.useBlizzardTheme and "PCLBlizzardNavTemplate" or "BackdropTemplate"
    petPreviewFrame = CreateFrame("Frame", "PCL_PetPreviewFrame", UIParent, frameTemplate)
    petPreviewFrame:SetSize(380, 280)
    petPreviewFrame:SetPoint("CENTER", UIParent, "CENTER")
    petPreviewFrame:SetFrameStrata("TOOLTIP")
    petPreviewFrame:SetFrameLevel(1000)
    petPreviewFrame:Hide()
    
    -- Apply the exact same styling as navigation frame
    if PCL_SETTINGS.useBlizzardTheme then
        -- Blizzard-style backdrop with proper textures (same as nav frame)
        if petPreviewFrame.SetBackdrop then
            petPreviewFrame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", 
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
                edgeSize = 16,
                insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            petPreviewFrame:SetBackdropColor(0.05, 0.05, 0.15, 0.95)  -- Dark blue tint with higher opacity
            petPreviewFrame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)  -- Blue-gray border
        end
    else
        -- Default theme - dark background with proper opacity (same as nav frame)
        if petPreviewFrame.SetBackdrop then
            petPreviewFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
            petPreviewFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)  -- Same as nav frame
            petPreviewFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)  -- Same as nav frame
        end
    end
    
    -- Create header section matching navigation frame title area
    petPreviewFrame.header = CreateFrame("Frame", nil, petPreviewFrame, "BackdropTemplate")
    petPreviewFrame.header:SetSize(364, 50)  -- Full width minus margins
    petPreviewFrame.header:SetPoint("TOPLEFT", petPreviewFrame, "TOPLEFT", 8, -8)
    
    -- Header has no background to match navigation frame clean style
    petPreviewFrame.header:SetBackdrop(nil)
    
    -- Dominant pet name title
    petPreviewFrame.petName = petPreviewFrame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    petPreviewFrame.petName:SetPoint("TOPLEFT", petPreviewFrame.header, "TOPLEFT", 12, -8)
    petPreviewFrame.petName:SetPoint("TOPRIGHT", petPreviewFrame.header, "TOPRIGHT", -80, -8)  -- Leave space for collection status
    petPreviewFrame.petName:SetText("Pet Name")
    -- Use same text styling as navigation frame title
    if PCL_SETTINGS.useBlizzardTheme then
        petPreviewFrame.petName:SetTextColor(1, 0.82, 0, 1)  -- Gold color like Blizzard UI
    else
        petPreviewFrame.petName:SetTextColor(1, 1, 1, 1)  -- White for default theme
    end
    petPreviewFrame.petName:SetJustifyH("LEFT")
    petPreviewFrame.petName:SetWordWrap(false)
    
    -- Pet type/family subtitle with icon
    petPreviewFrame.petTypeIcon = petPreviewFrame.header:CreateTexture(nil, "OVERLAY")
    petPreviewFrame.petTypeIcon:SetSize(16, 16)
    petPreviewFrame.petTypeIcon:SetPoint("TOPLEFT", petPreviewFrame.petName, "BOTTOMLEFT", 0, -6)
    
    petPreviewFrame.petType = petPreviewFrame.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    petPreviewFrame.petType:SetPoint("LEFT", petPreviewFrame.petTypeIcon, "RIGHT", 4, 0)
    petPreviewFrame.petType:SetText("Pet Type")
    if PCL_SETTINGS.useBlizzardTheme then
        petPreviewFrame.petType:SetTextColor(1, 1, 0, 1)  -- Yellow for Blizzard theme
    else
        petPreviewFrame.petType:SetTextColor(1, 1, 0, 1)  -- Yellow for default theme
    end
    petPreviewFrame.petType:SetJustifyH("LEFT")
    
    -- Collection status in top right (more prominent)
    petPreviewFrame.collectionStatus = petPreviewFrame.header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    petPreviewFrame.collectionStatus:SetPoint("TOPRIGHT", petPreviewFrame.header, "TOPRIGHT", -12, -15)
    petPreviewFrame.collectionStatus:SetText("Collection Status")
    petPreviewFrame.collectionStatus:SetJustifyH("RIGHT")
    
    -- Create model section with minimal styling to match navigation frame content area
    petPreviewFrame.modelSection = CreateFrame("Frame", nil, petPreviewFrame, "BackdropTemplate")
    petPreviewFrame.modelSection:SetSize(364, 200)  -- Larger model area
    petPreviewFrame.modelSection:SetPoint("TOPLEFT", petPreviewFrame.header, "BOTTOMLEFT", 0, -12)
    
    -- Minimal styling to match navigation frame clean look
    petPreviewFrame.modelSection:SetBackdrop(nil)  -- No background/border for clean look
    
    -- Create 3D model frame that fills most of the model section
    petPreviewFrame.model = CreateFrame("PlayerModel", nil, petPreviewFrame.modelSection)
    petPreviewFrame.model:SetSize(356, 192)  -- Fill model section minus padding
    petPreviewFrame.model:SetPoint("CENTER", petPreviewFrame.modelSection, "CENTER")
    
    -- No corner decorations to match navigation frame clean style
    
    -- Add OnShow script to refresh model when frame becomes visible
    petPreviewFrame:SetScript("OnShow", function(self)
        if self.model and self.currentCreatureID then
            C_Timer.After(0.1, function()
                if self:IsShown() and self.model then
                    self.model:RefreshCamera()
                    if self.currentCreatureID > 0 then
                        self.model:SetCreature(self.currentCreatureID)
                    end
                    self.model:SetCamDistanceScale(1.8)  -- Increased distance to show full pet
                    self.model:SetRotation(0.3)
                end
            end)
        end
    end)
    
    return petPreviewFrame
end

function PCL_functions:ShowPetPreview(petSpeciesID, anchorFrame)
    if not petSpeciesID or not anchorFrame then
        return
    end
    
    -- Create preview frame if it doesn't exist
    if not petPreviewFrame then
        self:CreatePetPreviewFrame()
    end
    
    -- Get pet information
    local petName, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID)
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(petSpeciesID)
    local isCollected = numCollected and numCollected > 0
    
    -- Better handling for collection counts 
    local actualCollected = numCollected or 0
    local actualLimit = limit
    
    -- More aggressive collection count handling with unique pet detection
    local actualCollected = numCollected or 0
    local actualLimit = limit
    
    -- List of known unique pets (species IDs that can only be collected once)
    local uniquePets = {
        -- Add specific species IDs for pets that are truly unique
        -- This list can be expanded as needed
    }
    
    -- Check if this pet is in the known unique pets list
    local isKnownUnique = false
    for _, uniqueID in ipairs(uniquePets) do
        if uniqueID == petSpeciesID then
            isKnownUnique = true
            break
        end
    end
    
    -- Handle API inconsistencies
    if not actualLimit or actualLimit == 0 then
        actualLimit = 3  -- Default fallback for nil/0 limits
    elseif actualLimit == 1 and not isKnownUnique then
        -- Most pets can be collected 3 times, override limit=1 unless it's a known unique pet
        actualLimit = 3
    elseif actualLimit == 1 and isKnownUnique then
        -- Keep limit as 1 for known unique pets
    else
        -- Use the API provided limit
    end
    
    if not petName then
        return
    end
    
    -- Update pet information with improved formatting
    petPreviewFrame.petName:SetText(petName or "Unknown Pet")
    
    -- Convert pet type number to readable string and set icon
    local petTypeNames = {
        [1] = "Humanoid", [2] = "Dragonkin", [3] = "Flying", [4] = "Undead", [5] = "Critter",
        [6] = "Magic", [7] = "Elemental", [8] = "Beast", [9] = "Aquatic", [10] = "Mechanical"
    }
    local petTypeIcons = {
        [1] = "Interface\\Icons\\Pet_Type_Humanoid",   -- Humanoid
        [2] = "Interface\\Icons\\Pet_Type_Dragon",     -- Dragonkin
        [3] = "Interface\\Icons\\Pet_Type_Flying",     -- Flying
        [4] = "Interface\\Icons\\Pet_Type_Undead",     -- Undead
        [5] = "Interface\\Icons\\Pet_Type_Critter",    -- Critter
        [6] = "Interface\\Icons\\Pet_Type_Magical",    -- Magic
        [7] = "Interface\\Icons\\Pet_Type_Elemental",  -- Elemental
        [8] = "Interface\\Icons\\Pet_Type_Beast",      -- Beast
        [9] = "Interface\\Icons\\Pet_Type_Water",      -- Aquatic
        [10] = "Interface\\Icons\\Pet_Type_Mechanical"  -- Mechanical
    }
    local typeName = petTypeNames[petType] or "Unknown"
    local typeIcon = petTypeIcons[petType] or "Interface\\Icons\\inv_misc_questionmark"
    
    petPreviewFrame.petType:SetText(typeName)
    petPreviewFrame.petTypeIcon:SetTexture(typeIcon)
    
    -- Enhanced collection status with count information
    local collectedCount = actualCollected
    local maxCount = actualLimit
    
    if isCollected then
        local statusText = "|cff00ff00COLLECTED|r\n|cffaaaaaa(" .. collectedCount .. "/" .. maxCount .. ")|r"
        petPreviewFrame.collectionStatus:SetText(statusText)
    else
        local statusText = "|cffff4444NOT COLLECTED|r\n|cffaaaaaa(" .. collectedCount .. "/" .. maxCount .. ")|r"
        petPreviewFrame.collectionStatus:SetText(statusText)
    end
    
    -- Try to set the 3D model
    if petPreviewFrame.model then
        -- Clear any existing model
        petPreviewFrame.model:ClearModel()
        
        -- Force the model to reset its state
        petPreviewFrame.model:SetModelScale(1)
        petPreviewFrame.model:SetPosition(0, 0, 0)
        
        -- Try to set the pet model using various methods
        local success = false
        
        -- Method 1: Try to use creature display ID if available
        if companionID then
            local creatureID = companionID
            if creatureID and creatureID > 0 then
                petPreviewFrame.model:SetCreature(creatureID)
                petPreviewFrame.currentCreatureID = creatureID  -- Store for OnShow refresh
                success = true
            end
        end
        
        -- Method 2: Fallback - try setting a generic pet model
        if not success then
            petPreviewFrame.model:SetCreature(42722) -- Generic rabbit model as fallback
            petPreviewFrame.currentCreatureID = 42722  -- Store for OnShow refresh
        end
        
        -- Position and scale the model with a slight delay to ensure it loads
        C_Timer.After(0.1, function()
            if petPreviewFrame.model then
                petPreviewFrame.model:SetCamDistanceScale(1.8)  -- Increased distance to show full pet
                petPreviewFrame.model:SetRotation(0.3)
                petPreviewFrame.model:RefreshCamera()
            end
        end)
        
        -- Also apply immediate positioning as backup
        petPreviewFrame.model:SetCamDistanceScale(1.8)  -- Increased distance to show full pet
        petPreviewFrame.model:SetRotation(0.3)
    end
    
    -- Position the preview frame near the pet icon
    petPreviewFrame:ClearAllPoints()
    petPreviewFrame:SetPoint("BOTTOMLEFT", anchorFrame, "TOPRIGHT", 10, 0)
    
    -- Make sure it stays on screen
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local frameRight = petPreviewFrame:GetRight()
    local frameTop = petPreviewFrame:GetTop()
    
    if frameRight and frameRight > screenWidth then
        petPreviewFrame:ClearAllPoints()
        petPreviewFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPLEFT", -10, 0)
    end
    
    if frameTop and frameTop > screenHeight then
        petPreviewFrame:ClearAllPoints()
        petPreviewFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMRIGHT", 10, -10)
    end
    
    -- Show the frame
    petPreviewFrame:Show()
    
    -- Force model refresh after showing the frame
    if petPreviewFrame.model then
        C_Timer.After(0.05, function()
            if petPreviewFrame and petPreviewFrame:IsShown() and petPreviewFrame.model then
                -- Try to refresh the model display
                petPreviewFrame.model:RefreshCamera()
                
                -- Re-apply the creature if needed
                if companionID and companionID > 0 then
                    petPreviewFrame.model:SetCreature(companionID)
                else
                    petPreviewFrame.model:SetCreature(42722) -- Fallback
                end
                
                petPreviewFrame.model:SetCamDistanceScale(1.8)  -- Increased distance to show full pet
                petPreviewFrame.model:SetRotation(0.3)
            end
        end)
    end
end

function PCL_functions:HidePetPreview()
    if petPreviewFrame then
        petPreviewFrame:Hide()
    end
end

-- Add these functions to the PCLcore.Function namespace
PCLcore.Function.CreatePetPreviewFrame = PCL_functions.CreatePetPreviewFrame
PCLcore.Function.ShowPetPreview = PCL_functions.ShowPetPreview
PCLcore.Function.HidePetPreview = PCL_functions.HidePetPreview

-- Function to create pet frames for a category (needed for pinned pets)
function PCL_functions:CreatePetsForCategory(petData, parentFrame, yOffset, tabFrame, isPinned, visible)
    if not petData or not parentFrame then
        return false, {}
    end
    
    local petFrames = {}
    local currentX = 20  -- Starting X position
    local currentY = yOffset or -30  -- Starting Y position
    local petsPerRow = PCL_SETTINGS.PetsPerRow or 12
    local petSize = 36
    local spacing = 5
    
    -- Calculate available width for pets
    local parentWidth = parentFrame:GetWidth() or 600
    local availableWidth = parentWidth - 40  -- Leave some margin
    
    -- Adjust pets per row if needed to fit the space
    local totalWidthNeeded = petsPerRow * petSize + (petsPerRow - 1) * spacing
    if totalWidthNeeded > availableWidth then
        petsPerRow = math.floor((availableWidth + spacing) / (petSize + spacing))
        petsPerRow = math.max(1, petsPerRow)  -- Ensure at least 1 pet per row
    end
    
    local currentIndex = 0
    
    -- Process pets based on data type
    if type(petData) == "table" then
        for i, pet in ipairs(petData) do
            if pet and pet.petID then
                local petSpeciesID = tonumber(pet.petID)
                if petSpeciesID then
                    -- Apply filtering - skip pet if it should be filtered
                    local shouldFilterByFamily = PCLcore.Function.ShouldFilterPetByFamily and PCLcore.Function:ShouldFilterPetByFamily(petSpeciesID, PCL_SETTINGS.selectedFamily)
                    local shouldFilterByQuality = PCLcore.Function.ShouldFilterPetByQuality and PCLcore.Function:ShouldFilterPetByQuality(petSpeciesID)
                    
                    if shouldFilterByFamily or shouldFilterByQuality then
                        -- Skip this pet due to filtering
                    else
                        -- Get pet info first to check if pet exists
                        local petName, icon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoBySpeciesID(petSpeciesID)
                        
                        -- Only create frame if pet exists
                        if petName then
                            -- Calculate position
                            local col = currentIndex % petsPerRow
                            local row = math.floor(currentIndex / petsPerRow)
                            local x = currentX + col * (petSize + spacing)
                            local y = currentY - row * (petSize + spacing + 5)  -- Extra spacing between rows
                            
                            -- Create pet frame only if pet exists
                    local petFrame = CreateFrame("Button", nil, parentFrame, "BackdropTemplate")
                    petFrame:SetSize(petSize, petSize)
                    petFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
                    
                    -- Set backdrop
                    petFrame:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        edgeSize = 2
                    })
                    
                    if icon then
                        -- Create icon texture
                        petFrame.tex = petFrame:CreateTexture(nil, "ARTWORK")
                        petFrame.tex:SetAllPoints(petFrame)
                        petFrame.tex:SetTexture(icon)
                        
                        -- Create pin icon
                        petFrame.pin = petFrame:CreateTexture(nil, "OVERLAY")
                        petFrame.pin:SetWidth(16)
                        petFrame.pin:SetHeight(16)
                        petFrame.pin:SetTexture("Interface\\AddOns\\PCL\\icons\\pin.blp")
                        petFrame.pin:SetPoint("TOPRIGHT", petFrame, "TOPRIGHT", 6, 6)
                        petFrame.pin:SetAlpha(1)  -- Always visible for pinned pets
                        
                        -- Set frame properties
                        petFrame.petID = "p" .. petSpeciesID
                        petFrame.category = pet.category or "Unknown"
                        petFrame.section = pet.section or "Unknown"
                        
                        -- Style based on collection status
                        local isCollected = IsPetCollected(petSpeciesID)
                        if isCollected then
                            petFrame.tex:SetVertexColor(1, 1, 1, 1)
                            petFrame:SetBackdropColor(0, 0.8, 0, 0.6)
                        else
                            petFrame.tex:SetVertexColor(0.4, 0.4, 0.4, 0.7)
                            petFrame:SetBackdropColor(0.3, 0.1, 0.1, 0.4)
                        end
                        
                        -- Apply pet quality border
                        if PCLcore.Function.ApplyPetQualityBorder then
                            PCLcore.Function:ApplyPetQualityBorder(petFrame, petSpeciesID, isCollected)
                        else
                            -- Fallback border styling
                            if isCollected then
                                petFrame:SetBackdropBorderColor(0, 1, 0, 1)
                            else
                                petFrame:SetBackdropBorderColor(0.6, 0.2, 0.2, 0.8)
                            end
                        end
                        
                        -- Add pet level display if enabled
                        if PCLcore.Function.AddPetLevelDisplay then
                            PCLcore.Function:AddPetLevelDisplay(petFrame, petSpeciesID, isCollected)
                        end
                        
                        -- Add breed collection status indicator
                        if PCLcore.Function.AddBreedCollectionStatus then
                            PCLcore.Function:AddBreedCollectionStatus(petFrame, petSpeciesID, isCollected)
                        end
                        
                        -- Add click functionality for pinned pets (can unpin)
                        if PCLcore.Function.SetPetClickFunctionalityPin then
                            PCLcore.Function:SetPetClickFunctionalityPin(petFrame, petSpeciesID, petName, nil, nil)
                        end
                        
                        -- Add hover functionality
                        if PCLcore.Function.LinkPetItem then
                            PCLcore.Function:LinkPetItem("p" .. petSpeciesID, petFrame, true)
                        end
                        
                        -- Enable mouse and show frame
                        petFrame:EnableMouse(true)
                        if visible then
                            petFrame:Show()
                        end
                        
                        table.insert(petFrames, petFrame)
                        currentIndex = currentIndex + 1
                        end -- Close if petName (pet exists)
                    end -- Close else (not filtered)
                end -- Close if petSpeciesID
            end -- Close if pet and pet.petID
        end -- Close for i, pet in ipairs(petData)
    end -- Close if type(petData) == "table"
    end
    
    return false, petFrames  -- First return value indicates overflow (false for now)
end

-- Add to PCLcore.Function namespace
PCLcore.Function.CreatePetsForCategory = PCL_functions.CreatePetsForCategory
PCLcore.Function.UpdateCollection = PCL_functions.UpdateCollection
PCLcore.Function.CalculateSectionStats = PCL_functions.CalculateSectionStats
PCLcore.Function.GetPetQuality = PCL_functions.GetPetQuality
PCLcore.Function.ApplyPetQualityBorder = PCL_functions.ApplyPetQualityBorder
PCLcore.Function.AddPetLevelDisplay = PCL_functions.AddPetLevelDisplay
PCLcore.Function.AddBreedCollectionStatus = PCL_functions.AddBreedCollectionStatus
PCLcore.Function.ShouldFilterPetByFamily = PCL_functions.ShouldFilterPetByFamily
PCLcore.Function.ShouldFilterPetByQuality = PCL_functions.ShouldFilterPetByQuality
PCLcore.Function.CreateFullBorder = PCL_functions.CreateFullBorder

-- Ensure the LinkPetItem function is properly exposed
-- This is needed because frames.lua checks for PCLcore.Function.LinkPetItem
if PCL_functions and PCL_functions.LinkPetItem then
    PCLcore.Function.LinkPetItem = PCL_functions.LinkPetItem
end
