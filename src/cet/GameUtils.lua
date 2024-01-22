--[[
Copyright (c) 2024 [Marco4413](https://github.com/Marco4413/CP77-DiscordRPC2)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local GameUtils = { }

---@param player PlayerPuppet|nil
---@return string|nil
function GameUtils.GetLifePath(player)
    if not player then return nil; end
    local systems = Game.GetScriptableSystemsContainer()
    local devSystem = systems:Get("PlayerDevelopmentSystem")
    local devData = devSystem:GetDevelopmentData(player)
    return devData ~= nil and devData:GetLifePath().value or nil
end

---@param player PlayerPuppet|nil
function GameUtils.GetLevel(player)
    if not player then return { level = -1, streetCred = -1 }; end
    local statsSystem = Game.GetStatsSystem()
    local playerEntityId = player:GetEntityID()
    local level = statsSystem:GetStatValue(playerEntityId, gamedataStatType.Level)
    local streetCred = statsSystem:GetStatValue(playerEntityId, gamedataStatType.StreetCred)
    return { level = level or -1, streetCred = streetCred or -1 }
end

---@param player PlayerPuppet|nil
function GameUtils.GetHealthArmor(player)
    if not player then return { health = -1, maxHealth = -1, armor = -1 }; end
    local playerEntityId = player:GetEntityID()
    local statsPoolSystem = Game.GetStatPoolsSystem()
    local health = math.floor(statsPoolSystem:GetStatPoolValue(
        playerEntityId, gamedataStatPoolType.Health, false) + .5)
    local statsSystem = Game.GetStatsSystem()
    local maxHealth = math.floor(statsSystem:GetStatValue(playerEntityId, gamedataStatType.Health) + .5)
    local armor = math.floor(statsSystem:GetStatValue(playerEntityId, gamedataStatType.Armor) + .5)
    return { health = health, maxHealth = maxHealth, armor = armor }
end

---@param weapon gameweaponObject|nil
function GameUtils.GetWeaponName(weapon)
    if not weapon then return nil; end
    local weaponRecord = weapon:GetWeaponRecord()
    if not weaponRecord then return nil; end
    return Game.GetLocalizedTextByKey(weaponRecord:DisplayName())
end

function GameUtils.GetActiveQuest()
    local res = { name = nil, objective = nil }
    local journal = Game.GetJournalManager()

    -- Game Dump:
    -- gameJournalQuestObjective[ id:02_meet_hanako, entries:Array[ handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle)], description:LocKey#9874, counter:0, optional:false, locationPrefabRef:, itemID:, districtID: ]
    local questObjective = journal:GetTrackedEntry()
    if not questObjective then return res; end

    local descriptionLocKey = questObjective:GetDescription()
    res.objective = Game.GetLocalizedText(descriptionLocKey)

    -- Game Dump:
    -- gameJournalQuestPhase[ id:q115, entries:Array[ handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle)], locationPrefabRef: ]
    local questPhase = journal:GetParentEntry(questObjective)
    if not questPhase then return res; end

    -- Game Dump:
    -- gameJournalQuest[ id:02_sickness, entries:Array[ handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle) handle:gameJournalEntry(RT_Handle)], title:LocKey#9860, type:MainQuest, recommendedLevelID:, districtID: ]
    local quest = journal:GetParentEntry(questPhase)
    if not quest then return res; end

    local titleLocKey = quest:GetTitle(journal)
    res.name = Game.GetLocalizedText(titleLocKey)
    return res
end

---@param player PlayerPuppet|nil
function GameUtils.GetGender(player)
    if not player then return nil; end
    local genderName = player:GetResolvedGenderName()
    return genderName and genderName.value or nil
end

function GameUtils.GetDistrict()
    local preventionSystem = Game.GetScriptableSystemsContainer():Get("PreventionSystem")
    local districtManager = preventionSystem.districtManager
    if not districtManager then return {}; end

    local currentDistrict = districtManager:GetCurrentDistrict()
    if not currentDistrict then return {}; end
    
    local cdRecord = currentDistrict:GetDistrictRecord()
    local pdRecord = cdRecord:ParentDistrict()

    if pdRecord then
        return {
            main = GetLocalizedText(pdRecord:LocalizedName()),
            sub = GetLocalizedText(cdRecord:LocalizedName())
        }
    end

    return { main = GetLocalizedText(cdRecord:LocalizedName()) }
end

return GameUtils
