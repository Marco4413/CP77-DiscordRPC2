## Cyberpunk2077RPC2

## About

**This is a Cyberpunk 2077 mod which adds Discord Rich Presence to the game!**

I had already made a mod which claimed to do the same thing, but it used CET and an external application (not convenient).

I plan to get all features from the previous version up and running within this new one. However, it will take some time.
**Though once feature parity is reached, I'll release this version on Nexusmods!**

### Requirements

- [RED4ext 1.18+](https://github.com/WopsS/RED4ext)
- [redscript 0.5.16+](https://github.com/jac3km4/redscript)

### Credits

**Thanks to all contributors of RED4ext and redscript for developing those projects, and to the
people from the Cyberpunk 2077 Modding Community Discord Server for helping me understand some parts
of RED4ext and redscript, I truly appreciate it!**

Also thanks to **WillyJL** for making the [original mod](https://github.com/Willy-JL/cp77-discord-rpc) that inspired me to do this!

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
