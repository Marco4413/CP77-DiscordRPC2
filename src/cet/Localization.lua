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

local Localization = {
    locale = {
        ["Default.LargeImageText"] = "Cyberpunk 2077",
        ["Loading.Details"] = "Loading...",
        ["MainMenu.Details"] = "Watching the Main Menu.",
        ["PauseMenu.Details"] = "Game Paused.",
        ["PauseMenu.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
        ["PauseMenu.SmallImageText"] = "{lifepath}",
        ["DeathMenu.Details"] = "Admiring the Death Menu.",
        ["DeathMenu.State"] = "No Armor?",
        ["Combat.Details"] = "Fighting with {health}/{maxHealth}HP",
        ["Combat.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
        ["Combat.SmallImageText"] = "{lifepath}",
        ["Combat.State.Weapon"] = "Using {weapon}",
        ["Combat.State.NoWeapon"] = "No weapon equipped.",
        ["Driving.Details"] = "Driving {vehicle}",
        ["Driving.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
        ["Driving.SmallImageText"] = "{lifepath}",
        ["Driving.State.Forward"] = "Cruising at {speed}km/h",
        ["Driving.State.Backwards"] = "Going backwards at {speed}km/h",
        ["Driving.State.Parked"] = "Currently parked.",
        ["Playing.Details"] = "Playing {name}",
        ["Playing.Details.Roaming"] = "Roaming.",
        ["Playing.Details.RoamingDistrict"] = "Roaming in {main}.",
        ["Playing.Details.RoamingSubDistrict"] = "Roaming in {sub},",
        ["Playing.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
        ["Playing.SmallImageText"] = "{lifepath}",
        ["Playing.State"] = "{objective}",
        ["Playing.State.Roaming"] = "",
        ["Playing.State.RoamingDistrict"] = "",
        ["Playing.State.RoamingSubDistrict"] = "{main}",
        ["UI.Config.Save"] = "Save",
        ["UI.Config.Load"] = "Load",
        ["UI.Config.Reset"] = "Reset",
        ["UI.Config.ForceUpdate"] = "Force Update",
        ["UI.Config.Enabled"] = "Enabled",
        ["UI.Config.SubmitInterval"] = "Submit Interval",
        ["UI.Config.PLStyle"] = "Phantom Liberty Style (changes gender image)",
        ["UI.Config.ShowQuest"] = "Show Quest",
        ["UI.Config.ShowQuestObjective"] = "Show Quest Objective",
        ["UI.Config.ShowDrivingActivity"] = "Show Driving Activity",
        ["UI.Config.ShowCombatActivity"] = "Show Combat Activity"
    }
}

---@param str string
---@param formats table
---@return string
function Localization.FormatString(str, formats)
    if not (str and formats) then return str; end
    local res = str:gsub("({([^}]+)})", function (expr, key)
        local format = formats[key] or formats[tonumber(key)]
        return (not format) and expr or format
    end)
    return res
end

function Localization:Get(key)
    return self.locale[key]
end

function Localization:GetFormatted(key, formats)
    return self.FormatString(self.locale[key], formats)
end

return Localization
