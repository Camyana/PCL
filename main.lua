-- * ------------------------------------------------------
-- *  Namespaces
-- * ------------------------------------------------------
local PCL, PCLcore = ...;

-- * ------------------------------------------------------
-- * Variables
-- * ------------------------------------------------------
PCLcore.Main = {};
local PCL_Load = PCLcore.Main;
local init_load = true
local load_check = 0
local region = GetCVar('portal')

-- New pet readiness tracking (adapted from MCL)
local petInit = {
    attempts = 0,
    maxAttempts = 40,          -- up to ~40 seconds worst case
    stableChecks = 0,
    requiredStableChecks = 2,   -- need two identical consecutive snapshots
    lastCount = 0,
    lastIDsHash = nil,
    initialized = false,
}

local function HashIDs(ids)
    if not ids then return 0 end
    table.sort(ids) -- safe; C_PetJournal returns a copy
    local acc = 0
    for i=1,#ids do
        acc = (acc * 33 + ids[i]) % 2147483647
    end
    return acc
end

local function IsPetAPIPartiallyReady()
    local numPets, numOwned = C_PetJournal.GetNumPets()
    if not numPets or numPets == 0 then return false end
    -- Sample one pet to see if we get full info
    local petID, speciesID = C_PetJournal.GetPetInfoByIndex(1)
    if petID and speciesID then
        local name = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        return (name ~= nil)
    end
    return false
end

local function PollPetJournalReadiness(callback)
    if petInit.initialized then return end
    petInit.attempts = petInit.attempts + 1

    local ready = IsPetAPIPartiallyReady()
    local numPets, _ = C_PetJournal.GetNumPets()
    local count = numPets or 0

    -- Create a simple hash based on count for now
    local hash = count

    if ready then
        if count == petInit.lastCount and hash == petInit.lastIDsHash then
            petInit.stableChecks = petInit.stableChecks + 1
        else
            petInit.stableChecks = 0
        end
        petInit.lastCount = count
        petInit.lastIDsHash = hash

        if petInit.stableChecks >= petInit.requiredStableChecks then
            petInit.initialized = true
            if callback then callback(true) end
            return
        end
    end

    if petInit.attempts >= petInit.maxAttempts then
        -- Give up waiting for perfect stability; proceed to avoid addon appearing broken.
        petInit.initialized = true
        if callback then callback(false) end
        return
    end

    C_Timer.After(1, function() PollPetJournalReadiness(callback) end)
end


-- * -------------------------------------------------
-- * Initialise Database
-- * Cycles through data.lua, checks if in game mount journal has an entry for mount. Restarts function if mount does is not loaded yet.
-- * Function is designed to check if the ingame mount journal has loaded correctly before loading our own database.
-- * -----------------------------------------------

function IsRegionalFiltered(id)
    if PCLcore.regionalFilter[region] ~= nil then
        for k, v in pairs(PCLcore.regionalFilter[region]) do
            if v == id then
                return true
            end
        end
    end
    return false
end

function CountPets()
    PCLcore.petList = PCLcore.petList or {}
    local count = 0
    for b, n in pairs(PCLcore.petList) do
        if type(n) == "table" then
            for h, j in pairs(n) do
                if type(j) == "table" then
                    for k, v in pairs(j) do
                        -- Ensure v.pets is a table before attempting to iterate over it
                        if type(v.pets) == "table" then
                            for kk, vv in pairs(v.pets) do
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return count
end

-- Global for Addon Compartment
PCL_OnAddonCompartmentClick = function()
    PCL_Load:Toggle()
end

-- Minimap Icon DataBroker Object
local LibDBIcon = LibStub("LibDBIcon-1.0", true)
local LibDataBroker = LibStub("LibDataBroker-1.1", true)

local PCLMinimapIcon = LibDataBroker and LibDataBroker:NewDataObject("PCL", {
    type = "launcher",
    text = "PCL",
    icon = "Interface\\AddOns\\PCL\\pcl-logo-32",
    OnClick = function(self, button)
        if button == "LeftButton" then
            PCL_Load:Toggle()
        elseif button == "RightButton" then
            -- Open settings
            if PCL_frames and PCL_frames.openSettings then
                PCL_frames:openSettings()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Pet Collection Log")
    end,
})

