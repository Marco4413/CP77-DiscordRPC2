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

local GameUtils = require "GameUtils"

local Handlers = { }

---@generic T
---@param mod CP77RPC
---@param activity Activity
---@param activityVars T
---@return T
function Handlers.SetCommonInfo(mod, activity, activityVars)
    if not activityVars then activityVars = {}; end
    local level = GameUtils.GetLevel(mod.player)
    local lifepath = GameUtils.GetLifePath(mod.player)
    activityVars.level = level.level
    activityVars.streetCred = level.streetCred
    activityVars.lifepath = mod.Localization:Get("Common.LifePath." .. (lifepath or "?"))

    activity.LargeImageKey = mod:GetGenderImageKey(GameUtils.GetGender(mod.player))
    activity.LargeImageText = mod.Localization:GetFormatted("Common.LargeImageText", activityVars)
    activity.SmallImageKey = lifepath:lower()
    if mod.showPlaythroughTime and mod.playthroughTime then
        activityVars.playthroughTime = math.floor(mod.playthroughTime / 3600)
        activity.SmallImageText = mod.Localization:GetFormatted("Common.SmallImageText.WPlaythroughTime", activityVars)
    else
        activity.SmallImageText = mod.Localization:GetFormatted("Common.SmallImageText", activityVars)
    end

    return activityVars
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.Loading(mod, activity)
    if mod.gameState == mod.GameStates.Loading then
        activity.Details = mod.Localization:Get("Loading.Details")
        return true
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.MainMenu(mod, activity)
    if mod.gameState == mod.GameStates.MainMenu then
        activity.Details = mod.Localization:Get("MainMenu.Details")
        return true
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.PauseMenu(mod, activity)
    if mod.gameState == mod.GameStates.PauseMenu and mod.player then
        local activityVars = Handlers.SetCommonInfo(mod, activity)
        activity.Details = mod.Localization:GetFormatted("PauseMenu.Details", activityVars)
        activity.State = ""
        return true
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.DeathMenu(mod, activity)
    if mod.gameState == mod.GameStates.DeathMenu then
        activity.LargeImageKey = "deathmenu"
        activity.Details = mod.Localization:Get("DeathMenu.Details")
        activity.State = mod.Localization:Get("DeathMenu.State")
        return true
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.Combat(mod, activity)
    if not mod.showCombatActivity then return; end
    if mod.gameState == mod.GameStates.Playing and mod.player and mod.player:IsInCombat() then
        local healthArmor = GameUtils.GetHealthArmor(mod.player)
        local weaponName = GameUtils.GetWeaponName(mod.player:GetActiveWeapon())
        local activityVars = Handlers.SetCommonInfo(mod, activity, {
            maxHealth = healthArmor.maxHealth,
            health = healthArmor.health,
            armor = healthArmor.armor,
            weapon = weaponName
        })
        
        activity.Details = mod.Localization:GetFormatted("Combat.Details", activityVars)
        activity.State = weaponName and
            mod.Localization:GetFormatted("Combat.State.Weapon", activityVars) or
            mod.Localization:GetFormatted("Combat.State.NoWeapon", activityVars)
        return true
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.Driving(mod, activity)
    if not mod.showDrivingActivity then return; end
    if mod.gameState == mod.GameStates.Playing and mod.player then
        local vehicle = Game.GetMountedVehicle(mod.player)
        local vehicleName = GameUtils.GetVehicleName(vehicle)
        if vehicleName and vehicle:IsPlayerDriver() then
            local speedUnit = mod.speedAsMPH and "mph" or "km/h"
            local vehicleSpeed, goingForward = GameUtils.GetVehicleSpeed(vehicle)
            -- 1.609344 is the conversion factor from mph to km/h
            if not mod.speedAsMPH then vehicleSpeed = vehicleSpeed * 1.609344; end
            -- local vehicleSpeed = math.floor(vehicle:GetCurrentSpeed() * (mod.speedAsMPH and 2.23693629192 or 3.6) + .5)
            local activityVars = Handlers.SetCommonInfo(mod, activity, {
                vehicle = vehicleName,
                speed = math.floor(vehicleSpeed + .5),
                speedUnit = speedUnit
            })
            
            activity.Details = mod.Localization:GetFormatted("Driving.Details", activityVars)
            if vehicleSpeed >= 1 then
                if goingForward then
                    activity.State = mod.Localization:GetFormatted("Driving.State.Forward", activityVars)
                else
                    activity.State = mod.Localization:GetFormatted("Driving.State.Backwards", activityVars)
                end
            else
                activity.State = mod.Localization:GetFormatted("Driving.State.Parked", activityVars)
            end
            return true
        end
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.Radio(mod, activity)
    if not mod.showRadioActivity then return; end
    if mod.gameState == mod.GameStates.Playing and mod.player then
        local vehicle = Game.GetMountedVehicle(mod.player)
        local vehicleName = GameUtils.GetVehicleName(vehicle)
        if vehicleName and vehicle:IsPlayerDriver() and vehicle:IsRadioReceiverActive() then
            local radioName
            local songName

            local radioExtStation = mod:GetRadioExtActiveStation();
            if radioExtStation then
                radioName = radioExtStation.radioName
                songName = radioExtStation.songName
            else
                radioName = Game.GetLocalizedTextByKey(vehicle:GetRadioReceiverStationName())
                songName = Game.GetLocalizedTextByKey(vehicle:GetRadioReceiverTrackName())
                if #songName == 0 then return false; end
            end

            local activityVars = Handlers.SetCommonInfo(mod, activity, { radio = radioName, song = songName, vehicle = vehicleName })

            activity.Details = mod.Localization:GetFormatted("Radio.Details.Vehicle", activityVars)
            activity.State = mod.Localization:GetFormatted("Radio.State.Vehicle", activityVars)
            return true
        end

        local pocketRadio = mod.player:GetPocketRadio()
        if pocketRadio and pocketRadio:IsActive() then
            local radioName
            local songName

            local radioExtStation = mod:GetRadioExtActiveStation();
            if radioExtStation then
                radioName = radioExtStation.radioName
                songName = radioExtStation.songName
            else
                radioName = Game.GetLocalizedTextByKey(pocketRadio:GetStationName())
                songName = Game.GetLocalizedTextByKey(pocketRadio:GetTrackName())
                if #songName == 0 then return false; end
            end

            local activityVars = Handlers.SetCommonInfo(mod, activity, { radio = radioName, song = songName })

            activity.Details = mod.Localization:GetFormatted("Radio.Details", activityVars)
            activity.State = mod.Localization:GetFormatted("Radio.State", activityVars)
            return true
        end
    end
