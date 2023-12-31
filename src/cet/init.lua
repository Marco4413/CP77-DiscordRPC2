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

local GameUI = require "libs/cp2077-cet-kit/GameUI"
local Handlers = require "Handlers"
local Localization = require "Localization"

---@enum GameStates
local GameStates = {
    None = 0,
    MainMenu = 1,
    DeathMenu = 2,
    PauseMenu = 3,
    Playing = 4,
    Loading = 5
}

---@class CP77RPC2
local CP77RPC2 = {
    ---@type PlayerPuppet Only available in Activity Handlers
    player = nil,
    gameState = GameStates.MainMenu,
    startedAt = 0,
    ---@type number|nil
    playthroughTime = nil, -- Available on save load
    elapsedInterval = 0,
    showUI = false,
    enabled = true,
    submitInterval = 1,
    style = "",
    showQuest = true,
    showQuestObjective = false,
    showDrivingActivity = false,
    showCombatActivity = false,
    showPlaythroughTime = false,
    ---@type Activity|nil
    activity = nil,
    GameStates = GameStates,
    _handlers = { },
    GameUtils = require("GameUtils"),
    Localization = Localization
}

---@class Activity
---@field ApplicationId number
---@field Details string
---@field StartTimestamp number
---@field EndTimestamp number
---@field LargeImageKey string
---@field LargeImageText string
---@field SmallImageKey string
---@field SmallImageText string
---@field State string
---@field PartySize number
---@field PartyMax number

---@alias ActivityHandler fun(rpc:CP77RPC2, activity:Activity):boolean|nil

local function ConsoleLog(...)
    print("[ " .. os.date("%x %X") .. " ][ CP77RPC2 ]:", table.concat({ ... }))
end

---@param localeName string The name used internally by the Localization system to identify the locale
---@param locale table The key-value pairs defining the translation
---@return boolean ok Whether the locale was registered
---@return string|nil error The reason the locale was not registered, if any
function CP77RPC2.RegisterLocale(localeName, locale)
    return Localization:RegisterLocale(localeName, locale)
end

function CP77RPC2:GetREDInstance()
    return Game.GetScriptableSystemsContainer():Get("CP77RPC2.CP77RPC2")
end

function CP77RPC2:ResetConfig()
    self.enabled = true
    self.submitInterval = 5
    self.style = ""
    Localization:SetLocale("en")
    self.showQuest = true
    self.showQuestObjective = false
    self.showDrivingActivity = false
    self.showCombatActivity = false
    self.showPlaythroughTime = false
end

function CP77RPC2:SaveConfig()
    local file = io.open("data/config.json", "w")
    file:write(json.encode({
        enabled = self.enabled,
        submitInterval = self.submitInterval,
        style = self.style,
        locale = Localization:GetCurrentLocale().name,
        showQuest = self.showQuest,
        showQuestObjective = self.showQuestObjective,
        showDrivingActivity = self.showDrivingActivity,
        showCombatActivity = self.showCombatActivity,
        showPlaythroughTime = self.showPlaythroughTime,
    }))
    io.close(file)
end

function CP77RPC2:LoadConfig()
    local ok = pcall(function ()
        local file = io.open("data/config.json", "r")
        local configText = file:read("*a")
        io.close(file)

        local config = json.decode(configText)
        if type(config.enabled) == "boolean" then
            self.enabled = config.enabled
        end

        if type(config.submitInterval) == "number" then
            self.submitInterval = config.submitInterval
        end

        if type(config.style) == "string" then
            self.style = config.style
        end

        if type(config.locale) == "string" then
            if not Localization:SetLocale(config.locale) then
                ConsoleLog("Couldn't set '", config.locale, "' as main locale.")
            end
        end

        if type(config.showQuest) == "boolean" then
            self.showQuest = config.showQuest
        end

        if type(config.showQuestObjective) == "boolean" then
            self.showQuestObjective = config.showQuestObjective
        end

        if type(config.showDrivingActivity) == "boolean" then
            self.showDrivingActivity = config.showDrivingActivity
        end

        if type(config.showCombatActivity) == "boolean" then
            self.showCombatActivity = config.showCombatActivity
        end

        if type(config.showPlaythroughTime) == "boolean" then
            self.showPlaythroughTime = config.showPlaythroughTime
        end
    end)
    
    if not ok then
        self:SaveConfig()
    end
end

function CP77RPC2:SubmitActivity()
    local red = self:GetREDInstance()
    if not red then
        return
    elseif self.activity then
        red:UpdateActivity(self.activity)
    else
        red:ClearActivity()
    end