-- Initialize minimap icon
local function InitializeMinimapIcon()
    if not LibDBIcon or not PCLMinimapIcon then
        return
    end
    
    -- Ensure settings exist
    if not PCL_SETTINGS then
        PCL_SETTINGS = {}
    end
    
    -- Default to showing minimap icon
    if PCL_SETTINGS.showMinimapIcon == nil then
        PCL_SETTINGS.showMinimapIcon = true
    end
    
    if PCL_SETTINGS.minimapIcon == nil then
        PCL_SETTINGS.minimapIcon = {
            hide = not PCL_SETTINGS.showMinimapIcon,
        }
    end
    
    -- Register the minimap icon
    LibDBIcon:Register("PCL", PCLMinimapIcon, PCL_SETTINGS.minimapIcon)
    
    -- Show or hide based on setting
    if PCL_SETTINGS.showMinimapIcon then
        LibDBIcon:Show("PCL")
    else
        LibDBIcon:Hide("PCL")
    end
end

-- Save total pet count
local totalPetCount = CountPets()

-- Debugging variables
local debugMode = true -- Set to false to disable debugging
local invalidPets = {}
local validPets = {}

local function InitPets()
    load_check = 0
    totalPetCount = 0
    
    -- Reset debug tracking
    if debugMode then
        invalidPets = {}
        validPets = {}
    end
    
    for b,n in pairs(PCLcore.petList) do
        for h,j in pairs(n) do
            if (type(j) == "table") then
                for k,v in pairs(j) do
                    for kk,vv in pairs(v.pets) do
                        if not IsRegionalFiltered(vv) then
                            if not string.match(vv, "^p") then
                                totalPetCount = totalPetCount + 1
                                -- For pets, we work with species IDs directly
                                local petName = C_PetJournal.GetPetInfoBySpeciesID(vv)
                                if petName ~= nil then
                                    load_check = load_check + 1
                                    if debugMode then
                                        table.insert(validPets, {speciesID = vv, petName = petName, expansion = n.name, category = v.name})
                                    end
                                else
                                    -- Pet doesn't exist in game, but we'll count it as "loaded" to prevent infinite waiting
                                    load_check = load_check + 1
                                    if debugMode then
                                        table.insert(invalidPets, {speciesID = vv, expansion = n.name, category = v.name})
                                    end
                                end                            
                            else
                                -- Handle petID entries (strings starting with "p")
                                totalPetCount = totalPetCount + 1
                                load_check = load_check + 1
                                if debugMode then
                                    local petIDNum = tonumber(string.sub(vv, 2))
                                    local petName = C_PetJournal.GetPetInfoBySpeciesID(petIDNum)
                                    if not petName then
                                        table.insert(invalidPets, {petID = petIDNum, expansion = n.name, category = v.name, type = "petID"})
                                    else
                                        table.insert(validPets, {petID = petIDNum, petName = petName, expansion = n.name, category = v.name, type = "petID"})
                                    end
                                end
                            end
                        end                                     
                    end
                end
            end
        end
    end
    
    -- Debug summary (silent tracking only)
    if debugMode then
        -- Data is collected but not printed to chat
        -- invalidPets and validPets tables are populated for debugging if needed
    end
end


-- * -----------------------------------------------------
-- * Toggle the main window
-- * -----------------------------------------------------


PCLcore.dataLoaded = false

function PCL_Load:PreLoad()      
    if load_check >= totalPetCount then
        PCLcore.dataLoaded = true
        return true
    else   
        InitPets()         
        return false
    end
end

-- Set a maximum number of initialization retries
local MAX_INIT_RETRIES = 3