end

---@param mod CP77RPC2
---@param activity Activity
function Handlers.Playing(mod, activity)
    if mod.gameState == mod.GameStates.Playing and mod.player then
        local questShown = false
        if mod.showQuest then
            local questInfo = GameUtils.GetActiveQuest()
            if questInfo.name then
                questShown = true
                local activityVars = Handlers.SetCommonInfo(mod, activity, {
                    quest = questInfo.name,
                    objective = questInfo.objective
                })
                if not (mod.showQuestObjective and activityVars.objective) then activityVars.objective = ""; end
                activity.Details = mod.Localization:GetFormatted("Playing.Details", activityVars)
                activity.State = mod.Localization:GetFormatted("Playing.State", activityVars)
            end
        end

        if not questShown then
            local district = GameUtils.GetDistrict()
            local activityVars = Handlers.SetCommonInfo(mod, activity, {
                district = district.main,
                subDistrict = district.sub
            })

            if district.main then
                if district.sub then
                    activity.Details = mod.Localization:GetFormatted("Playing.Details.Roaming.SubDistrict", activityVars)
                    activity.State = mod.Localization:GetFormatted("Playing.State.Roaming.SubDistrict", activityVars)
                else
                    activity.Details = mod.Localization:GetFormatted("Playing.Details.Roaming.District", activityVars)
                    activity.State = mod.Localization:GetFormatted("Playing.State.Roaming.District", activityVars)
                end
            else
                activity.Details = mod.Localization:GetFormatted("Playing.Details.Roaming", activityVars)
                activity.State = mod.Localization:GetFormatted("Playing.State.Roaming", activityVars)
            end
        end

        return true
    end
end

---@param mod CP77RPC2
function Handlers:RegisterHandlers(mod)
    mod:AddActivityHandler(self.Playing)
    mod:AddActivityHandler(self.Combat)
    mod:AddActivityHandler(self.Driving)
    mod:AddActivityHandler(self.Radio)
    mod:AddActivityHandler(self.DeathMenu)
    mod:AddActivityHandler(self.PauseMenu)
    mod:AddActivityHandler(self.MainMenu)
    mod:AddActivityHandler(self.Loading)
end

return Handlers
