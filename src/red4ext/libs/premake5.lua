local discord_game_sdk_premake_lua = [[
project "discord_game_sdk"
  kind "StaticLib"
  language "C++"
  cppdialect "C++20"
 
  location "build"
  targetdir "%{prj.location}/%{cfg.buildcfg}"
 
  includedirs "cpp"
  files { "cpp/**.cpp", "cpp/**.h", }
  links "lib/x86_64/discord_game_sdk.dll.lib"
 
  filter "toolset:gcc"
    buildoptions { "-Wall", "-Wextra", "-Wpedantic", "-Werror", }
 
  filter "toolset:msc"
    buildoptions { "/W4", "/WX", }
 
  filter "configurations:Debug"
    symbols "On"
 
  filter "configurations:Release"
    optimize "Speed"
]]

if _ACTION == "configure" then
  local dgs_zip = "discord_game_sdk.zip"
  local dgs_fold = "discord_game_sdk"
  
  if os.isfile(dgs_zip) then
    printf("Removing old %s", dgs_zip)
    os.remove(dgs_zip)
  end

  if os.isdir(dgs_fold) then
    printf("Removing old %s folder...", dgs_fold)
    os.rmdir(dgs_fold)
  end

  do -- Download Discord Game SDK
    local url = "https://dl-game-sdk.discordapp.net/2.5.6/discord_game_sdk.zip"
    printf("Downloading %s from %s", dgs_zip, url)
    local str, code = http.download(url, dgs_zip)
    if code ~= 200 then
      error("Could not download " .. dgs_zip)
    end
    printf("%s downloaded!", dgs_zip)
  end

  printf("Extracting %s to %s", dgs_zip, dgs_fold)
  zip.extract(dgs_zip, dgs_fold)
  printf("Writing premake file for %s...", dgs_fold)
  io.writefile(path.join(dgs_fold, "premake5.lua"), discord_game_sdk_premake_lua)
  print("discord_game_sdk configuration complete!")
end

include "discord_game_sdk"
