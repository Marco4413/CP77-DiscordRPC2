--[[
Copyright (c) 2023 [Marco4413](https://github.com/Marco4413/CP77-DiscordRPC2)

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

---@param self CP77RPC2
---@param activity Activity
function Handlers.Loading(self, activity)
    if self.gameState == self.GameStates.Loading then
        activity.Details = self.Localization:Get("Loading.Details")
        return true
    end
end

---@param self CP77RPC2
---@param activity Activity
function Handlers.MainMenu(self, activity)
    if self.gameState == self.GameStates.MainMenu then
        activity.Details = self.Localization:Get("MainMenu.Details")
        return true
    end
end

---@param self CP77RPC2
---@param activity Activity
function Handlers.PauseMenu(self, activity)
    if self.gameState == self.GameStates.PauseMenu and self.player then
        local level = GameUtils.GetLevel(self.player)
        local lifepath = GameUtils.GetLifePath(self.player)

        activity.Details = self.Localization:Get("PauseMenu.Details")
        activity.LargeImageKey = self:GetGenderImageKey(GameUtils.GetGender(self.player))
        activity.LargeImageText = self.Localization:GetFormatted("PauseMenu.LargeImageText", level)
        activity.SmallImageKey = lifepath:lower()
        activity.SmallImageText = self.Localization:GetFormatted("PauseMenu.SmallImageText", { lifepath = lifepath })
        activity.State = ""
        return true
    end
end

---@param self CP77RPC2
---@param activity Activity
function Handlers.DeathMenu(self, activity)
    if self.gameState == self.GameStates.DeathMenu then
        activity.LargeImageKey = "deathmenu"
        activity.Details = self.Localization:Get("DeathMenu.Details")
        activity.State = self.Localization:Get("DeathMenu.State")
        return true
    end
end

---@param self CP77RPC2
---@param activity Activity
function Handlers.Combat(self, activity)
    if not self.showCombatActivity then return; end
    if self.gameState == self.GameStates.Playing and self.player and self.player:IsInCombat() then
        local level = GameUtils.GetLevel(self.player)
        local lifepath = GameUtils.GetLifePath(self.player)
        local healthArmor = GameUtils.GetHealthArmor(self.player)
        local weaponName = GameUtils.GetWeaponName(self.player:GetActiveWeapon())
        
        activity.Details = self.Localization:GetFormatted("Combat.Details", healthArmor)
        activity.LargeImageKey = self:GetGenderImageKey(GameUtils.GetGender(self.player))
        activity.LargeImageText = self.Localization:GetFormatted("Combat.LargeImageText", level)
        activity.SmallImageKey = lifepath:lower()
        activity.SmallImageText = self.Localization:GetFormatted("Combat.SmallImageText", { lifepath = lifepath })
        activity.State = weaponName and
            self.Localization:GetFormatted("Combat.State.Weapon", { weapon = weaponName }) or
            self.Localization:Get("Combat.State.NoWeapon")
        return true
    end
end

---@param self CP77RPC2
---@param activity Activity
function Handlers.Driving(self, activity)
    if not self.showDrivingActivity then return; end
    if self.gameState == self.GameStates.Playing and self.player then
        local vehicle = Game.GetMountedVehicle(self.player)
        if vehicle and vehicle:IsPlayerDriver() then
            local level = GameUtils.GetLevel(self.player)
            local lifepath = GameUtils.GetLifePath(self.player)
            local vehicleName = vehicle:GetDisplayName()
            local vehicleSpeed = math.floor(vehicle:GetCurrentSpeed() * 3.6 + .5)
            
            activity.Details = self.Localization:GetFormatted("Driving.Details", { vehicle = vehicleName })
            activity.LargeImageKey = self:GetGenderImageKey(GameUtils.GetGender(self.player))
            activity.LargeImageText = self.Localization:GetFormatted("Driving.LargeImageText", level)
            activity.SmallImageKey = lifepath:lower()
            activity.SmallImageText = self.Localization:GetFormatted("Driving.SmallImageText", { lifepath = lifepath })

            if vehicleSpeed > 0 then
                activity.State = self.Localization:GetFormatted("Driving.State.Forward", { speed = vehicleSpeed })
            elseif vehicleSpeed < 0 then
                activity.State = self.Localization:GetFormatted("Driving.State.Backwards", { speed = -vehicleSpeed })
            else
                activity.State = self.Localization:Get("Driving.State.Parked")
            end
            return true
        end
    end
end

---@param self CP77RPC2
---@param activity Activity
function Handlers.Playing(self, activity)
    if self.gameState == self.GameStates.Playing and self.player then
        local questShown = false
        if self.showQuest then
            local questInfo = GameUtils.GetActiveQuest()
            if questInfo.name then
                questShown = true
                if not (self.showQuestObjective and questInfo.objective) then questInfo.objective = ""; end
                activity.Details = self.Localization:GetFormatted("Playing.Details", questInfo)
                activity.State = self.Localization:GetFormatted("Playing.State", questInfo)
            end
        end

        
        if not questShown then
            local district = GameUtils.GetDistrict()
            if district.main then
                if district.sub then
                    activity.Details = self.Localization:GetFormatted("Playing.Details.RoamingSubDistrict", district)
                    activity.State = self.Localization:GetFormatted("Playing.State.RoamingSubDistrict", district)
                else
                    activity.Details = self.Localization:GetFormatted("Playing.Details.RoamingDistrict", district)
                    activity.State = self.Localization:GetFormatted("Playing.State.RoamingDistrict", district)
                end
            else
                activity.Details = self.Localization:Get("Playing.Details.Roaming")
                activity.State = self.Localization:Get("Playing.State.Roaming")
            end
        end

        local level = GameUtils.GetLevel(self.player)
        local lifepath = GameUtils.GetLifePath(self.player)

        activity.LargeImageKey = self:GetGenderImageKey(GameUtils.GetGender(self.player))
        activity.LargeImageText = self.Localization:GetFormatted("Playing.LargeImageText", level)
        activity.SmallImageKey = lifepath:lower()
        activity.SmallImageText = self.Localization:GetFormatted("Playing.SmallImageText", { lifepath = lifepath })
        return true
    end
end

---@param mod CP77RPC2
function Handlers:RegisterHandlers(mod)
    mod:AddActivityHandler(self.Playing)
    mod:AddActivityHandler(self.Combat)
    mod:AddActivityHandler(self.Driving)
    mod:AddActivityHandler(self.DeathMenu)
    mod:AddActivityHandler(self.PauseMenu)
    mod:AddActivityHandler(self.MainMenu)
    mod:AddActivityHandler(self.Loading)
end

return Handlers
