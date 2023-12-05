#include "CP77RPC2/discordcore.h"

// #define DISCORD_CLIENT_ID 1025361016802005022

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::PluginHandle aHandle, RED4ext::EMainReason aReason, const RED4ext::Sdk* aSdk)
{
    switch (aReason) {
    case RED4ext::EMainReason::Load: {
        RED4ext::RTTIRegistrator::Add(CP77RPC2::RegisterTypes, CP77RPC2::PostRegisterTypes);
        CP77RPC2::Discord::Start();
        aSdk->logger->InfoF(aHandle, "Loaded!\n");
        break;
    }
    case RED4ext::EMainReason::Unload: {
        CP77RPC2::Discord::Stop();
        aSdk->logger->InfoF(aHandle, "Unloaded!\n");
    }
    }

    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::PluginInfo* aInfo)
{
    aInfo->name = L"DiscordRPC2";
    aInfo->author = L"Marco4413";
    aInfo->version = RED4EXT_SEMVER(2, 0, 1);
    aInfo->runtime = RED4EXT_RUNTIME_LATEST;
    aInfo->sdk = RED4EXT_SDK_LATEST;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_LATEST;
}