-- Initialization function
function PCL_Load:Init(force, showOnComplete)
    local function proceed()
        local retries = 0
        local function repeatCheck()
            if PCL_Load:PreLoad() then
                -- Initialization steps
                if PCLcore.PCL_MF == nil then
                    -- Ensure Frames module is available
                    if not PCLcore.Frames then
                        return false
                    end
                    
                    -- Ensure Frames module is properly loaded before creating main frame
                    if not PCLcore.Frames or not PCLcore.Frames.CreateMainFrame then
                        print("PCL Error: Frames module not properly loaded")
                        return false
                    end
                    
                    PCLcore.PCL_MF = PCLcore.Frames:CreateMainFrame()
                    PCLcore.PCL_MF:SetShown(false)
                    
                    -- Ensure Function module is available before calling methods
                    if PCLcore.Function and PCLcore.Function.initSections then
                        -- Data validation before initialization
                        local validationPassed = true
                        
                        -- Validate saved variables
                        if not PCL_DB or type(PCL_DB) ~= "table" then
                            print("PCL: Corrupted database detected, resetting...")
                            PCL_DB = {}
                            validationPassed = false
                        end
                        
                        if not PETLIST or type(PETLIST) ~= "table" then
                            print("PCL: Corrupted pet list detected, resetting...")
                            PETLIST = {}
                            validationPassed = false
                        end
                        
                        if not PCL_PINNED or type(PCL_PINNED) ~= "table" then
                            print("PCL: Corrupted pinned list detected, resetting...")
                            PCL_PINNED = {}
                            validationPassed = false
                        end
                        
                        if not PCL_SETTINGS or type(PCL_SETTINGS) ~= "table" then
                            print("PCL: Corrupted settings detected, resetting...")
                            PCL_SETTINGS = {}
                            validationPassed = false
                        end
                        
                        -- Wrap initialization in protected call
                        local success, error = pcall(PCLcore.Function.initSections, PCLcore.Function, true) -- Defer heavy operations
                        if not success then
                            print("PCL Error during initialization: " .. tostring(error))
                            print("PCL: Attempting recovery...")
                            
                            -- Try to recover by resetting data and trying again
                            PCL_DB = {}
                            PETLIST = {}
                            PCL_PINNED = {}
                            
                            local retrySuccess, retryError = pcall(PCLcore.Function.initSections, PCLcore.Function, true)
                            if not retrySuccess then
                                print("PCL Error: Recovery failed - " .. tostring(retryError))
                                return false
                            else
                                print("PCL: Recovery successful")
                            end
                        end
                    else
                        print("PCL Error: Function module or initSections not available")
                    end
                end
                
                -- Ensure Function module is available before updating collection
                if PCLcore.Function and PCLcore.Function.UpdateCollection then
                    -- Skip heavy stats calculation during initialization
                    PCLcore.Function:UpdateCollection(true)
                end
                
                -- If we should show the window after initialization, do so
                if showOnComplete and PCLcore.PCL_MF then
                    PCLcore.PCL_MF:Show()
                end
                
                init_load = false -- Ensure that the initialization does not repeat unnecessarily.
            else
                retries = retries + 1
                if retries < MAX_INIT_RETRIES then
                    -- Retry the initialization process after a delay
                    C_Timer.After(1, repeatCheck)
                end
            end
        end
        
        -- Force reinitialization if specifically requested
        if force then
            load_check = 0
            PCLcore.dataLoaded = false
        end
        
        -- Check if we need to attempt initialization
        if not PCLcore.dataLoaded then
            init_load = true
            repeatCheck()
        end
    end

    -- Begin with polling readiness (only once)
    if not petInit.initialized then
        PollPetJournalReadiness(function(stable)
            proceed()
        end)
    else
        proceed()
    end
end

-- Toggle function
function PCL_Load:Toggle()
    -- Check preload status and if false, attempt initialization
    if PCLcore.dataLoaded == false then
        PCL_Load:Init(false, true) -- Initialize and show when complete
        return
    end 
    if PCLcore.PCL_MF == nil then
        return -- Immune to function calls before the initialization process is complete, as the frame doesn't exist yet.
    else
        PCLcore.PCL_MF:SetShown(not PCLcore.PCL_MF:IsShown()) -- The addon's frame exists and can be toggled.
    end
end

local f = CreateFrame("Frame")
local login = true

-- * -------------------------------------------------
-- * Loads addon once Blizzard_Collections has loaded in.
-- * -------------------------------------------------

local function EnsureCollectionsLoaded()
    if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
        local ok = pcall(C_AddOns.LoadAddOn, "Blizzard_Collections")
        if not ok then
            -- Retry shortly if load failed (can happen very early on some clients)
            C_Timer.After(2, EnsureCollectionsLoaded)
            return false
        end
    end
    return true
