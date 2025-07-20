local PCL, PCLcore = ...
local AceLocale = LibStub("AceLocale-3.0")

PCLcore.L = AceLocale:GetLocale("PCL", true)  -- 'true' ensures fallback to enUS if needed
