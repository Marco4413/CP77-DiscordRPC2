include "libs"

project "cp77rpc2"
  kind "SharedLib"
  language "C++"
  cppdialect "C++20"

  location "build"
  targetdir "%{prj.location}/%{cfg.buildcfg}"

  includedirs {
    "include",
    "libs/RED4ext.SDK/include",
    "libs/discord_game_sdk/cpp",
  }
  
  files { "src/**.cpp", "include/**.h" }
  links "discord_game_sdk"

  filter "toolset:gcc"
    buildoptions { "-Wall", "-Wextra", "-Wpedantic", "-Werror", }

  filter "toolset:msc"
    buildoptions { "/W4", "/WX", }

  filter "configurations:Debug"
    defines "CP77RPC2_DEBUG"
    symbols "On"

  filter "configurations:Release"
    optimize "Speed"