end

local function ClearPetFilters()
    if C_PetJournal.SetFlagFilter then
        -- Show both collected and not collected
        pcall(C_PetJournal.SetFlagFilter, LE_PET_JOURNAL_FLAG_COLLECTED, true)
        pcall(C_PetJournal.SetFlagFilter, LE_PET_JOURNAL_FLAG_NOT_COLLECTED, true)
    end
    if C_PetJournal.SetSearchFilter then
        pcall(C_PetJournal.SetSearchFilter, "")
    end
    if C_PetJournal.SetAllPetTypesFilter then
        pcall(C_PetJournal.SetAllPetTypesFilter, true)
    end
    if C_PetJournal.SetAllPetSourcesFilter then
        pcall(C_PetJournal.SetAllPetSourcesFilter, true)
    end
end

local function onevent(self, event, arg1, ...)
    if(login and ((event == "ADDON_LOADED" and name == arg1) or (event == "PLAYER_LOGIN"))) then
        login = nil
        f:UnregisterEvent("ADDON_LOADED")
        f:UnregisterEvent("PLAYER_LOGIN")
        
        -- Force load Blizzard_Collections early
        EnsureCollectionsLoaded()
        ClearPetFilters()
        
        -- Safe initialization without Blizzard_Collections loading
        if PCLcore.Function and PCLcore.Function.AddonSettings then
            local success, err = pcall(function()
                PCLcore.Function:AddonSettings()
            end)
            if not success then
                print("|cffFF0000PCL:|r Settings initialization error:", err or "Unknown error")
            end
        end
        
        -- Initialize LibSharedMedia safely
        if PCLcore.InitializeLibSharedMedia then
            local success, err = pcall(function()
                PCLcore.InitializeLibSharedMedia()
            end)
            if not success then
                print("|cffFF0000PCL:|r LibSharedMedia initialization error:", err or "Unknown error")
            end
        end
        
        -- Initialize search functionality safely
        if PCLcore.InitializeSearch then
            local success, err = pcall(function()
                PCLcore.InitializeSearch()
            end)
            if not success then
                print("|cffFF0000PCL:|r Search initialization error:", err or "Unknown error")
            end
        end
        
        -- Initialize minimap icon
        local success, err = pcall(function()
            InitializeMinimapIcon()
        end)
        if not success then
            print("|cffFF0000PCL:|r Minimap icon initialization error:", err or "Unknown error")
        end
        
        -- Register slash commands
        SLASH_PCLICON1 = "/pclicon"
        SlashCmdList["PCLICON"] = function(msg)
            PCL_SETTINGS.showMinimapIcon = not PCL_SETTINGS.showMinimapIcon
            
            if not PCL_SETTINGS.minimapIcon then
                PCL_SETTINGS.minimapIcon = {}
            end
            PCL_SETTINGS.minimapIcon.hide = not PCL_SETTINGS.showMinimapIcon
            
            local LibDBIcon = LibStub("LibDBIcon-1.0", true)
            if LibDBIcon then
                if PCL_SETTINGS.showMinimapIcon then
                    LibDBIcon:Show("PCL")
                    print("|cff1FB7EBPCL:|r Minimap icon shown")
                else
                    LibDBIcon:Hide("PCL")
                    print("|cff1FB7EBPCL:|r Minimap icon hidden")
                end
            end
        end
        
        -- Start initialization after readiness polling handled inside :Init
        PCL_Load:Init()
        
        -- Initialize PetCard functionality
        if PCLcore.PetCard then
            PCLcore.PetCard:CreatePetCard()
        end
    end
end

-- Listen for late pet data to trigger re-scan if needed
local petListener = CreateFrame("Frame")
local pendingRescan
petListener:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
petListener:SetScript("OnEvent", function()
    if not PCLcore.dataLoaded then return end
    if pendingRescan then return end
    pendingRescan = true
    C_Timer.After(2, function()
        pendingRescan = nil
        if PCLcore.Function and PCLcore.Function.UpdateCollection then
            PCLcore.Function:UpdateCollection()
        end
    end)
end)

-- Events
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", onevent)