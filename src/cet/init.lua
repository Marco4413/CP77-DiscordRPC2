--[[
Copyright (c) 2025 [Marco4413](https://github.com/Marco4413/CP77-DiscordRPC2)

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
local BetterUI = require "BetterUI"
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
    overlayOnGame = false,
    enabled = true,
    submitInterval = 1,
    style = "",
    showQuest = true,
    showQuestObjective = false,
    showDrivingActivity = false,
    showCombatActivity = false,
    showRadioActivity = false,
    enableRadioExtIntegration = true,
    showPlaythroughTime = false,
    speedAsMPH = false,
    _configInitialized = false,
    ---@type Activity|nil
    activity = nil,
    GameStates = GameStates,
    _handlers = { },
    _initHandlersConfig = { },
    GameUtils = require("GameUtils"),
    Localization = Localization,
    RadioExt = nil
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

local function ConsoleWarn(...)
    print("[ " .. os.date("%x %X") .. " ][ CP77RPC2 ][ WARN ]:", table.concat({ ... }))
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
    self.showRadioActivity = false
    self.enableRadioExtIntegration = true
    self.showPlaythroughTime = false
    self.speedAsMPH = false

    self:SortActivityHandlersBy(self._initHandlersConfig)
    for i=1, #self._handlers do
        local h = self._handlers[i]
        h.enabled = self._initHandlersConfig[h.id].enabled
    end
end

function CP77RPC2:SaveConfig()
    local handlers = {}
    for i=1, #self._handlers do
        local h = self._handlers[i]
        handlers[h.id] = { order = i, enabled = h.enabled }
    end

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
        showRadioActivity = self.showRadioActivity,
        enableRadioExtIntegration = self.enableRadioExtIntegration,
        showPlaythroughTime = self.showPlaythroughTime,
        speedAsMPH = self.speedAsMPH,
        handlers = handlers,
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

        if type(config.showRadioActivity) == "boolean" then
            self.showRadioActivity = config.showRadioActivity
        end

        if type(config.enableRadioExtIntegration) == "boolean" then
            self.enableRadioExtIntegration = config.enableRadioExtIntegration
        end

        if type(config.showPlaythroughTime) == "boolean" then
            self.showPlaythroughTime = config.showPlaythroughTime
        end

        if type(config.speedAsMPH) == "boolean" then
            self.speedAsMPH = config.speedAsMPH
        end

        if type(config.handlers) == "table" then
            self:SortActivityHandlersBy(config.handlers)
            for i=1, #self._handlers do
                local h = self._handlers[i]
                local handlerConfig = config.handlers[h.id]
                if type(handlerConfig) == "table" and type(handlerConfig.enabled) == "boolean" then
                    h.enabled = handlerConfig.enabled
                end
            end
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

---Use this method within the onTweak CET event
---@param handlerId string An id which UNIQUELY identifies the provided handler
---@param handler ActivityHandler
---@param enabledByDefault boolean|nil
function CP77RPC2:SetActivityHandler(handlerId, handler, enabledByDefault)
    enabledByDefault = enabledByDefault == nil and true or (enabledByDefault and true or false)
    if self._handlers[handlerId] then
        ConsoleWarn("Handler: ", handlerId, " is being overridden.")

        self._handlers[handlerId] = handler
        for _, h in next, self._handlers do
            if h.id == handlerId then
                h.enabled = enabledByDefault
                h.handler = handler
                break
            end
        end
        self._initHandlersConfig[handlerId].enabled = enabledByDefault
    else
        self._handlers[handlerId] = handler
        table.insert(self._handlers, { id = handlerId, enabled = enabledByDefault, handler = handler })
        self._initHandlersConfig[handlerId] = { order = #self._handlers, enabled = enabledByDefault }
    end
end

---@param handlerId string
function CP77RPC2:DelActivityHandler(handlerId)
    if self._handlers[handlerId] then
        self._handlers[handlerId] = nil
        for i=#self._handlers, 1, -1 do
            if (self._handlers[i].id == handlerId) then
                table.remove(self._handlers, i)
                break
            end
        end

        local removedOrder = self._initHandlersConfig[handlerId]
        self._initHandlersConfig[handlerId] = nil
        for k, handlerConfig in next, self._initHandlersConfig do
            if handlerConfig.order > removedOrder then
                handlerConfig.order = handlerConfig.order - 1
            end
        end
    end
end

function CP77RPC2:GetActivityHandlerComparator(orders)
    return function (a, b)
        local prioA = orders[a.id]
        if type(prioA) == "table"  then prioA = prioA.order; end
        if type(prioA) ~= "number" then return false; end

        local prioB = orders[b.id]
        if type(prioB) == "table"  then prioB = prioB.order; end
        if type(prioB) ~= "number" then return true; end

        return prioA < prioB
    end
end

function CP77RPC2:SortActivityHandlersBy(orders)
    -- I don't really like sorting them directly, change it if it causes any issue
    table.sort(self._handlers, self:GetActivityHandlerComparator(orders))
end

---@param handler ActivityHandler
function CP77RPC2:AddActivityHandler(handler)
    -- Deprecated because an id is necessary to preserve handler order
    ConsoleWarn("Usage of deprecated method CP77RPC2:AddActivityHandler(), use :SetActivityHandler instead.")
    return handler
end

---@param handler ActivityHandler
function CP77RPC2:RemoveActivityHandler(handler)
    ConsoleWarn("Usage of deprecated method CP77RPC2:RemoveActivityHandler(), use :DelActivityHandler instead.")
end

function CP77RPC2:GetGenderImageKey(gender)
    return self.style == "PL" and table.concat{gender:lower(),"-pl"} or gender:lower()
end

function CP77RPC2:GetRadioExtActiveStation()
    if not self.enableRadioExtIntegration then return nil; end
    if self.RadioExt and self.RadioExt.radioManager and self.RadioExt.radioManager.managerV then
        local stationData = self.RadioExt.radioManager.managerV:getActiveStationData()
        if not stationData then return nil; end
        if stationData.isStream then
            return {
                radioName = stationData.station,
                songName = self.Localization:Get("RadioExt.Stream.Song")
            }
        end
        return {
            radioName = stationData.station,
            songName = stationData.track:match(".*[\\/](.+)%.") or ""
        }
    end
    return nil
end

function CP77RPC2:UpdateGameState()
    -- We assume the player is in the MainMenu by default
    -- GameUI does not detect the transition from DeathMenu to MainMenu
    -- However, GameUI.IsDetached() does return true
    local newState = GameStates.MainMenu
    if GameUI.IsLoading() or GameUI.IsFastTravel() then
        newState = GameStates.Loading
    elseif GameUI.IsMenu() then
        if GameUI.GetMenu() == "MainMenu" then
            newState = GameStates.MainMenu
        elseif GameUI.GetMenu() == "DeathMenu" then
            newState = GameStates.DeathMenu
        elseif GameUI.GetMenu() == "PauseMenu" then
            newState = GameStates.PauseMenu
        elseif not GameUI.IsDetached() then
            newState = GameStates.Playing
        end
    elseif not GameUI.IsDetached() then
        newState = GameStates.Playing
    end
    -- Update at the end in case some other mod has a reference to this mod.
    -- Don't really know if mods run on different threads.
    -- If not, congrats to CET for being well optimized.
    self.gameState = newState
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
    CP77RPC2._configInitialized = true

    CP77RPC2.startedAt = os.time() * 1e3

    if RadioExt then
        CP77RPC2.RadioExt = GetMod("radioExt")
    end

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

    -- GameUI.Listen(function() end)
    -- Don't add listeners for all Events of GameUI
    GameUI.OnFastTravel(function () end)
    GameUI.OnLoading(function () end)
    GameUI.OnSession(function () end)
    GameUI.OnMenu(function () end)
    -- These listeners will force GameUI to update its state
    -- So that CP77RPC2:UpdateGameState() can directly query GameUI

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

        CP77RPC2:UpdateGameState()
        -- CP77RPC2.gameState can't be GameStates.None after calling CP77RPC2:UpdateGameState()
        -- Though this check will remain to be future-proof.
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
            local h = CP77RPC2._handlers[i]
            if h.enabled and h.handler(CP77RPC2, activity) then
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
    if CP77RPC2._configInitialized then
        CP77RPC2:SaveConfig()
    end
end

local function Event_OnDraw()
    if not (CP77RPC2.showUI or CP77RPC2.overlayOnGame) then return; end

    if ImGui.Begin("CP77 - DiscordRPC 2") then
        ImGui.Text(Localization:Get("UI.Config.Activity.Label"))
        ImGui.SameLine()
        if BetterUI.FitButtonN(1, Localization:Get("UI.Config.ForceUpdate")) then
            CP77RPC2.elapsedInterval = CP77RPC2.submitInterval + 1
        end

        ImGui.Separator()
        CP77RPC2.enabled = ImGui.Checkbox(Localization:Get("UI.Config.Enabled"), CP77RPC2.enabled)
        
        do
            local newValue, changed = BetterUI.DragFloat(
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
            " So, if you change language by mistake, you can still navigate the UI properly to revert the change."
        })

        CP77RPC2.showQuest = ImGui.Checkbox(Localization:Get("UI.Config.ShowQuest"), CP77RPC2.showQuest)
        if CP77RPC2.showQuest then
            CP77RPC2.showQuestObjective = ImGui.Checkbox(Localization:Get("UI.Config.ShowQuestObjective"), CP77RPC2.showQuestObjective)
        end

        CP77RPC2.showDrivingActivity = ImGui.Checkbox(Localization:Get("UI.Config.ShowDrivingActivity"), CP77RPC2.showDrivingActivity)
        CP77RPC2.showCombatActivity = ImGui.Checkbox(Localization:Get("UI.Config.ShowCombatActivity"), CP77RPC2.showCombatActivity)
        CP77RPC2.showRadioActivity = ImGui.Checkbox(Localization:Get("UI.Config.ShowRadioActivity"), CP77RPC2.showRadioActivity)
        if CP77RPC2.RadioExt and CP77RPC2.showRadioActivity then
            CP77RPC2.enableRadioExtIntegration = ImGui.Checkbox(
                Localization:Get("UI.Config.EnableRadioExtIntegration"),
                CP77RPC2.enableRadioExtIntegration)
        end
        CP77RPC2.showPlaythroughTime = ImGui.Checkbox(Localization:Get("UI.Config.ShowPlaythroughTime"), CP77RPC2.showPlaythroughTime)
        CP77RPC2.speedAsMPH = ImGui.Checkbox(Localization:Get("UI.Config.SpeedAsMPH"), CP77RPC2.speedAsMPH)

        -- TODO: Localization
        if ImGui.CollapsingHeader("Activities") then
            for i=1, #CP77RPC2._handlers do
                ImGui.PushID(CP77RPC2._handlers[i].id)

                if i > 1 then
                    if BetterUI.SquareButton("<") then
                        local tmp = CP77RPC2._handlers[i]
                        CP77RPC2._handlers[i]   = CP77RPC2._handlers[i-1]
                        CP77RPC2._handlers[i-1] = tmp
                    end
                else
                    BetterUI.SquareButton(" ")
                end

                ImGui.SameLine()
                if i < #CP77RPC2._handlers then
                    if BetterUI.SquareButton(">") then
                        local tmp = CP77RPC2._handlers[i]
                        CP77RPC2._handlers[i]   = CP77RPC2._handlers[i+1]
                        CP77RPC2._handlers[i+1] = tmp
                    end
                else
                    BetterUI.SquareButton(" ")
                end

                ImGui.SameLine()
                local h = CP77RPC2._handlers[i]
                h.enabled = ImGui.Checkbox(h.id, h.enabled)

                ImGui.PopID()
            end
        end

        ImGui.Separator()

        ImGui.Text(Localization:Get("UI.Config.Label"))
        ImGui.SameLine()

        if BetterUI.FitButtonN(3, Localization:Get("UI.Config.Load")) then CP77RPC2:LoadConfig(); end
        ImGui.SameLine()

        if BetterUI.FitButtonN(2, Localization:Get("UI.Config.Save")) then CP77RPC2:SaveConfig(); end
        ImGui.SameLine()

        if BetterUI.FitButtonN(1, Localization:Get("UI.Config.Reset")) then CP77RPC2:ResetConfig(); end
        ImGui.Separator()

        if ImGui.CollapsingHeader("Debug") then
            CP77RPC2.overlayOnGame = ImGui.Checkbox("Overlay on Game", CP77RPC2.overlayOnGame)
            ImGui.Separator()

            local red = CP77RPC2:GetREDInstance()
            if red then
                ImGui.Text("Discord Running: " .. (red:IsRunning() and "Yes" or "No"))
                ImGui.Text("Connected to Discord: " .. (red:IsConnected() and "Yes" or "No"))
                if red:IsOk() then
                    ImGui.Text("Discord Game SDK Error: No")
                else
                    ImGui.Text("Discord Game SDK Error: Yes (code=" .. tostring(red:GetLastRunCallbacksResult()) .. ")")
                end
            else
                ImGui.Text("redscript instance not found.")
            end

            ImGui.Separator()
            ImGui.Text("Mod Integrations:")
            ImGui.Bullet()
            ImGui.TextWrapped("RadioExt: " .. (CP77RPC2.RadioExt and "Found" or "Not Found"))

            if CP77RPC2.activity then
                ImGui.Separator()
                local activityFields = {
                    "Details",
                    "State",
                    "LargeImageKey",
                    "LargeImageText",
                    "SmallImageKey",
                    "SmallImageText"
                }
    
                for _, fieldName in next, activityFields do
                    ImGui.Text(fieldName .. ":")
                    ImGui.SameLine()
                    ImGui.TextWrapped(CP77RPC2.activity[fieldName] or "")
                end
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