end

---@param handler ActivityHandler
function CP77RPC2:AddActivityHandler(handler)
    table.insert(self._handlers, handler)
    return handler
end

---@param handler ActivityHandler
function CP77RPC2:RemoveActivityHandler(handler)
    for i=#self._handlers, 1, -1 do
        if (self._handlers[i] == handler) then
            table.remove(self._handlers, i)
            break
        end
    end
end

function CP77RPC2:GetGenderImageKey(gender)
    return self.style == "PL" and table.concat{gender:lower(),"-pl"} or gender:lower()
end

local function Event_OnTweak()
    ConsoleLog("Registering extra locales.")
    local ok, error = CP77RPC2.RegisterLocale("it", require "locales/it")
    if not ok then
        ConsoleLog("Failed to register Italian translation: ", error)
    end
end

local function Event_OnInit()
    CP77RPC2:ResetConfig() -- Loads default settings
    CP77RPC2:LoadConfig()

    CP77RPC2.startedAt = os.time() * 1e3

    ObserveAfter("MenuScenario_SingleplayerMenu", "OnEnterScenario", function ()
        local metadata = Game.GetSystemRequestsHandler():GetLatestSaveMetadata()
        if metadata then
            CP77RPC2.playthroughTime = metadata.playthroughTime
            return
        end
        CP77RPC2.playthroughTime = nil
    end)

    ObserveAfter("gsmBaseRequestsHandler", "LoadLastCheckpoint", function (handler)
        local metadata = handler:GetLatestSaveMetadata()
        if metadata then
            CP77RPC2.playthroughTime = metadata.playthroughTime
            return
        end
        CP77RPC2.playthroughTime = nil
    end)

    ObserveAfter("LoadGameMenuGameController", "LoadGame", function (controller, item)
        if item.metadata then
            CP77RPC2.playthroughTime = item.metadata.playthroughTime
            return
        end
        CP77RPC2.playthroughTime = nil
    end)

    GameUI.OnSessionStart(function ()
        CP77RPC2.gameState = GameStates.Playing
    end)

    GameUI.OnLoadingStart(function ()
        CP77RPC2.gameState = GameStates.Loading
    end)

    GameUI.OnFastTravelFinish(function ()
        CP77RPC2.gameState = GameStates.Playing
    end)

    GameUI.OnMenuOpen(function (state)
        if state.menu == "MainMenu" then
            CP77RPC2.gameState = GameStates.MainMenu
        elseif state.menu == "DeathMenu" then
            CP77RPC2.gameState = GameStates.DeathMenu
        elseif state.menu == "PauseMenu" then
            CP77RPC2.gameState = GameStates.PauseMenu
        end
    end)

    GameUI.OnMenuClose(function (state)
        if state.lastMenu ~= "MainMenu" and state.lastMenu ~= "DeathMenu" then
            CP77RPC2.gameState = GameStates.Playing
        end
    end)

    ConsoleLog("Mod Initialized!")
end

local function Event_OnUpdate(dt)
    if not CP77RPC2.enabled then
        if CP77RPC2.activity then
            CP77RPC2.activity = nil
            CP77RPC2:SubmitActivity()
        end
        return
    end

    local red = CP77RPC2:GetREDInstance()
    if not red then return; end

    CP77RPC2.elapsedInterval = CP77RPC2.elapsedInterval + dt
    if CP77RPC2.elapsedInterval >= CP77RPC2.submitInterval then
        CP77RPC2.elapsedInterval = 0

        if CP77RPC2.gameState == GameStates.None then
            if CP77RPC2.activity then
                CP77RPC2.activity = nil
                CP77RPC2:SubmitActivity()
            end 
            return
        end

        ---@type Activity
        local activity = red:CreateDefaultActivity()
        activity.StartTimestamp = CP77RPC2.startedAt

        CP77RPC2.player = Game.GetPlayer()
        for i=#CP77RPC2._handlers, 1, -1 do
            if CP77RPC2._handlers[i](CP77RPC2, activity) then
                break
            end
        end

        CP77RPC2.activity = activity
        CP77RPC2:SubmitActivity()
    end
end

local function Event_OnShutdown()
    CP77RPC2.activity = nil
    CP77RPC2:SubmitActivity()
    CP77RPC2:SaveConfig()
end

