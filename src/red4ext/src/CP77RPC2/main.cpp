#include "CP77RPC2/discordrpc.h"

// #define DISCORD_CLIENT_ID 1025361016802005022

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle aHandle, RED4ext::v1::EMainReason aReason, const RED4ext::v1::Sdk* aSdk)
{
    switch (aReason) {
    case RED4ext::v1::EMainReason::Load: {
        RED4ext::CRTTISystem* rtti = RED4ext::CRTTISystem::Get();
        rtti->AddRegisterCallback(CP77RPC2::Bindings::RegisterTypes);
        rtti->AddPostRegisterCallback(CP77RPC2::Bindings::PostRegisterTypes);
        CP77RPC2::DiscordRPC::GetInstance()->Start();
        aSdk->logger->InfoF(aHandle, "Loaded!\n");
    } break;
    case RED4ext::v1::EMainReason::Unload: {
        CP77RPC2::DiscordRPC::GetInstance()->Stop();
        aSdk->logger->InfoF(aHandle, "Unloaded!\n");
    } break;
    }

    return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* aInfo)
{
    aInfo->name = L"DiscordRPC2";
    aInfo->author = L"Marco4413";
    aInfo->version = RED4EXT_V1_SEMVER(2, 9, 1);
    aInfo->runtime = RED4EXT_V1_RUNTIME_VERSION_INDEPENDENT;
    aInfo->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports()
{
    return RED4EXT_API_VERSION_1;
}
