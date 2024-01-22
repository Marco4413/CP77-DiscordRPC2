return {
    -- The name to be displayed when selecting this locale
    -- I'd suggest using the following standard: "{LocaleDisplayName} (by {AuthorName})"
    ["Locale.Name"] = "English",
    -- As you can see all keys have the same naming convention: "{GameState}.{ActivityFieldName}.{SubGameState}"
    -- ActivityFieldName(s) can be found at https://discord.com/developers/docs/rich-presence/how-to#updating-presence-update-presence-payload-fields
    -- Just scroll a little down and there should be an image with a legend.
    -- Missing entries of user-created locales will fallback to English.
    ["Loading.Details"] = "Loading...",
    ["MainMenu.Details"] = "Watching the Main Menu.",
    ["PauseMenu.Details"] = "Game Paused.",
    -- Vars: level, streetCred
    ["PauseMenu.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
    -- Vars: lifepath
    ["PauseMenu.SmallImageText"] = "{lifepath}",
    -- Vars: lifepath, playthroughTime (hours)
    ["PauseMenu.SmallImageText.WPlaythroughTime"] = "{playthroughTime}h {lifepath}",
    ["DeathMenu.Details"] = "Admiring the Death Menu.",
    ["DeathMenu.State"] = "No Armor?",
    -- Vars: health, maxHealth, armor
    ["Combat.Details"] = "Fighting with {health}/{maxHealth}HP",
    -- Vars: level, streetCred
    ["Combat.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
    -- Vars: lifepath
    ["Combat.SmallImageText"] = "{lifepath}",
    -- Vars: lifepath, playthroughTime (hours)
    ["Combat.SmallImageText.WPlaythroughTime"] = "{playthroughTime}h {lifepath}",
    -- Vars: weapon
    ["Combat.State.Weapon"] = "Using {weapon}",
    ["Combat.State.NoWeapon"] = "No weapon equipped.",
    -- Vars: vehicle
    ["Driving.Details"] = "Driving {vehicle}",
    -- Vars: level, streetCred
    ["Driving.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
    -- Vars: lifepath
    ["Driving.SmallImageText"] = "{lifepath}",
    -- Vars: lifepath, playthroughTime (hours)
    ["Driving.SmallImageText.WPlaythroughTime"] = "{playthroughTime}h {lifepath}",
    -- Vars: speed, speedUnit
    ["Driving.State.Forward"] = "Cruising at {speed}{speedUnit}",
    -- Vars: speed, speedUnit
    ["Driving.State.Backwards"] = "Going backwards at {speed}{speedUnit}",
    ["Driving.State.Parked"] = "Currently parked.",
    -- Vars: name (Quest Name), objective (Empty if disabled by the player)
    ["Playing.Details"] = "Playing {name}",
    ["Playing.Details.Roaming"] = "Roaming.",
    -- Vars: main (Main District)
    ["Playing.Details.RoamingDistrict"] = "Roaming in {main}.",
    -- Vars: main (Main District), sub (Sub District)
    ["Playing.Details.RoamingSubDistrict"] = "Roaming in {sub},",
    -- Vars: level, streetCred
    ["Playing.LargeImageText"] = "Level: {level}; Street Cred: {streetCred}",
    -- Vars: lifepath
    ["Playing.SmallImageText"] = "{lifepath}",
    -- Vars: lifepath, playthroughTime (hours)
    ["Playing.SmallImageText.WPlaythroughTime"] = "{playthroughTime}h {lifepath}",
    -- Vars: name (Quest Name), objective (Empty if disabled by the player)
    ["Playing.State"] = "{objective}",
    ["Playing.State.Roaming"] = "",
    -- Vars: main (Main District)
    ["Playing.State.RoamingDistrict"] = "",
    -- Vars: main (Main District), sub (Sub District)
    ["Playing.State.RoamingSubDistrict"] = "{main}",
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
    ["UI.Config.ShowDrivingActivity"] = "Show Driving Activity",
    ["UI.Config.ShowCombatActivity"] = "Show Combat Activity",
    ["UI.Config.ShowPlaythroughTime"] = "Show Playthrough Time [EXPERIMENTAL]",
    ["UI.Config.SpeedAsMPH"] = "Speed as MPH"
}