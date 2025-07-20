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

-- Save total pet count
local totalPetCount = CountPets()

local function InitPets()
    load_check = 0
    -- Don't reset totalPetCount, we need it for comparison
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
                                end                            
                            end
                        end                                     
                    end
                end
            end
        end
    end
end


-- * -----------------------------------------------------
-- * Toggle the main window
-- * -----------------------------------------------------


PCLcore.dataLoaded = false

function PCL_Load:PreLoad()      
    local totalPetCount, _ = C_PetJournal.GetNumPets()
    
    if totalPetCount and totalPetCount > 0 then
        PCLcore.dataLoaded = true
        return true
    else
        return false
    end
end

-- Set a maximum number of initialization retries
local MAX_INIT_RETRIES = 3

-- Initialization function
function PCL_Load:Init(force)
    -- Force reinitialization if specifically requested
    if force then
        init_load = true
        PCLcore.dataLoaded = false
    end

    -- Check if we need to attempt initialization
    if not init_load and PCLcore.dataLoaded then
        return true
    end

    if PCL_Load:PreLoad() then
        -- Initialization steps
        if PCLcore.PCL_MF == nil then
            -- Ensure Frames module is available
            if not PCLcore.Frames then
                return false
            end
            PCLcore.PCL_MF = PCLcore.Frames:CreateMainFrame()
            PCLcore.PCL_MF:SetShown(false)
            
            if PCLcore.Function and PCLcore.Function.initSections then
                PCLcore.Function:initSections()
            end
        end
        
        if PCLcore.Function and PCLcore.Function.UpdateCollection then
            PCLcore.Function:UpdateCollection()
        end
        
        init_load = false -- Ensure that the initialization does not repeat unnecessarily.
        return true
    else
        return false
    end
end

-- Toggle function
function PCL_Load:Toggle()
    -- Check preload status and if false, prevent execution.
    if PCLcore.dataLoaded == false then
        PCL_Load:Init()
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


local function onevent(self, event, arg1, ...)
    if(login and ((event == "ADDON_LOADED" and name == arg1) or (event == "PLAYER_LOGIN"))) then
        login = nil
        f:UnregisterEvent("ADDON_LOADED")
        f:UnregisterEvent("PLAYER_LOGIN")
	    if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
	        C_AddOns.LoadAddOn("Blizzard_Collections")
	    end
        
        -- Ensure Function module is available before calling AddonSettings
        if PCLcore.Function and PCLcore.Function.AddonSettings then
            PCLcore.Function:AddonSettings()
        end
        
        -- Register for pet journal updates and try initial load
        f:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
        
        -- Try to initialize immediately (in case pet data is already available)
        PCL_Load:Init()
        
        -- Initialize LibSharedMedia first
        if PCLcore.InitializeLibSharedMedia then
            PCLcore.InitializeLibSharedMedia()
        end
        
        -- Initialize search functionality
        if PCLcore.InitializeSearch then
            PCLcore.InitializeSearch()
        end
        
        -- Initialize minimap icon after settings are ready
        if PCLcore.InitializeMinimapIcon then
            PCLcore.InitializeMinimapIcon()
        end
    elseif event == "PET_JOURNAL_LIST_UPDATE" then
        -- Pet journal data is now available, try to initialize
        if PCL_Load:Init() then
            -- Successfully initialized, no need to listen for more updates
            f:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")
        end
    end
end


-- function addon:MCL_MM() self.db.profile.minimap.hide = not self.db.profile.minimap.hide if self.db.profile.minimap.hide then icon:Hide("MCL-icon") else icon:Show("MCL-icon") end end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", onevent)