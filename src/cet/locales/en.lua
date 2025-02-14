return {
    -- The name to be displayed when selecting this locale
    -- I'd suggest using the following standard: "{LocaleDisplayName} (by {AuthorName})"
    ["Locale.Name"] = "English",
    -- As you can see all keys have the same naming convention: "{GameState}.{ActivityFieldName}.{SubGameState}"
    -- ActivityFieldName(s) can be found at https://discord.com/developers/docs/rich-presence/how-to#updating-presence-update-presence-payload-fields
    -- Just scroll a little down and there should be an image with a legend.
    -- Missing entries of user-created locales will fallback to English.
    ["RadioExt.Stream.Song"] = "Streaming from the Net.",

    ["Loading.Details"] = "Loading...",
    ["MainMenu.Details"] = "Watching the Main Menu.",
    ["DeathMenu.Details"] = "Admiring the Death Menu.",
    ["DeathMenu.State"] = "No Armor?",

    -- Common Vars: level, streetCred, playthroughTime (hours, if available)
    ["Common.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
    ["Common.SmallImageText"] = "{lifepath}",
    ["Common.SmallImageText.WPlaythroughTime"] = "{playthroughTime}h {lifepath}",
    -- Translations for life paths
    ["Common.LifePath.Nomad"] = "Nomad",
    ["Common.LifePath.StreetKid"] = "StreetKid",
    ["Common.LifePath.Corporate"] = "Corpo",

    ["PauseMenu.Details"] = "Game Paused.",

    -- Radio Vars: radio, song
    ["Radio.Details"] = "Tuned on {radio},",
    ["Radio.State"] = "{song}",
    -- Radio + Vehicle Vars: vehicle
    ["Radio.Details.Vehicle"] = "Tuned on {radio},",
    ["Radio.State.Vehicle"] = "{song}",

    -- Combat Vars: health, maxHealth, armor
    ["Combat.Details"] = "Fighting with {health}/{maxHealth}HP",
    ["Combat.State.NoWeapon"] = "No weapon equipped.",
    -- Combat + Weapon Vars: weapon
    ["Combat.State.Weapon"] = "Using {weapon}",
    
    -- Driving Vars: vehicle, speed (>= 0), speedUnit
    ["Driving.Details"] = "Driving {vehicle}",
    ["Driving.State.Forward"] = "Cruising at {speed}{speedUnit}",
    ["Driving.State.Backwards"] = "Going backwards at {speed}{speedUnit}",
    ["Driving.State.Parked"] = "Currently parked.",

    -- Playing Quest Vars: quest, objective (Empty if disabled by the player)
    ["Playing.Details"] = "Playing {quest}",
    ["Playing.State"] = "{objective}",
    
    -- Roaming District Vars: district, subDistrict
    ["Playing.Details.Roaming.District"] = "Roaming in {district}.",
    ["Playing.State.Roaming.District"] = "",
    ["Playing.Details.Roaming.SubDistrict"] = "Roaming in {subDistrict},",
    ["Playing.State.Roaming.SubDistrict"] = "{district}",

    -- No Specific Vars
    ["Playing.Details.Roaming"] = "Roaming.",
    ["Playing.State.Roaming"] = "",

    ["UI.Config.Label"] = "Config |",
    ["UI.Config.Save"] = "Save",
    ["UI.Config.Load"] = "Load",
    ["UI.Config.Reset"] = "Reset",
    ["UI.Config.Activity.Label"] = "Activity |",
    ["UI.Config.ForceUpdate"] = "Force Update",
    ["UI.Config.Enabled"] = "Enabled",
    ["UI.Config.SubmitInterval"] = "Submit Interval",
    ["UI.Config.PLStyle"] = "Phantom Liberty Style (changes gender image)",
    ["UI.Config.ShowQuest"] = "Show Quest",
    ["UI.Config.ShowQuestObjective"] = "Show Quest Objective",
    ["UI.Config.EnableRadioExtIntegration"] = "Enable RadioExt Integration",
    ["UI.Config.ShowPlaythroughTime"] = "Show Playthrough Time [EXPERIMENTAL]",
    ["UI.Config.SpeedAsMPH"] = "Speed as MPH",

    ["UI.Config.Activities"] = "Activities",
    -- In Lua [[ ]] denotes a multi-line string
    ["UI.Config.Activities.Description"] = [[
Pressing the checkbox will toggle the activity on or off.
While pressing the '<' or '>' button will modify the priority of the activity. The top-most one is the one with the lowest priority (i.e. the one which will be overridden by the others if one is applied).
]],
    ["UI.Config.Activities.Item.DiscordRPC2.Playing"]   = "Playing",
    ["UI.Config.Activities.Item.DiscordRPC2.Combat"]    = "Combat",
    ["UI.Config.Activities.Item.DiscordRPC2.Driving"]   = "Driving",
    ["UI.Config.Activities.Item.DiscordRPC2.Radio"]     = "Radio",
    ["UI.Config.Activities.Item.DiscordRPC2.DeathMenu"] = "Death Menu",
    ["UI.Config.Activities.Item.DiscordRPC2.PauseMenu"] = "Pause Menu",
    ["UI.Config.Activities.Item.DiscordRPC2.MainMenu"]  = "Main Menu",
    ["UI.Config.Activities.Item.DiscordRPC2.Loading"]   = "Loading"
}