local function Event_OnDraw()
    if not CP77RPC2.showUI then return; end

    if ImGui.Begin("CP77 - DiscordRPC 2") then
        ImGui.Text(Localization:Get("UI.Config.Activity.Label"))
        ImGui.SameLine()
        if ImGui.Button(Localization:Get("UI.Config.ForceUpdate")) then
            CP77RPC2.elapsedInterval = CP77RPC2.submitInterval + 1
        end

        ImGui.Separator()
        CP77RPC2.enabled = ImGui.Checkbox(Localization:Get("UI.Config.Enabled"), CP77RPC2.enabled)
        
        do
            local newValue, changed = ImGui.DragFloat(
                Localization:Get("UI.Config.SubmitInterval"),
                CP77RPC2.submitInterval, 0.01, 1, 3600, "%.2f")
            
            if changed then
                CP77RPC2.submitInterval = math.max(newValue, 1)
            end
        end

        if ImGui.Checkbox(Localization:Get("UI.Config.PLStyle"), CP77RPC2.style == "PL") then
            CP77RPC2.style = "PL"
        else
            CP77RPC2.style = ""
        end

        local currentLocale = Localization:GetCurrentLocale()
        if ImGui.BeginCombo("Language", currentLocale.displayName) then
            local locales = Localization:GetLocales()
        
            for _, locale in next, locales do
                local selected = locale.name == currentLocale.name
                if ImGui.Selectable(locale.displayName, selected) and not selected then
                    Localization:SetLocale(locale.name)
                end
            end
        
            ImGui.EndCombo()
        end

        ImGui.TextWrapped(table.concat {
            "Languages will not translate this text and the \"Language\" selection menu.",
            " So, if you change language by mistake, you can still navigate the UI properly to revert the change.",
            " Languages SHOULD NOT translate any part of the UI (albeit they could)."
        })

        CP77RPC2.showQuest = ImGui.Checkbox(Localization:Get("UI.Config.ShowQuest"), CP77RPC2.showQuest)
        if CP77RPC2.showQuest then
            CP77RPC2.showQuestObjective = ImGui.Checkbox(Localization:Get("UI.Config.ShowQuestObjective"), CP77RPC2.showQuestObjective)
        end

        CP77RPC2.showDrivingActivity = ImGui.Checkbox(Localization:Get("UI.Config.ShowDrivingActivity"), CP77RPC2.showDrivingActivity)
        CP77RPC2.showCombatActivity = ImGui.Checkbox(Localization:Get("UI.Config.ShowCombatActivity"), CP77RPC2.showCombatActivity)
        CP77RPC2.showPlaythroughTime = ImGui.Checkbox(Localization:Get("UI.Config.ShowPlaythroughTime"), CP77RPC2.showPlaythroughTime)

        ImGui.Separator()

        ImGui.Text(Localization:Get("UI.Config.Label"))
        ImGui.SameLine()

        if ImGui.Button(Localization:Get("UI.Config.Load")) then CP77RPC2:LoadConfig(); end
        ImGui.SameLine()

        if ImGui.Button(Localization:Get("UI.Config.Save")) then CP77RPC2:SaveConfig(); end
        ImGui.SameLine()

        if ImGui.Button(Localization:Get("UI.Config.Reset")) then CP77RPC2:ResetConfig(); end
        ImGui.Separator()

        if ImGui.CollapsingHeader("Debug") then
            local red = CP77RPC2:GetREDInstance()
            if red then
                ImGui.Text("Running: " .. (red:IsRunning() and "Yes" or "No"))
                ImGui.Text("Connected: " .. (red:IsConnected() and "Yes" or "No"))
                if red:IsOk() then
                    ImGui.Text("Error: No")
                else
                    ImGui.Text("Error: Yes (code=" .. tostring(red:GetLastRunCallbacksResult()) .. ")")
                end
            else
                ImGui.Text("redscript instance not found.")
            end
        end
        ImGui.Separator()
    end
    ImGui.End()
end

local function Event_OnOverlayOpen()
    CP77RPC2.showUI = true
end

local function Event_OnOverlayClose()
    CP77RPC2.showUI = false
end

function CP77RPC2:Init()
    Handlers:RegisterHandlers(CP77RPC2)
    registerForEvent("onTweak", Event_OnTweak)
    registerForEvent("onInit", Event_OnInit)
    registerForEvent("onUpdate", Event_OnUpdate)
    registerForEvent("onShutdown", Event_OnShutdown)
    registerForEvent("onDraw", Event_OnDraw)
    registerForEvent("onOverlayOpen", Event_OnOverlayOpen)
    registerForEvent("onOverlayClose", Event_OnOverlayClose)
    return self
end

return CP77RPC2:Init()
