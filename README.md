## Cyberpunk2077 - DiscordRPC 2

## About

**This is a Cyberpunk 2077 mod which adds Discord Rich Presence to the game!**

I had already made a mod which claimed to do the same thing, but it used CET and an external application (not convenient).
This new version is self-contained!

### Features
- Large image based on character gender.
- Small image based on lifepath.
- Level and Street Cred shown when hovering the large image.
- Quest and Objective tracking (optional).
- Driving activity (optional).
- Combat activity (optional).
- Roaming activity (no quest selected) showing what district the player is in.

### Requirements

- [RED4ext 1.20+](https://github.com/WopsS/RED4ext)
- [redscript 0.5.17+](https://github.com/jac3km4/redscript)
- [CET 1.29.1+](https://github.com/yamashi/CyberEngineTweaks)

### Adding Translations

**Note:** I don't accept PRs that add other languages since it would be a nightmare for me to maintain.
That's why this mod has support for other mods to provide translations (see below).

Other CET mods can register locales using the `CP77RPC2.RegisterLocale` function.

The following snippet of code can get you started:
```lua
-- Name used for logging inside the "onTweak" event
local langName = "Italian"
-- A unique id for this locale
local localeName = "it"
local locale = {
    -- All loc keys and their meaning can be found at https://github.com/Marco4413/CP77-DiscordRPC2/blob/master/src/cet/locales/en.lua
    -- If a key was not translated, it can be omitted and a fallback to English will be made.
    ["Locale.Name"] = "Italiano (by Marco4413)",
    ...
}

registerForEvent("onTweak", function()
    local CP77RPC2 = GetMod("CP77RPC2")
    if not CP77RPC2 then
        print("[CP77RPC2 - " .. langName .. " Translation]: CP77RPC2 is not installed.")
        return
    end

    local ok, error = CP77RPC2.RegisterLocale(localeName, locale)
    if ok then
        print("[CP77RPC2 - " .. langName .. " Translation]: Translation registered!")
    else
        print("[CP77RPC2 - " .. langName .. " Translation]: Failed to register translation: ", error)
    end
end)
```

### Credits

**Thanks to all contributors of RED4ext, redscript and CyberEngineTweaks for developing those projects, and to the
people from the Cyberpunk 2077 Modding Community Discord Server for helping me understand some parts
of RED4ext and redscript, I truly appreciate it!**

Also thanks to **WillyJL** for making the [original mod](https://github.com/Willy-JL/cp77-discord-rpc) that inspired me to do this!
And thanks to **psiberx** for developing [cet-kit](https://github.com/psiberx/cp2077-cet-kit).

## Building

**You must have premake5 and VS2022 installed.**

Run the following commands to set up build files:
```sh
$ premake5 configure
$ premake5 vs2022
```

Then open the `cp77rpc2.sln` file (with VS2022) that was created in the root directory,
and build the `cp77rpc2` project. The built RED4ext plugin can be found inside
`src/red4ext/build/Configuration/cp77rpc2.dll`. Make sure to also copy `discord_game_sdk.dll`,
found inside `src/red4ext/libs/discord_game_sdk/lib/x86_64/`, to the same folder as the plugin.
