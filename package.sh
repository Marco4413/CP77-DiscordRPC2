#!/bin/bash

set -xe

MOD_VERSION="$( git describe --tags --abbrev=0 --match='v*' | sed s/^v// )"

BASE='./build'
ARTIFACT_DIR="./artifact"

CET_TARGET="./$BASE/bin/x64/plugins/cyber_engine_tweaks/mods/CP77RPC2"
REDSCRIPT_TARGET="./$BASE/r6/scripts/CP77RPC2"
RED4EXT_TARGET="./$BASE/red4ext/plugins/CP77RPC2"

mkdir -p "$ARTIFACT_DIR"
mkdir -p "$CET_TARGET"
mkdir -p "$REDSCRIPT_TARGET"
mkdir -p "$RED4EXT_TARGET"

# Package CET mod

cp './src/cet/init.lua'         "$CET_TARGET"
cp './src/cet/BetterUI.lua'     "$CET_TARGET"
cp './src/cet/GameUtils.lua'    "$CET_TARGET"
cp './src/cet/Handlers.lua'     "$CET_TARGET"
cp './src/cet/Localization.lua' "$CET_TARGET"
cp -R './src/cet/locales'       "$CET_TARGET"
cp './README.md'  "$CET_TARGET"
cp './LICENSE.md' "$CET_TARGET"

mkdir -p "$CET_TARGET/libs/cp2077-cet-kit"
cp './src/cet/libs/cp2077-cet-kit/GameUI.lua' "$CET_TARGET/libs/cp2077-cet-kit"
cp './src/cet/libs/cp2077-cet-kit/LICENSE'    "$CET_TARGET/libs/cp2077-cet-kit"

mkdir -p "$CET_TARGET/data"
echo 'Thank you.' > "$CET_TARGET/data/PLEASE_VORTEX_DONT_IGNORE_THIS_FOLDER"

# Package REDscript mod

cp './src/redscript/CP77RPC2.reds' "$REDSCRIPT_TARGET"

# Package RED4ext mod

cp './src/red4ext/build/Release/cp77rpc2.dll'                            "$RED4EXT_TARGET"
cp './src/red4ext/libs/discord_game_sdk/lib/x86_64/discord_game_sdk.dll' "$RED4EXT_TARGET"

# Create zip

7z a -mx9 -r -- "$ARTIFACT_DIR/DiscordRPC2-$MOD_VERSION.zip" \
    "./$BASE/bin" \
    "./$BASE/r6"  \
    "./$BASE/red4ext"
